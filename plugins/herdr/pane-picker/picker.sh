#!/usr/bin/env bash
set -euo pipefail

[[ ${HERDR_ENV:-} == 1 ]] || { echo 'Run this picker inside Herdr' >&2; exit 1; }

if [[ ${1:-} == --list ]]; then
  "${HERDR_BIN_PATH:-herdr}" api snapshot | jq -r --arg mode "${2:-agents}" '
    .result.snapshot as $s
    | ($s.workspaces | map({key: .workspace_id, value: .label}) | from_entries) as $workspaces
    | ($s.tabs | map({key: .tab_id, value: .label}) | from_entries) as $tabs
    | $s.panes | to_entries
    | sort_by([(.value.workspace_id != $s.focused_workspace_id),
               (.value.tab_id != $s.focused_tab_id), .key])
    | .[].value
    | select($mode == "all" or ((.agent // "") != ""))
    | [.pane_id, ([
        $workspaces[.workspace_id], $tabs[.tab_id],
        (.label // .name // .terminal_title_stripped // .terminal_title),
        (.foreground_cwd // .cwd), (.agent // "terminal"), .pane_id
      ] | map(select(. != null and . != "") | tostring
              | gsub("[\u0000-\u001f\u007f-\u009f]"; " ")) | join(" · "))]
    | join("\t")
  '
  exit
fi

# Quote the script path once for fzf's reload commands, even when it has spaces.
printf -v HERDR_PICKER_LIST 'bash %q --list' "$0"
export HERDR_PICKER_LIST
selection=$(
  unset FZF_DEFAULT_OPTS FZF_DEFAULT_OPTS_FILE
  bash "$0" --list agents |
    fzf --no-multi --no-sort --layout=reverse --delimiter=$'\t' --with-nth=2.. \
      --prompt='Agents> ' --header='Ctrl+A: agents/all panes · Enter: copy ID · Esc: cancel' \
      --with-shell='bash -c' --bind='ctrl-a:transform:
        if [ "$FZF_PROMPT" = "Agents> " ]; then
          printf "change-prompt(All panes> )+reload:%s all\n" "$HERDR_PICKER_LIST"
        else
          printf "change-prompt(Agents> )+reload:%s agents\n" "$HERDR_PICKER_LIST"
        fi'
) || exit $?

# Do not launch pbcopy on cancellation: it would clear the existing clipboard.
[[ -n $selection ]] && printf '%s' "${selection%%$'\t'*}" | pbcopy
