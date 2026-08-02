---
name: herdr-orca
description: Use only from the herdr-orca profile to discover and inspect child worktree workspaces belonging to its current Herdr parent workspace.
---

# Herdr Orca

Use the bundled snapshot script as the authoritative source for Orca's child
workspace membership and current agent state:

```bash
scripts/child-snapshot.sh
```

The script reads `HERDR_WORKSPACE_ID`, queries the running Herdr session, and
returns JSON containing only open linked worktrees associated with that parent.
Each child contains its worktree record, matching workspace record, and matching
agent records. Unrelated workspaces and agents are excluded before output.

This skill defines discovery and snapshot mechanics only. The `herdr-orca`
agent profile defines dispatch, child briefs, retries, and authorization scope.

Rules:

- Run the script once for each requested status snapshot or before dispatch when
  membership might have changed.
- Treat `children[].workspace.workspace_id` as the only allowed workspace IDs.
- Use IDs and paths returned by Herdr. Never infer worktree locations.
- Use `children[].agents[].agent_session` for native transcript export and
  prefer that live transcript over terminal scrollback or summarized state.
- Do not separately call `herdr worktree list`, `herdr workspace list`, or
  `herdr agent list` to reconstruct the same snapshot.
- Do not use a remembered child after it disappears from a fresh snapshot.
- If the script fails, report its error. Do not fall back to workspace-name or
  path matching.
- After the first unknown command or option, inspect the relevant installed
  command group. Treat its help as authoritative and do not guess another syntax.
- Before retrying any possibly partial dispatch, inspect the native transcript
  and confirm that the requested action did not already occur.
