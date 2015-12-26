# Lines configured by zsh-newuser-install
HISTFILE=~/.histfile
HISTSIZE=1000
SAVEHIST=1000
setopt autocd extendedglob
bindkey -e
# End of lines configured by zsh-newuser-install
# The following lines were added by compinstall
zstyle :compinstall filename '/Users/matthewgrossman/.zshrc'

autoload -Uz compinit
compinit
# End of lines added by compinstall

alias ls="ls -G"
