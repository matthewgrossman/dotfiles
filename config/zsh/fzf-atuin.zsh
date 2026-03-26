# FZF + Atuin integration
# Uses atuin's SQLite database with fzf's UI for better multiline display

# TODO:
# - figure out why some commands like helm aren't showing up in recent history
# - make the time-since-last-run on the left column, maybe with a different color for pass/fail
# - fix adding the bracketed paste mode back in after fzf exits (currently it breaks pasting into the terminal after using ctrl-r)
fzf-atuin-history-widget() {
  local selected

  selected=$(atuin history list --print0 --cmd-only | \
    fzf --read0 --no-sort --tac \
        --prompt 'history (all)> ' \
        --header 'ctrl-g: directory │ ctrl-s: session │ ctrl-a: all │ ctrl-y: copy' \
        --preview 'printf "%s" {}' \
        --preview-window 'down:10:wrap' \
        --bind "ctrl-g:change-prompt(history (cwd)> )+reload(atuin history list --print0 --cmd-only --cwd)" \
        --bind "ctrl-s:change-prompt(history (session)> )+reload(atuin history list --print0 --cmd-only --session)" \
        --bind "ctrl-a:change-prompt(history (all)> )+reload(atuin history list --print0 --cmd-only)" \
        --bind 'ctrl-y:execute-silent(printf "%s" {} | pbcopy)+abort')

  if [[ -n "$selected" ]]; then
    LBUFFER="$selected"
  fi

  zle reset-prompt
}

zle -N fzf-atuin-history-widget
bindkey '^R' fzf-atuin-history-widget
