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
compinit -u
# End of lines added by compinstall

alias ls="ls -G"
alias dot="cd $HOME/dotfiles"
export EDITOR='/usr/local/bin/vim'

setopt CLOBBER

# color options
BASE16_SHELL=$HOME/.config/base16-shell/
[ -n "$PS1"  ] && [ -s $BASE16_SHELL/profile_helper.sh  ] && eval "$($BASE16_SHELL/profile_helper.sh)"
base16_default-dark

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
export FZF_DEFAULT_OPTS="--exact --multi --ansi"
export FZF_CTRL_R_OPTS="--sort"

# Modified version where you can press
#   - CTRL-O to open with `open` command,
#   - CTRL-E or Enter key to open with the $EDITOR
fo() {
  local out file key
  out=$(fzf-tmux --query="$1" --exit-0 --expect=ctrl-o,ctrl-e)
  key=$(head -1 <<< "$out")
  file=$(head -2 <<< "$out" | tail -1)
  if [ -n "$file" ]; then
    [ "$key" = ctrl-o ] && open "$file" || ${EDITOR} "$file"
  fi
}

gpr() {
    local last_commit=$(git log -1 --pretty=%B)
    gpc && hub pull-request -o -m "$last_commit" | pbcopy
}

tbr() {
    tmux rename-window "$(git-branch-current)"
}

tco () {
    git checkout "$(tmux display-message -p '#W')"
}

export PATH="/usr/local/sbin:$PATH"

if [ -f ~/.lyftrc  ]; then
    source ~/.lyftrc
    source '/Users/matthewgrossman/src/blessclient/lyftprofile' # bless ssh alias
fi
