import json
import os
from pathlib import Path
import subprocess
import tempfile
import unittest


SCRIPT = Path(__file__).with_name("picker.sh")


class PickerTests(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory(prefix="herdr picker test ")
        self.addCleanup(self.temp.cleanup)
        self.root = Path(self.temp.name)
        self.clipboard = self.root / "clipboard"
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
        self.mock("herdr", '[ "$*" = "api snapshot" ] || exit 2\ncat "$TEST_SNAPSHOT"')
        self.mock("pbcopy", 'cat > "$TEST_CLIPBOARD"')
        self.mock("fzf", 'cat > "$TEST_ROWS"\nexit 130')
        self.env = {**os.environ, "PATH": f"{self.root}:{os.environ['PATH']}", "HERDR_ENV": "1",
                    "HERDR_BIN_PATH": str(self.root / "herdr"),
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

    def test_selection_copies_id_only_without_newline(self):
        self.mock("fzf", 'cat > "$TEST_ROWS"\nprintf "w2:p3\\tlabel\\n"')
        result = self.run_picker()
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(self.clipboard.read_bytes(), b"w2:p3")

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
