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
brew bundle

# link hammerspoon data
defaults write org.hammerspoon.Hammerspoon MJConfigFile "$HOME/.config/hammerspoon/init.lua"

# reload ZSH now that setup is done
source ~/.zshrc

# random mac settings {{{
# many of these were taken from these two sources:
# https://github.com/mathiasbynens/dotfiles/blob/main/.macos
# https://github.com/buo/dotfiles/blob/master/osx/_25trackpad.sh

# allow key-repeat and speed it up
defaults write -g ApplePressAndHoldEnabled -bool false
defaults write -g InitialKeyRepeat -int 15 # normal minimum is 15 (225 ms)
defaults write -g KeyRepeat -int 2 # normal minimum is 2 (30 ms)

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

# Enable three finger drag
defaults write com.apple.AppleMultitouchTrackpad TrackpadThreeFingerDrag -bool true
defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad TrackpadThreeFingerDrag -bool true
defaults -currentHost write -g com.apple.trackpad.threeFingerDragGesture -bool true
defaults -currentHost write -g com.apple.trackpad.threeFingerHorizSwipeGesture -int 0
defaults -currentHost write -g com.apple.trackpad.threeFingerVertSwipeGesture -int 0

# }}}
