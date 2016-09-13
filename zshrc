# Lines configured by zsh-newuser-install
HISTFILE=~/.histfile
HISTSIZE=100000
SAVEHIST=100000
setopt autocd extendedglob
setopt INC_APPEND_HISTORY
bindkey -e
# End of lines configured by zsh-newuser-install

# The following lines were added by compinstall
autoload -Uz compinit
compinit
# End of lines added by compinstall

alias ls="ls -G"
export EDITOR='/usr/local/bin/nvim'
source ~/.lyftrc

setopt CLOBBER

BASE16_SHELL=$HOME/.config/base16-shell/
[ -n "$PS1"  ] && [ -s $BASE16_SHELL/profile_helper.sh  ] && eval "$($BASE16_SHELL/profile_helper.sh)"
base16_default-dark
unlink $HOME/.base16_theme

# load zgen
source "${HOME}/.zgen/zgen.zsh"

# if the init scipt doesn't exist
if ! zgen saved; then

    # prezto options
    zgen prezto editor key-bindings 'emacs'

    # prezto and modules
    zgen prezto
    zgen prezto git
    zgen prezto command-not-found
    zgen prezto history
    zgen prezto history-substring-search
    zgen prezto syntax-highlighting
    zgen prezto directory
    zgen prezto prompt

    zgen load bhilburn/powerlevel9k powerlevel9k

    # generate the init script from plugins above
    zgen save
fi

POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(dir vcs)
POWERLEVEL9K_RIGHT_PROMPT_ELEMENTS=(status time)

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
export FZF_DEFAULT_COMMAND='ag -g ""'
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"

# Modified version where you can press
#   - CTRL-O to open with `open` command,
#   - CTRL-E or Enter key to open with the $EDITOR
fo() {
  local out file key
  out=$(fzf-tmux --query="$1" --exit-0 --expect=ctrl-o,ctrl-e)
  key=$(head -1 <<< "$out")
  file=$(head -2 <<< "$out" | tail -1)
  if [ -n "$file" ]; then
    [ "$key" = ctrl-o ] && open "$file" || ${EDITOR:-nvim} "$file"
  fi
}

pr() {
    hub pull-request -o -m "$1" | pbcopy
}

export PATH="/usr/local/sbin:$PATH"
