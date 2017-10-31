# Lines configured by zsh
HISTFILE=~/.histfile
HISTSIZE=100000
SAVEHIST=100000
setopt autocd extendedglob
setopt INC_APPEND_HISTORY
setopt CLOBBER
bindkey -e
autoload -Uz compinit
compinit -u
autoload -U colors && colors

alias ls="ls -G"
alias dot="cd $HOME/dotfiles"
alias g="git"
export EDITOR='/usr/local/bin/nvim'

alias vi='nvim'
alias vim='nvim'

# color
BASE16_SHELL=$HOME/.config/base16-shell/
[ -n "$PS1"  ] && [ -s $BASE16_SHELL/profile_helper.sh  ] && eval "$($BASE16_SHELL/profile_helper.sh)"
[ ! -f $HOME/.vimrc_background ] && base16_default-dark

# fzf
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
export FZF_DEFAULT_COMMAND='ag -g ""'
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_DEFAULT_OPTS="--ansi"
export FZF_CTRL_R_OPTS="--sort"

# lyft
if [ -f ~/.lyftrc  ]; then
    source ~/.lyftrc
    source '/Users/mgrossman/src/blessclient/lyftprofile' # bless ssh alias
fi

# custom functions
fo() {
  local out file key
  out=$(fzf-tmux --query="$1" --exit-0 --expect=ctrl-o,ctrl-e)
  key=$(head -1 <<< "$out")
  file=$(head -2 <<< "$out" | tail -1)
  if [ -n "$file" ]; then
    [ "$key" = ctrl-o ] && open "$file" || ${EDITOR} "$file"
  fi
}

# push local branch to remote and create a PR
gpr() {
    local last_commit=$(git log -1 --pretty=%B)
    gpc && hub pull-request -o -m "$last_commit" | pbcopy
}

# checkout recent branches
co() {
    local branches=$(git branch --sort=committerdate | awk '/^[^*]/ {print $1}')
    local branch=$(fzf --tac --no-sort <<< $branches)
    git checkout $branch
}

. $HOME/dotfiles/theme.zsh
