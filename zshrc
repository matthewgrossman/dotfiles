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

alias ls="ls -G"
alias dot="cd $HOME/dotfiles"
export EDITOR='/usr/local/bin/vim'

POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(dir vcs)
POWERLEVEL9K_RIGHT_PROMPT_ELEMENTS=(status time)

# plugins

# TODO: fix mac specific directory for zplug
export ZPLUG_HOME=/usr/local/opt/zplug
source $ZPLUG_HOME/init.zsh

zplug "modules/git", from:prezto
zplug "modules/osx", from:prezto
zplug "modules/history", from:prezto
zplug "modules/utility", from:prezto
zplug "modules/completion", from:prezto
zplug "modules/directory", from:prezto
zplug "bhilburn/powerlevel9k", use:powerlevel9k.zsh-theme
zplug load

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
    source '/Users/matthewgrossman/src/blessclient/lyftprofile' # bless ssh alias
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
