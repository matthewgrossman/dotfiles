#!/bin/bash

# scp lyft/onebox.sh ONEBOX-onebox.dev.lyft.net:~/.bash_aliases
# .bashrc automatically sources bash_aliases, which isn't currently being used

# install fzf
if [ ! -d ~/.fzf ]; then
    git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
    ~/.fzf/install
fi
