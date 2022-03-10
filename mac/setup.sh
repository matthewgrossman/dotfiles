#!/bin/bash

# first run link.sh!

# need xcode to do anything fun on macs
xcode-select --install

# install homebrew and all programs in mac/Brewfile
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
eval "$(/opt/homebrew/bin/brew shellenv)"
brew bundle
rehash

# link hammerspoon data
defaults write org.hammerspoon.Hammerspoon MJConfigFile "$HOME/.config/hammerspoon/init.lua"

# reload ZSH now that setup is done
source ~/.zshrc

# install non-brew deps
<"$XDG_CONFIG_HOME/pip/requirements.txt" xargs -n1 pipx install
