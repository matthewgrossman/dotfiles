import copy
import importlib.util
from pathlib import Path
import unittest
from unittest.mock import patch

spec = importlib.util.spec_from_file_location("aliases", Path(__file__).with_name("sync_aliases.py"))
aliases = importlib.util.module_from_spec(spec)
spec.loader.exec_module(aliases)


def snapshot(names=(None,), workspace="OpenShell", tab="Test Runner"):
    return {
        "workspaces": [{"workspace_id": "w1", "label": workspace}],
        "tabs": [{"tab_id": "w1:t1", "label": tab}],
        "agents": [{"pane_id": f"w1:p{i}", "workspace_id": "w1", "tab_id": "w1:t1",
                    "agent": "opencode", "name": name} for i, name in enumerate(names, 1)],
    }


class AliasTests(unittest.TestCase):
    def test_unnamed_and_marked_agents_are_managed(self):
        self.assertEqual(aliases.desired_aliases(snapshot()), {"w1:p1": "openshell-test-runner_"})
        self.assertEqual(aliases.desired_aliases(snapshot(("old-auto_",))), {"w1:p1": "openshell-test-runner_"})

    def test_unmarked_aliases_are_untouched(self):
        self.assertEqual(aliases.desired_aliases(snapshot(("review-4629", "spork-123"))), {})

    def test_shared_tab_uses_stable_pane_identifiers(self):
        self.assertEqual(aliases.desired_aliases(snapshot((None, None))), {
            "w1:p1": "openshell-test-runner-w1-p1_",
            "w1:p2": "openshell-test-runner-w1-p2_",
        })

    def test_normalization_and_length(self):
        for workspace, tab in [("123", "???"), ("Ünicode", "日本語"), ("a" * 80, "b" * 80)]:
            names = aliases.desired_aliases(snapshot((None, None), workspace, tab)).values()
            self.assertEqual(len(set(names)), 2)
            for name in names:
                self.assertRegex(name, r"^[a-z][a-z0-9_-]{0,31}$")
                self.assertTrue(name.endswith("_"))

    def test_same_labels_across_workspaces_are_unique(self):
        state = snapshot((None,))
        state["workspaces"].append({"workspace_id": "w2", "label": "OpenShell"})
        state["tabs"].append({"tab_id": "w2:t1", "label": "Test Runner"})
        state["agents"].append({"pane_id": "w2:p1", "workspace_id": "w2", "tab_id": "w2:t1"})
        names = aliases.desired_aliases(state)
        self.assertNotEqual(names["w1:p1"], names["w2:p1"])

    def test_current_labels_alone_determine_names(self):
        state = snapshot(("previous-name_",))
        state["tabs"][0]["label"] = "New Tab"
        self.assertEqual(aliases.desired_aliases(state), {"w1:p1": "openshell-new-tab_"})

    def test_disappearing_peer_removes_disambiguator(self):
        state = snapshot(("openshell-test-runner-w1-p1_",))
        self.assertEqual(aliases.desired_aliases(state)["w1:p1"], "openshell-test-runner_")

    def test_snapshot_order_does_not_change_names(self):
        state = snapshot((None, None, None))
        expected = aliases.desired_aliases(state)
        state["agents"].reverse()
        self.assertEqual(aliases.desired_aliases(state), expected)

    def test_preview_and_idempotence(self):
        with patch.object(aliases, "herdr", return_value={"snapshot": snapshot()}) as cli, patch("builtins.print"):
            aliases.sync()
            cli.assert_called_once_with("api", "snapshot")
        state = snapshot(("openshell-test-runner_",))
        with patch.object(aliases, "herdr", return_value={"snapshot": state}) as cli:
            aliases.sync(apply=True)
            cli.assert_called_once_with("api", "snapshot")

    def test_manual_rename_between_snapshot_and_apply_wins(self):
        state = snapshot()
        live = {**state["agents"][0], "name": "manual"}
        with patch.object(aliases, "herdr", side_effect=[{"snapshot": state}, {"agent": live}]) as cli:
            aliases.sync(apply=True)
            self.assertEqual(cli.call_count, 2)

    def test_two_phase_rename_handles_swapped_labels(self):
        state = snapshot(("openshell-two_",))
        state["tabs"][0]["label"] = "One"
        state["tabs"].append({"tab_id": "w1:t2", "label": "Two"})
        state["agents"].append({**state["agents"][0], "pane_id": "w1:p2", "tab_id": "w1:t2", "name": "openshell-one_"})
        live = {agent["pane_id"]: copy.deepcopy(agent) for agent in state["agents"]}

        def cli(*args):
            if args == ("api", "snapshot"):
                return {"snapshot": copy.deepcopy(state)}
            if args[:2] == ("agent", "get"):
                return {"agent": copy.deepcopy(live[args[2]])}
            if args[:2] == ("agent", "rename"):
                self.assertNotIn(args[3], {agent["name"] for agent in live.values()})
                live[args[2]]["name"] = args[3]
                return {}
            self.fail(args)

        with patch.object(aliases, "herdr", side_effect=cli), patch("builtins.print"):
            aliases.sync(apply=True)
        self.assertEqual(live["w1:p1"]["name"], "openshell-one_")
        self.assertEqual(live["w1:p2"]["name"], "openshell-two_")


if __name__ == "__main__":
    unittest.main()
