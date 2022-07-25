#!/bin/bash

sudo apt install clang
sudo apt install make
sudo apt install universal-ctags
sudo add-apt-repository ppa:neovim-ppa/stable
sudo apt update
sudo apt install neovim
sudo apt install -y \
    fzf \
    pipx \
    universal-ctags \
    ranger \
    ripgrep \
    luarocks \
    zsh \
    zsh-autosuggestions \
    zsh-syntax-highlighting

<"$XDG_CONFIG_HOME/luarocks/luarocks.txt" xargs -n1 luarocks install
