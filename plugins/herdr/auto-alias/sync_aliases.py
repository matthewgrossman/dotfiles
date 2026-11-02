"""Herdr is the only naming database: unnamed or trailing-_ aliases are managed."""

import argparse
from collections import Counter
import fcntl
import json
import os
from pathlib import Path
import re
import subprocess
import sys
import unicodedata


def slug(text):
    text = unicodedata.normalize("NFKD", text).encode("ascii", "ignore").decode().lower()
    return re.sub(r"[^a-z0-9]+", "-", text).strip("-") or "agent"


def alias(base, suffix=""):
    return base[:31 - len(suffix)].rstrip("-") + suffix + "_"


def desired_aliases(snapshot):
    workspaces = {item["workspace_id"]: item["label"] for item in snapshot["workspaces"]}
    tabs = {item["tab_id"]: item["label"] for item in snapshot["tabs"]}
    bases = {}
    for agent in snapshot["agents"]:
        name = agent.get("name")
        if name and not name.endswith("_"):
            continue
        if agent["workspace_id"] not in workspaces or agent["tab_id"] not in tabs:
            continue
        base = slug(workspaces[agent["workspace_id"]] + "-" + tabs[agent["tab_id"]])
        if not base[0].isalpha():
            base = "a-" + base
        bases[agent["pane_id"]] = base

    counts = Counter(alias(base) for base in bases.values())
    result = {pane: alias(base) for pane, base in bases.items() if counts[alias(base)] == 1}
    used = set(result.values())
    for pane, base in sorted(bases.items()):
        if pane in result:
            continue
        suffix = "-" + slug(pane)
        candidate = alias(base, suffix)
        counter = 2
        while candidate in used:
            candidate = alias(base, suffix + f"-{counter}")
            counter += 1
        result[pane] = candidate
        used.add(candidate)
    return result


def herdr(*args):
    result = subprocess.run([os.environ.get("HERDR_BIN_PATH", "herdr"), *args],
                            check=True, capture_output=True, text=True, timeout=10)
    return json.loads(result.stdout)["result"]


def sync(apply=False):
    snapshot = herdr("api", "snapshot")["snapshot"]
    desired = desired_aliases(snapshot)
    changes = [(agent, desired[agent["pane_id"]]) for agent in snapshot["agents"]
               if agent["pane_id"] in desired and agent.get("name") != desired[agent["pane_id"]]]
    if not apply:
        for agent, name in changes:
            print(f"{agent['pane_id']}: {agent.get('name') or '(unnamed)'} -> {name}")
        return

    # Stage changes under temporary managed names so swapping tab/workspace
    # labels cannot collide with another agent's old alias. No saved ownership.
    used = {agent.get("name") for agent in snapshot["agents"]} | set(desired.values())
    staged = []
    for agent, name in changes:
        pane = agent["pane_id"]
        try:
            live = herdr("agent", "get", pane)["agent"]
            if (live.get("name"), live.get("agent_session"), live.get("agent")) != (
                    agent.get("name"), agent.get("agent_session"), agent.get("agent")):
                continue  # A manual rename, exit, or replacement won the race.
            temporary = alias("alias-tmp-" + slug(pane))
            counter = 2
            while temporary in used:
                temporary = alias("alias-tmp-" + slug(pane), f"-{counter}")
                counter += 1
            used.add(temporary)
            herdr("agent", "rename", pane, temporary)
            staged.append((pane, temporary, name))
        except subprocess.CalledProcessError as error:
            print(f"auto-alias: {pane}: {error.stderr.strip()}", file=sys.stderr)
    for pane, temporary, name in staged:
        try:
            if herdr("agent", "get", pane)["agent"].get("name") == temporary:
                herdr("agent", "rename", pane, name)
                print(f"{pane}: {name}")
        except subprocess.CalledProcessError as error:
            print(f"auto-alias: {pane}: {error.stderr.strip()}", file=sys.stderr)


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--apply", action="store_true", help="rename agents (default: preview only)")
    args = parser.parse_args()
    # Serialize event handlers using the script's inode, not a state/lock file.
    with Path(__file__).open() as lock:
        fcntl.flock(lock, fcntl.LOCK_EX)
        sync(args.apply)
