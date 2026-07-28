#!/bin/sh
set -eu

if [ "${HERDR_ENV:-}" != "1" ]; then
  printf '%s\n' 'herdr-orca: HERDR_ENV=1 is required' >&2
  exit 1
fi

if [ -z "${HERDR_WORKSPACE_ID:-}" ]; then
  printf '%s\n' 'herdr-orca: HERDR_WORKSPACE_ID is required' >&2
  exit 1
fi

if ! command -v herdr >/dev/null 2>&1; then
  printf '%s\n' 'herdr-orca: herdr is not on PATH' >&2
  exit 1
fi

if ! command -v jq >/dev/null 2>&1; then
  printf '%s\n' 'herdr-orca: jq is not on PATH' >&2
  exit 1
fi

worktrees=$(herdr worktree list --workspace "$HERDR_WORKSPACE_ID" --json)
workspaces=$(herdr workspace list)
agents=$(herdr agent list)

jq -n \
  --arg parent_workspace_id "$HERDR_WORKSPACE_ID" \
  --argjson worktrees "$worktrees" \
  --argjson workspaces "$workspaces" \
  --argjson agents "$agents" \
  '{
    parent_workspace_id: $parent_workspace_id,
    parent: {
      source: $worktrees.result.source,
      workspace: (
        [$workspaces.result.workspaces[]
          | select(.workspace_id == $parent_workspace_id)][0] // null
      )
    },
    children: [
      $worktrees.result.worktrees[]
      | select(.is_linked_worktree == true and .open_workspace_id != null)
      | . as $worktree
      | {
          workspace: (
            [$workspaces.result.workspaces[]
              | select(.workspace_id == $worktree.open_workspace_id)][0] // null
          ),
          worktree: $worktree,
          agents: [
            $agents.result.agents[]
            | select(.workspace_id == $worktree.open_workspace_id)
          ]
        }
    ]
  }'
