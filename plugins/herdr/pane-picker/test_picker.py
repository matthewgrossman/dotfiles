import json
import os
from pathlib import Path
import shutil
import subprocess
import tempfile
import tomllib
import unittest


SCRIPT = Path(__file__).with_name("picker.sh")


class PickerTests(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory(prefix="herdr picker test ")
        self.addCleanup(self.temp.cleanup)
        self.root = Path(self.temp.name)
        self.clipboard = self.root / "clipboard"
        self.sent = self.root / "sent"
        self.data = {
            "focused_workspace_id": "w2", "focused_tab_id": "w2:t2",
            "workspaces": [{"workspace_id": "w1", "label": "Other"},
                           {"workspace_id": "w2", "label": "Current"}],
            "tabs": [{"tab_id": "w2:t1", "label": "Tab one"},
                     {"tab_id": "w2:t2", "label": "Tab two"}],
            "panes": [
                {"pane_id": "w1:p1", "workspace_id": "w1", "tab_id": "w1:t1", "agent": "claude"},
                {"pane_id": "w2:p1", "workspace_id": "w2", "tab_id": "w2:t1", "agent": "pi"},
                {"pane_id": "w2:p2", "workspace_id": "w2", "tab_id": "w2:t2", "cwd": "/shell"},
                {"pane_id": "w2:p3", "workspace_id": "w2", "tab_id": "w2:t2", "agent": "opencode"},
                {"pane_id": "w2:p4", "workspace_id": "w2", "tab_id": "w2:t2", "agent": "codex"},
            ],
        }
        self.mock("herdr", '''if [[ $* == 'api snapshot' ]]; then
  cat "$TEST_SNAPSHOT"
elif [[ ${1:-} == pane && ${2:-} == send-text ]]; then
  printf '%s\\n' "$@" > "$TEST_SENT"
else
  exit 2
fi''')
        self.mock("pbcopy", 'cat > "$TEST_CLIPBOARD"')
        self.mock("fzf", 'cat > "$TEST_ROWS"\nexit 130')
        self.env = {**os.environ, "PATH": f"{self.root}:{os.environ['PATH']}", "HERDR_ENV": "1",
                    "HERDR_BIN_PATH": str(self.root / "herdr"),
                    "HERDR_PICKER_SOURCE_PANE_ID": "w2:p4", "TEST_SENT": str(self.sent),
                    "TEST_SNAPSHOT": str(self.root / "snapshot.json"),
                    "TEST_CLIPBOARD": str(self.clipboard), "TEST_ROWS": str(self.root / "rows")}

    def mock(self, name, body):
        path = self.root / name
        path.write_text("#!/bin/bash\nset -euo pipefail\n" + body + "\n")
        path.chmod(0o755)

    def run_picker(self, *args, script=SCRIPT):
        Path(self.env["TEST_SNAPSHOT"]).write_text(json.dumps({"result": {"snapshot": self.data}}))
        return subprocess.run(["bash", str(script), *args], env=self.env, capture_output=True, text=True)

    def ids(self, result):
        self.assertEqual(result.returncode, 0, result.stderr)
        return [row.split("\t", 1)[0] for row in result.stdout.splitlines()]

    def test_agents_only_and_locality_order(self):
        self.assertEqual(self.ids(self.run_picker("--list")), ["w2:p3", "w2:p4", "w2:p1", "w1:p1"])

    def test_all_panes_preserves_order_within_groups(self):
        self.assertEqual(self.ids(self.run_picker("--list", "all")),
                         ["w2:p2", "w2:p3", "w2:p4", "w2:p1", "w1:p1"])

    def test_real_fzf_search_ranks_matches_but_empty_query_stays_local(self):
        executable = shutil.which("fzf")
        if not executable:
            self.skipTest("fzf is not installed")
        self.env["TEST_REAL_FZF"] = executable
        self.data["workspaces"][0]["label"] = "oci-worktree"
        self.data["panes"][3]["terminal_title"] = "o c i -"
        self.mock("fzf", 'printf "ctrl-y\\n"\nexec "$TEST_REAL_FZF" --filter="$TEST_QUERY" "$@"')
        for query, expected in (("", b"w2:p3"), ("oci-", b"w1:p1")):
            with self.subTest(query=query):
                self.env["TEST_QUERY"] = query
                result = self.run_picker()
                self.assertEqual(result.returncode, 0, result.stderr)
                self.assertEqual(self.clipboard.read_bytes(), b"herdr " + expected)

    def test_missing_focus_preserves_snapshot_order(self):
        del self.data["focused_workspace_id"], self.data["focused_tab_id"]
        self.assertEqual(self.ids(self.run_picker("--list", "all")),
                         [pane["pane_id"] for pane in self.data["panes"]])

    def test_sanitizes_titles(self):
        self.data["panes"][3]["terminal_title"] = "Title\nforged\trow\x1b[31m"
        result = self.run_picker("--list")
        row = result.stdout.splitlines()[0]
        self.assertEqual(row.count("\t"), 1)
        self.assertNotIn("\x1b", row)
        self.assertEqual(len(result.stdout.splitlines()), 4)

    def test_cancel_and_failure_leave_clipboard_unchanged(self):
        for status in (1, 2, 130):
            self.clipboard.write_text("existing clipboard")
            self.mock("fzf", f'cat > "$TEST_ROWS"\nexit {status}')
            self.assertEqual(self.run_picker().returncode, status)
            self.assertEqual(self.clipboard.read_text(), "existing clipboard")
            self.assertFalse(self.sent.exists())

    def test_ctrl_y_copies_reference_without_typing(self):
        self.mock("fzf", 'cat > "$TEST_ROWS"\nprintf "ctrl-y\\nw2:p3\\tlabel\\n"')
        result = self.run_picker()
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(self.clipboard.read_bytes(), b"herdr w2:p3")
        self.assertFalse(self.sent.exists())

    def test_enter_inserts_into_original_pane_without_submitting_or_copying(self):
        self.mock("fzf", 'cat > "$TEST_ROWS"\nprintf "\\nw2:p3\\tlabel\\n"')
        self.clipboard.write_text("unchanged")
        result = self.run_picker()
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(self.sent.read_text().splitlines(),
                         ["pane", "send-text", "w2:p4", "herdr w2:p3"])
        self.assertEqual(self.clipboard.read_text(), "unchanged")

    def test_no_selection_does_not_type_or_copy(self):
        self.mock("fzf", 'cat > "$TEST_ROWS"\nprintf "ctrl-y\\n"')
        self.assertEqual(self.run_picker().returncode, 0)
        self.assertFalse(self.sent.exists())
        self.assertFalse(self.clipboard.exists())

    def test_missing_original_pane_never_uses_focused_pane(self):
        self.env.pop("HERDR_PICKER_SOURCE_PANE_ID")
        self.mock("fzf", 'cat > "$TEST_ROWS"\nprintf "\\nw2:p3\\tlabel\\n"')
        result = self.run_picker()
        self.assertNotEqual(result.returncode, 0)
        self.assertIn("Missing original pane ID", result.stderr)
        self.assertFalse(self.sent.exists())

    def test_action_captures_original_pane_before_opening_popup(self):
        manifest = tomllib.loads(SCRIPT.with_name("herdr-plugin.toml").read_text())
        self.mock("herdr", 'printf "%s\\n" "$@" > "$TEST_SENT"')
        self.env["HERDR_PANE_ID"] = "w9:p7"
        result = subprocess.run(manifest["actions"][0]["command"], env=self.env,
                                capture_output=True, text=True)
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(self.sent.read_text().splitlines(), [
            "plugin", "pane", "open", "--plugin", "local.pane-picker", "--entrypoint", "picker",
            "--env", "HERDR_PICKER_SOURCE_PANE_ID=w9:p7",
        ])

    def test_no_agents_can_reload_all_without_temp_files(self):
        self.data["panes"] = [self.data["panes"][2]]
        self.mock("fzf", 'cat > "$TEST_ROWS"\neval "$HERDR_PICKER_LIST all" > "$TEST_ROWS.all"\nexit 130')
        result = self.run_picker()
        self.assertEqual(result.returncode, 130, result.stderr)
        self.assertEqual((self.root / "rows").read_text(), "")
        self.assertIn("w2:p2\t", (self.root / "rows.all").read_text())

    def test_reload_command_handles_script_paths_with_spaces(self):
        script = self.root / "picker with spaces.sh"
        script.write_text(SCRIPT.read_text())
        self.mock("fzf", 'cat > "$TEST_ROWS"\neval "$HERDR_PICKER_LIST all" > "$TEST_ROWS.all"\nexit 130')
        result = self.run_picker(script=script)
        self.assertEqual(result.returncode, 130, result.stderr)
        self.assertIn("w2:p2\t", (self.root / "rows.all").read_text())

    def test_requires_herdr(self):
        self.env["HERDR_ENV"] = "0"
        result = self.run_picker()
        self.assertEqual(result.returncode, 1)
        self.assertIn("inside Herdr", result.stderr)
        self.assertFalse(self.clipboard.exists())


if __name__ == "__main__":
    unittest.main()
