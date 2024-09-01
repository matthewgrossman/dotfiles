#!/bin/bash
set -Eeuxo pipefail

cd "$HOME/dotfiles/config" && git ls-files \
  | awk -F'/' '{print $1}' \
  | sort -u \
  | xargs -I {} ln -sfn "$HOME/dotfiles/config/{}" "$HOME/.config/{}"
