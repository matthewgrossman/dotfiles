#!/usr/bin/env zsh
set -Eeuxo pipefail

# Homebrew (for GUI casks/mas) and Determinate Nix are prerequisites.
bash "$HOME/dotfiles/link.sh"

if command -v darwin-rebuild >/dev/null 2>&1; then
    sudo -H darwin-rebuild switch --flake "$HOME/dotfiles#mac"
else
    sudo -H nix run nix-darwin/master#darwin-rebuild -- switch --flake "$HOME/dotfiles#mac"
fi

# Optional curl-only tools not managed by Nix.
if ! command -v pi >/dev/null 2>&1; then
    curl -fsSL https://pi.dev/install.sh | sh
fi
