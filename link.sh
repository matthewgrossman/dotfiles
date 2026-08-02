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
        local backup_path="$BACKUP_DIR/${target#"$HOME"/}"
        local backup_index=1

        while [ -e "$backup_path" ] || [ -L "$backup_path" ]; do
            backup_path="$BACKUP_DIR/${target#"$HOME"/}.$backup_index"
            backup_index=$((backup_index + 1))
        done

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

# These applications write generated data alongside their configuration, so
# keep their destination directories real and link only tracked files.
FILE_LINK_DIRS=(
    git
    herdr
    opencode
    zed
    zsh
)

uses_file_links() {
    local directory="$1"
    local exception

    for exception in "${FILE_LINK_DIRS[@]}"; do
        if [ "$directory" = "$exception" ]; then
            return 0
        fi
    done

    return 1
}

# zsh doesn't follow XDG standards
symlink "$HOME/dotfiles/config/zsh/.zshenv" "$HOME/.zshenv"

# Link complete application config directories by default.
for source_dir in "$HOME"/dotfiles/config/*/; do
    directory="$(basename "$source_dir")"

    if uses_file_links "$directory"; then
        continue
    fi

    symlink "${source_dir%/}" "$HOME/.config/$directory"
done

# Link tracked files individually for applications that mix generated data
# into their config directories. Top-level files are also linked individually.
git ls-files | while read -r file; do
    if [[ "$file" == */* ]]; then
        directory="${file%%/*}"

        if ! uses_file_links "$directory"; then
            continue
        fi
    fi

    target_dir="$HOME/.config/$(dirname "$file")"

    # If target_dir is a symlink, remove it so we can create a real directory.
    if [ -L "$target_dir" ]; then
        echo "Removing directory symlink: $target_dir"
        rm "$target_dir"
    fi

    mkdir -p "$target_dir"
    symlink "$HOME/dotfiles/config/$file" "$HOME/.config/$file"
done
