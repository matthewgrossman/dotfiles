#!/bin/sh
/usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
brew tap homebrew/bundle
brew bundle
rehash

# install powerline fonts
pip install powerline-status && ./powerline-status/install.sh
