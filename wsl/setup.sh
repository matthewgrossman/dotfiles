#!/bin/bash


# install linuxbrew, https://brew.sh
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

sudo apt install -y \
    zsh \
    zsh-autosuggestions \
    zsh-syntax-highlighting

sudo chsh --shell /usr/bin/zsh

sudo apt install clang
sudo apt install gcc
sudo apt install make
sudo apt install universal-ctags
sudo apt install -y \
    fzf \
    pipx \
    universal-ctags \
    ranger \
    ripgrep \
    luarocks \

<"$XDG_CONFIG_HOME/luarocks/luarocks.txt" xargs -n1 luarocks install

sudo add-apt-repository ppa:neovim-ppa/stable
sudo apt update
sudo apt install neovim

# somethings easier via brew
brew install luarocks
brew install lua-language-server
