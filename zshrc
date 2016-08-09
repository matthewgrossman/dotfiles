# Lines configured by zsh-newuser-install
HISTFILE=~/.histfile
HISTSIZE=1000
SAVEHIST=1000
setopt autocd extendedglob
bindkey -e
# End of lines configured by zsh-newuser-install
# The following lines were added by compinstall

autoload -Uz compinit
compinit
# End of lines added by compinstall

alias ls="ls -G"
export EDITOR='vim'
source ~/.lyftrc

# load zgen
source "${HOME}/.zgen/zgen.zsh"

# if the init scipt doesn't exist
if ! zgen saved; then

    # prezto options
    zgen prezto editor key-bindings 'emacs'
    zgen prezto prompt theme 'sorin'

    # prezto and modules
    zgen prezto
    zgen prezto git
    zgen prezto command-not-found
    zgen prezto history
    zgen prezto history-substring-search
    zgen prezto syntax-highlighting
    zgen prezto directory
    zgen prezto prompt


    # generate the init script from plugins above
    zgen save
fi

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
let $FZF_DEFAULT_COMMAND = 'ag --hidden --ignore .git -g ""'
