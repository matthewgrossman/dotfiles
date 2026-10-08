"""Fuzzy-find a Herdr pane and copy its ID. No agent or message APIs."""

import json
import os
import re
import shlex
import subprocess
import sys
import tempfile
from pathlib import Path


PLUGIN_ID = "local.pane-picker"


def herdr(*args):
    result = subprocess.run([os.environ.get("HERDR_BIN_PATH", "herdr"), *args],
                            capture_output=True, text=True, timeout=30, check=True)
    return json.loads(result.stdout)["result"]


def display(value):
    # Pane titles must not inject terminal escapes, columns, or picker rows.
    return re.sub(r"[\x00-\x1f\x7f-\x9f]", " ", str(value or ""))


def pane_rows(snapshot):
    workspaces = {w["workspace_id"]: w.get("label") for w in snapshot["workspaces"]}
    tabs = {t["tab_id"]: t.get("label") for t in snapshot["tabs"]}
    rows = []
    # Stable sorting preserves Herdr's order within each locality group.
    panes = sorted(snapshot["panes"], key=lambda pane: (
        pane.get("workspace_id") != snapshot.get("focused_workspace_id"),
        pane.get("tab_id") != snapshot.get("focused_tab_id"),
    ))
    for pane in panes:
        title = (pane.get("label") or pane.get("name")
                 or pane.get("terminal_title_stripped") or pane.get("terminal_title"))
        fields = [workspaces.get(pane.get("workspace_id")),
                  tabs.get(pane.get("tab_id")), title,
                  pane.get("foreground_cwd") or pane.get("cwd"),
                  pane.get("agent") or "terminal", pane["pane_id"]]
        label = " · ".join(display(value) for value in fields if value)
        rows.append(f"{pane['pane_id']}\t{label}")
    return rows


def pick_pane(snapshot):
    rows = pane_rows(snapshot)
    if not rows:
        raise ValueError("No Herdr panes available")
    agent_ids = {pane["pane_id"] for pane in snapshot["panes"] if pane.get("agent")}
    agent_rows = [row for row in rows if row.split("\t", 1)[0] in agent_ids]
    with tempfile.TemporaryDirectory(prefix="herdr-pane-picker-") as directory:
        all_file, agent_file = Path(directory) / "all", Path(directory) / "agents"
        all_file.write_text("\n".join(rows) + "\n")
        agent_file.write_text("".join(row + "\n" for row in agent_rows))
        toggle = (
            "ctrl-a:transform:if [ \"$FZF_PROMPT\" = 'Agents> ' ]; then "
            "printf '%s\\n' \"$HERDR_PICKER_SHOW_ALL\"; else "
            "printf '%s\\n' \"$HERDR_PICKER_SHOW_AGENTS\"; fi"
        )
        result = subprocess.run(
            ["fzf", "--no-multi", "--no-sort", "--layout=reverse", "--delimiter=\t", "--with-nth=2..",
             "--prompt=Agents> ", "--header=Ctrl+A: agents/all panes · Enter: copy ID · Esc: cancel",
             "--with-shell=/bin/sh -c", "--bind", toggle],
            input=agent_file.read_text(), stdout=subprocess.PIPE, text=True,
            env={**os.environ, "FZF_DEFAULT_OPTS": "", "FZF_DEFAULT_OPTS_FILE": "",
                 "HERDR_PICKER_SHOW_ALL": f"change-prompt(All panes> )+reload:cat {shlex.quote(str(all_file))}",
                 "HERDR_PICKER_SHOW_AGENTS": f"change-prompt(Agents> )+reload:cat {shlex.quote(str(agent_file))}"},
        )
    if result.returncode in (1, 130):
        return None
    if result.returncode:
        raise ValueError("fzf failed")
    pane_id = result.stdout.split("\t", 1)[0].strip()
    if pane_id not in {pane["pane_id"] for pane in snapshot["panes"]}:
        raise ValueError("Invalid picker selection")
    return pane_id


def copy_pane():
    pane_id = pick_pane(herdr("api", "snapshot")["snapshot"])
    if pane_id is not None:
        # Absolute path also works with GPUI's non-interactive PATH. No newline.
        subprocess.run(["/usr/bin/pbcopy"], input=pane_id, capture_output=True,
                       text=True, timeout=5, check=True)
        print(f"Copied {pane_id}.")


def main():
    try:
        if os.environ.get("HERDR_ENV") != "1":
            raise ValueError("Run this plugin inside Herdr")
        if sys.argv[1:] == ["--open"]:
            # Popups target the active pane automatically; no source ID needed.
            herdr("plugin", "pane", "open", "--plugin", PLUGIN_ID, "--entrypoint", "picker")
        elif not sys.argv[1:]:
            copy_pane()
        else:
            raise ValueError("Usage: picker.py [--open]")
    except (OSError, ValueError, KeyError, TypeError, subprocess.SubprocessError) as error:
        detail = getattr(error, "stderr", None) or str(error)
        print(f"Error: {detail.strip()}", file=sys.stderr)
        if not sys.argv[1:] and sys.stdin.isatty():
            try:
                input("Press Enter to close.")
            except EOFError:
                pass
        return 1
    except (KeyboardInterrupt, EOFError):
        return 130
    return 0


if __name__ == "__main__":
    sys.exit(main())
