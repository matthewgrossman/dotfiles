#!/bin/bash

sudo add-apt-repository -y ppa:neovim-ppa/stable
sudo apt update
sudo apt install -y \
    zsh \
    zsh-autosuggestions \
    zsh-syntax-highlighting \
    fzf \
    universal-ctags \
    ranger \
    ripgrep \
    luarocks \
    shellcheck \
    clang \
    gcc \
    g++ \
    make \
    universal-ctags \
    python3-venv \
    python3-pip \
    golang-go \
    fswatch \
    net-tools \
    neovim

chsh --shell /usr/bin/zsh

# install linuxbrew, https://brew.sh
NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
brew install luarocks
brew install lua-language-server
<"$HOME/.config/luarocks/luarocks.txt" xargs -n1 luarocks install

# pipx
python3 -m pip install --user pipx
python3 -m pip install --user pynvim
pipx ensurepath
pipx install neovim-remote
pipx install ansible-base

# overwrite wsl.conf ? commented out because might cause problems
# sudo ln -sf "$HOME/dotfiles/wsl/wsl.conf" /etc/wsl.conf
# install powertoys, disable the double-tap control thing
