#!/bin/bash

# install fzf
if [ -f ~/.fzf ] > /dev/null; then
    git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
    ~/.fzf/install
fi

# install ubuntu deps
for dep in "dtach"; do
    command -v "$dep" > /dev/null || sudo apt-get install "$dep"
done

d() {
    if [[ -n "$1" ]]; then
        dtach -A "/tmp/dtach_$1" -e ^b -z bash
    else
        local session=$(ls -l /tmp/dtach_* | awk '{print substr($NF, 12)}' | fzf)
        dtach -A "/tmp/dtach_$session" -e ^b -z bash
    fi
}
