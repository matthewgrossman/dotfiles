#!/usr/bin/env zsh
set -Eeuxo pipefail

# first run link.sh!
. "$HOME/dotfiles/link.sh"

# Check if Xcode Command Line Tools are already installed
if ! xcode-select -p &> /dev/null; then
    echo "Xcode Command Line Tools are not installed. Installing..."
    xcode-select --install
else
    echo "Xcode Command Line Tools are already installed."
fi

# install homebrew and all programs in mac/Brewfile
if ! command -v brew &> /dev/null; then
    echo "Homebrew is not installed. Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
else
    echo "Homebrew is already installed."
fi
eval "$(/opt/homebrew/bin/brew shellenv)"
cd "$HOME/dotfiles/mac"
brew bundle

# install uv
curl -LsSf https://astral.sh/uv/install.sh | sh
uv tool install llm

# link hammerspoon data
defaults write org.hammerspoon.Hammerspoon MJConfigFile "$HOME/.config/hammerspoon/init.lua"

# reload ZSH now that setup is done
zsh "$HOME/.config/zsh/.zshrc"
zsh "$HOME/dotfiles/mac/mac_defaults.sh"
