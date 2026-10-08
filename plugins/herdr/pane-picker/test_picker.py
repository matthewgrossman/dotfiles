import contextlib
import io
import os
import shlex
import subprocess
import sys
import unittest
from pathlib import Path
from unittest.mock import patch

import picker


def snapshot():
    return {
        "focused_workspace_id": "w1",
        "focused_tab_id": "w1:t1",
        "workspaces": [{"workspace_id": "w1", "label": "dotfiles"},
                       {"workspace_id": "w2", "label": "project"}],
        "tabs": [{"tab_id": "w1:t1", "label": "agents"},
                 {"tab_id": "w2:t1", "label": "shell"}],
        "panes": [
            {"pane_id": "w1:p1", "workspace_id": "w1", "tab_id": "w1:t1",
             "agent": "opencode", "terminal_title_stripped": "Review", "cwd": "/code"},
            {"pane_id": "w2:p1", "workspace_id": "w2", "tab_id": "w2:t1", "cwd": "/project"},
        ],
    }


class PickerTests(unittest.TestCase):
    def test_defaults_to_agents_and_provides_all_panes_toggle(self):
        def run_fzf(argv, **kwargs):
            self.assertIn("--prompt=Agents> ", argv)
            self.assertIn("ctrl-a:transform:", argv[-1])
            self.assertIn("w1:p1\t", kwargs["input"])
            self.assertNotIn("w2:p1\t", kwargs["input"])
            env = kwargs["env"]
            for key, ids in (("HERDR_PICKER_SHOW_ALL", ["w1:p1", "w2:p1"]),
                             ("HERDR_PICKER_SHOW_AGENTS", ["w1:p1"])):
                command = env[key].split("+reload:", 1)[1]
                path = shlex.split(command)[1]
                rows = Path(path).read_text().splitlines()
                self.assertEqual([row.split("\t", 1)[0] for row in rows], ids)
            return subprocess.CompletedProcess(argv, 130, "")

        with patch.object(subprocess, "run", side_effect=run_fzf):
            self.assertIsNone(picker.pick_pane(snapshot()))

    def test_no_agents_still_allows_toggling_to_terminals(self):
        data = snapshot()
        data["panes"] = [data["panes"][1]]
        with patch.object(subprocess, "run", return_value=subprocess.CompletedProcess([], 130, "")) as run:
            self.assertIsNone(picker.pick_pane(data))
        self.assertEqual(run.call_args.kwargs["input"], "")

    def test_current_tab_then_current_workspace_then_other_workspaces(self):
        data = snapshot()
        data["focused_workspace_id"] = "w2"
        data["focused_tab_id"] = "w2:t2"
        data["panes"] += [
            {"pane_id": "w3:p1", "workspace_id": "w3", "tab_id": "w3:t1"},
            {"pane_id": "w2:p3", "workspace_id": "w2", "tab_id": "w2:t2"},
            {"pane_id": "w2:p4", "workspace_id": "w2", "tab_id": "w2:t1"},
            {"pane_id": "w2:p5", "workspace_id": "w2", "tab_id": "w2:t2"},
        ]
        original_ids = [pane["pane_id"] for pane in data["panes"]]
        ids = [row.split("\t", 1)[0] for row in picker.pane_rows(data)]
        self.assertEqual(ids, ["w2:p3", "w2:p5", "w2:p1", "w2:p4", "w1:p1", "w3:p1"])
        self.assertEqual([pane["pane_id"] for pane in data["panes"]], original_ids)

    def test_missing_focus_keeps_existing_order(self):
        data = snapshot()
        del data["focused_workspace_id"], data["focused_tab_id"]
        ids = [row.split("\t", 1)[0] for row in picker.pane_rows(data)]
        self.assertEqual(ids, [pane["pane_id"] for pane in data["panes"]])

    def test_includes_all_workspaces_nonagents_and_current_pane(self):
        rows = picker.pane_rows(snapshot())
        self.assertEqual(len(rows), 2)
        self.assertIn("w1:p1\tdotfiles · agents · Review · /code · opencode · w1:p1", rows)
        self.assertIn("w2:p1\tproject · shell · /project · terminal · w2:p1", rows)

    def test_sanitizes_title_without_changing_id(self):
        data = snapshot()
        data["panes"][0]["terminal_title_stripped"] = "Title\nforged\trow\x1b[31m"
        row = picker.pane_rows(data)[0]
        self.assertTrue(row.startswith("w1:p1\t"))
        self.assertEqual(row.count("\t"), 1)
        self.assertNotIn("\n", row)
        self.assertNotIn("\x1b", row)

    def test_selection_returns_only_id(self):
        with patch.object(subprocess, "run", return_value=subprocess.CompletedProcess([], 0, "w2:p1\tlabel\n")) as run:
            self.assertEqual(picker.pick_pane(snapshot()), "w2:p1")
        self.assertIn("--no-sort", run.call_args.args[0])

    def test_invalid_selection_and_empty_list_fail(self):
        with patch.object(subprocess, "run", return_value=subprocess.CompletedProcess([], 0, "w9:p9\tforged\n")):
            with self.assertRaisesRegex(ValueError, "Invalid picker selection"):
                picker.pick_pane(snapshot())
        data = snapshot()
        data["panes"] = []
        with self.assertRaisesRegex(ValueError, "No Herdr panes"):
            picker.pick_pane(data)

    def test_escape_leaves_clipboard_unchanged(self):
        with patch.object(picker, "herdr", return_value={"snapshot": snapshot()}) as herdr, \
                patch.object(subprocess, "run", return_value=subprocess.CompletedProcess([], 130, "")) as run:
            picker.copy_pane()
        herdr.assert_called_once_with("api", "snapshot")
        run.assert_called_once()
        self.assertEqual(run.call_args.args[0][0], "fzf")

    def test_copies_exact_id_without_newline_and_never_sends_input(self):
        with patch.object(picker, "herdr", return_value={"snapshot": snapshot()}) as herdr, \
                patch.object(picker, "pick_pane", return_value="w2:p1"), \
                patch.object(subprocess, "run") as run, contextlib.redirect_stdout(io.StringIO()):
            picker.copy_pane()
        herdr.assert_called_once_with("api", "snapshot")
        run.assert_called_once_with(["/usr/bin/pbcopy"], input="w2:p1", capture_output=True,
                                    text=True, timeout=5, check=True)

    def test_launch_does_not_require_source_context_or_pass_target_pane(self):
        with patch.dict(os.environ, {"HERDR_ENV": "1"}), \
                patch.object(sys, "argv", ["picker.py", "--open"]), \
                patch.object(picker, "herdr") as herdr:
            os.environ.pop("HERDR_PANE_ID", None)
            self.assertEqual(picker.main(), 0)
        herdr.assert_called_once_with("plugin", "pane", "open", "--plugin", "local.pane-picker",
                                      "--entrypoint", "picker")

    def test_refuses_to_run_outside_herdr(self):
        with patch.dict(os.environ, {"HERDR_ENV": "0"}), \
                patch.object(picker, "herdr") as herdr, \
                contextlib.redirect_stderr(io.StringIO()):
            self.assertEqual(picker.main(), 1)
        herdr.assert_not_called()


if __name__ == "__main__":
    unittest.main()
