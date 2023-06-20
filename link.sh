#!/bin/bash
set -Eeuxo pipefail

# symlink the dotfiles
ln -sfn $HOME/dotfiles/config/ $HOME/.config
ln -sfn $HOME/dotfiles/config/zsh/zshrc $HOME/.zshrc
ln -sfn $HOME/dotfiles/config/zsh/zprofile $HOME/.zprofile
