#!/usr/bin/env bash
# Vendored from paulbkim-dev/vim-herdr-navigation at commit 820d48f5d9c.
# Adapted to run as a Herdr `type = "shell"` keybinding, which provides
# HERDR_ACTIVE_PANE_ID, rather than as an installed plugin action.

set -euo pipefail

dir="${1:?usage: vim-herdr-navigation.sh <left|down|up|right>}"
herdr="${HERDR_BIN_PATH:-herdr}"
pane="${HERDR_ACTIVE_PANE_ID:-${HERDR_PANE_ID:-}}"

case "$dir" in
  left) key="ctrl+h" ;;
  down) key="ctrl+j" ;;
  up) key="ctrl+k" ;;
  right) key="ctrl+l" ;;
  *) echo "unknown direction: $dir" >&2; exit 2 ;;
esac

# Match vi, vim, nvim, view, gvim, and their diff variants.
vim_re='^g?(view|l?n?vim?x?)(diff)?$'
passthrough_re="${HERDR_NAV_PASSTHROUGH_RE:-}"
forward=0

if [[ -n "$pane" ]] && command -v jq >/dev/null 2>&1; then
  if "$herdr" pane process-info --pane "$pane" 2>/dev/null \
    | jq -e --arg vim "$vim_re" --arg pass "$passthrough_re" \
        '.result.process_info.foreground_processes[]?.name
         | ascii_downcase
         | select(test($vim) or ($pass != "" and (try test($pass) catch false)))' \
        >/dev/null 2>&1; then
    forward=1
  fi
fi

if [[ "$forward" -eq 1 ]]; then
  exec "$herdr" pane send-keys "$pane" "$key"
elif [[ -n "$pane" ]]; then
  exec "$herdr" pane focus --direction "$dir" --pane "$pane"
else
  exec "$herdr" pane focus --direction "$dir" --current
fi
