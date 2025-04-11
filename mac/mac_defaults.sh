#!/usr/bin/env zsh
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

# default to the list view in Finder
defaults write com.apple.finder "FXPreferredViewStyle" -string "Nlsv"

# enable tap-to-click
defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad Clicking -bool true
defaults write com.apple.AppleMultitouchTrackpad Clicking -bool true
defaults -currentHost write NSGlobalDomain com.apple.mouse.tapBehavior -int 1
defaults write NSGlobalDomain com.apple.mouse.tapBehavior -int 1

# enable four-finger-down to show all windows for an app
defaults write com.apple.dock showAppExposeGestureEnabled -bool true

# show the path bar at the bottom
defaults write com.apple.finder "ShowPathbar" -bool "true"

# spaces span multiple spaces
defaults write com.apple.spaces "spans-displays" -bool "true"

# make activity monitor update more frequently
defaults write com.apple.ActivityMonitor "UpdatePeriod" -int "1"

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

killall Finder
killall Dock
killall SystemUIServer

# }}}
