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
    fswatch \
    net-tools \
    ansible \
    nmap \

chsh --shell /usr/bin/zsh

# install linuxbrew, https://brew.sh
NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
brew install luarocks
brew install lua-language-server
brew install neovim
brew install node
brew install go
brew install gh
brew install reorder-python-imports
brew install poetry
brew install neovim-remote
<"$HOME/.config/luarocks/luarocks.txt" xargs -n1 luarocks install

# python
python3 -m pip install --user pynvim

# overwrite wsl.conf ? commented out because might cause problems
# sudo ln -sf "$HOME/dotfiles/wsl/wsl.conf" /etc/wsl.conf
# install powertoys, disable the double-tap control thing
