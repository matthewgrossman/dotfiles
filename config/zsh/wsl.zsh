#!/usr/bin/env zsh

alias shutdown='wsl.exe --terminate $WSL_DISTRO_NAME'
wezterm() {
    wezterm.exe "$@"
}
bindkey "^[[1;5D" backward-word
bindkey "^[[1;5C" forward-word
export BROWSER='cmd.exe /c start ""'

# RUNNING=$(ps aux | grep tailscaled | grep -v grep)
# echo "ableh!"
# echo "$RUNNING"
# if [ -z "$RUNNING" ]; then
#     sudo tailscaled > /dev/null 2>&1 &
#     disown
# fi
