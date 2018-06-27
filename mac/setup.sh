#!/bin/bash

# need xcode to do anything fun on macs
xcode-select --install

# install homebrew and all programs in mac/Brewfile
/usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
brew tap homebrew/bundle
brew bundle
rehash

# change shell to zsh
which zsh | sudo tee -a /etc/shells
chsh -s $(which zsh)

# link hammerspoon data
defaults write org.hammerspoon.Hammerspoon MJConfigFile "$HOME/.config/hammerspoon/init.lua"

# reload ZSH now that setup is done
source ~/.zshrc

# install non-brew deps
pip install -r $HOME/.config/pip/requirements.txt
sh /$HOME/.config/node/node.sh
