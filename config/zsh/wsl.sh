#!/usr/bin/env bash

alias shutdown='wsl.exe --terminate $WSL_DISTRO_NAME'

# RUNNING=$(ps aux | grep tailscaled | grep -v grep)
# echo "ableh!"
# echo "$RUNNING"
# if [ -z "$RUNNING" ]; then
#     sudo tailscaled > /dev/null 2>&1 &
#     disown
# fi