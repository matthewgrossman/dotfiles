#!/usr/bin/env zsh
set -Eeuxo pipefail

# Link dotfiles using the script's Bash interpreter.
bash "$HOME/dotfiles/link.sh"
zsh "$HOME/dotfiles/mac/mac_defaults.sh"

# Homebrew and its Xcode Command Line Tools dependency are prerequisites.
brew bundle --file="$HOME/dotfiles/mac/Brewfile"

# install uv
curl -LsSf https://astral.sh/uv/install.sh | sh

# install opencode
curl -fsSL https://opencode.ai/install | bash

# link hammerspoon data
defaults write org.hammerspoon.Hammerspoon MJConfigFile "$HOME/.config/hammerspoon/init.lua"

# reload ZSH now that setup is done
zsh "$HOME/.config/zsh/.zshrc"
