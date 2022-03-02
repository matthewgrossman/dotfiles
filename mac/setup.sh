#!/bin/bash

# need xcode to do anything fun on macs
xcode-select --install

# install homebrew and all programs in mac/Brewfile
/usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
brew bundle
rehash

# link hammerspoon data
defaults write org.hammerspoon.Hammerspoon MJConfigFile "$HOME/.config/hammerspoon/init.lua"

# reload ZSH now that setup is done
source ~/.zshrc

# install non-brew deps
<"$XDG_CONFIG_HOME/pip/requirements.txt" xargs -n1 pipx install
