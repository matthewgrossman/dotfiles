#!/bin/sh
/usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
brew tap homebrew/bundle
brew bundle
rehash

# base16-shell
git clone https://github.com/chriskempson/base16-shell.git ~/.config/base16-shell

# vim-plug
curl -fLo ~/.vim/autoload/plug.vim --create-dirs \
        https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim

# powerline fonts
git clone https://github.com/powerline/fonts.git && ./fonts/install.sh && rm -rf fonts
