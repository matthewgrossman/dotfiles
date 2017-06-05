#!/bin/sh

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

# base16-shell colors
git clone https://github.com/chriskempson/base16-shell.git ~/.config/base16-shell

# sync iterm2 with config
defaults write com.googlecode.iterm2.plist PrefsCustomFolder -string "$HOME/dotfiles/mac"
defaults write com.googlecode.iterm2.plist LoadPrefsFromCustomFolder -bool true

# reload ZSH now that setup is done
source ~/.zshrc
zplug install
