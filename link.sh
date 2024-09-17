#!/bin/bash
set -Eeuo pipefail

# Function to create a symbolic link if it doesn't exist
symlink() {
    local source="$1"
    local target="$2"
    if [ ! -e "$target" ] || [ "$(readlink "$target")" != "$source" ]; then
        ln -sfn "$source" "$target"
        echo "Created symlink: $target -> $source"
    else
        echo "Symlink already exists: $target -> $source"
    fi
}
export -f symlink

cd "$HOME/dotfiles/config" || exit 1

# zsh doesn't follow XDG standards
symlink $HOME/dotfiles/config/zsh/.zshenv $HOME/.zshenv

cd "$HOME/dotfiles/config" && git ls-files \
  | awk -F'/' '{print $1}' \
  | sort -u \
  | xargs -I {} bash -c 'symlink "$HOME/dotfiles/config/{}" "$HOME/.config/{}"'
