#!/usr/bin/env zsh
set -Eeuxo pipefail

# Homebrew (for GUI casks/mas) and Determinate Nix are prerequisites.
bash "$HOME/dotfiles/link.sh"

if command -v darwin-rebuild >/dev/null 2>&1; then
    sudo -H darwin-rebuild switch --flake "$HOME/dotfiles#mac"
else
    sudo -H nix run nix-darwin/master#darwin-rebuild -- switch --flake "$HOME/dotfiles#mac"
fi
