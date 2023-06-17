#!/bin/bash
set -Eeuxo pipefail

# first run link.sh!

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
<"$XDG_CONFIG_HOME/npm/packages.txt" xargs -n1 npm -g install
<"$XDG_CONFIG_HOME/cargo/cargo.txt" xargs -n1 cargo install
<"$XDG_CONFIG_HOME/luarocks/luarocks.txt" xargs -n1 luarocks install

# random mac settings {{{

# allow key-repeat
defaults write -g ApplePressAndHoldEnabled -bool false

# automatically hide the dock when not hovering over
defaults write com.apple.dock "autohide" -bool "true"

# don't rearrange spaces based on use
defaults write com.apple.dock "mru-spaces" -bool "false"

# show file extensions in finder
defaults write NSGlobalDomain "AppleShowAllExtensions" -bool "true"

# show hidden dotfiles
defaults write com.apple.Finder "AppleShowAllFiles" -bool "true"

# don't warn whenever I change file extensions
defaults write com.apple.finder "FXEnableExtensionChangeWarning" -bool "false"

# }}}
