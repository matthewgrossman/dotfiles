#!/bin/bash
set -Eeuo pipefail

BACKUP_DIR="$HOME/dotfiles/link.bak"

# Function to create a symbolic link, backing up existing files
symlink() {
    local source="$1"
    local target="$2"

    if [ "$(readlink "$target" 2>/dev/null)" = "$source" ]; then
        echo "Symlink already exists: $target -> $source"
        return
    fi

    # Back up existing file
    if [ -e "$target" ] && [ ! -L "$target" ]; then
        local backup_path="$BACKUP_DIR/${target#$HOME/}"
        mkdir -p "$(dirname "$backup_path")"
        mv "$target" "$backup_path"
        echo "Backed up: $target -> $backup_path"
    fi

    ln -sfn "$source" "$target"
    echo "Created symlink: $target -> $source"
}
export -f symlink
export BACKUP_DIR

cd "$HOME/dotfiles/config" || exit 1

# zsh doesn't follow XDG standards
symlink $HOME/dotfiles/config/zsh/.zshenv $HOME/.zshenv

# Symlink individual files (not directories) so apps can create their own state dirs
cd "$HOME/dotfiles/config" && git ls-files | while read -r file; do
  target_dir="$HOME/.config/$(dirname "$file")"

  # If target_dir is a symlink, remove it so we can create a real directory
  if [ -L "$target_dir" ]; then
    echo "Removing directory symlink: $target_dir"
    rm "$target_dir"
  fi

  mkdir -p "$target_dir"
  symlink "$HOME/dotfiles/config/$file" "$HOME/.config/$file"
done
