#!/usr/bin/env zsh

# export KITTY_DEVELOP_FROM="$HOME/src/kitty"
export SHELL="$(which zsh)" # wtf??? wezterm????
# uncomment this and `zprof` at the bottom to profile zsh startup
# zmodload zsh/zprof

# put completions in .zfunc
fpath+="$HOME/.zfunc"
autoload -Uz compinit
for dump in ~/.zcompdump(N.mh+24); do
  compinit
done
compinit -C

if [[ "$(uname)" == "Linux" ]]; then
    # linux via `apt`
    HOMEBREW_PREFIX="/usr"
    source /usr/share/doc/fzf/examples/key-bindings.zsh
    source /usr/share/doc/fzf/examples/completion.zsh
    eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
    alias ls='ls --color=auto'
    if [[ -n "WSL_DISTRO_NAME" ]]; then
        source $XDG_CONFIG_HOME/zsh/wsl.zsh
    fi
else
    # macs
    HOMEBREW_PREFIX="/opt/homebrew"
fi

export WORDCHARS=${WORDCHARS/\/}
# export PYTHONBREAKPOINT="ipdb.set_trace"
export PYTHONBREAKPOINT=pdbp.set_trace
export GOPATH=$HOME/dev

# only modify PATH if we aren't in a nvim subshell
if [ -z "$NVIM" ]; then
    export PATH="/opt/homebrew/bin:$PATH"
    export PATH="/usr/local/sbin:$PATH"
    export PATH="$HOME/.krew/bin:$PATH"
    export PATH="$HOME/.cargo/bin:$PATH"
    export PATH="$HOME/.local/bin:$PATH"
    export PATH="$GOPATH/bin:$PATH"
    export PATH="$HOME/bin:$PATH"
    export PATH="/usr/local/opt/llvm/bin:$PATH"
    export PATH="$HOMEBREW_PREFIX/opt/gnu-tar/libexec/gnubin:$PATH"

    # when in nvim, VISUAL is overriden by nvr instead
    export VISUAL="$(which nvim)"
fi

if command -v direnv > /dev/null; then
    eval "$(direnv hook zsh)"
fi

HISTSIZE=10000000
SAVEHIST=10000000
export HISTFILE="$ZDOTDIR/zsh_history"

# Backup history every 10 minutes, keep last 3 days
backup_stamp="$(date +%Y%m%d%H)$((10#$(date +%M) / 10))"
if [[ ! -f "$ZDOTDIR/zsh_history.backup.$backup_stamp" ]]; then
    cp "$ZDOTDIR/zsh_history" "$ZDOTDIR/zsh_history.backup.$backup_stamp" 2>/dev/null
    find "$ZDOTDIR" -name "zsh_history.backup.*" -mtime +3 -delete 2>/dev/null &!
fi

# Keep history append-only across concurrent shells.
setopt APPEND_HISTORY
setopt INC_APPEND_HISTORY
setopt HIST_FCNTL_LOCK
setopt HIST_EXPIRE_DUPS_FIRST
setopt HIST_IGNORE_DUPS
setopt HIST_FIND_NO_DUPS

setopt autocd extendedglob
setopt CLOBBER
# Import history from a file into this shell without rewriting HISTFILE.
histload() {
  local source_file="${1:-$HISTFILE}"
  fc -RI "$source_file"
}

# Dump this shell's in-memory history to a separate file by default.
histdump() {
  local target="${1:-$ZDOTDIR/zsh_history.dump.$(date +%Y%m%d%H%M%S)}"
  fc -W "$target"
  print -r -- "$target"
}

# Replace the main history file with a known-good backup, keeping a rollback copy.
histrestoremain() {
  local source_file="$1"
  if [[ -z "$source_file" ]]; then
    print -u2 -- "usage: histrestoremain <history-file>"
    return 1
  fi

  local rollback="$ZDOTDIR/zsh_history.backup.$(date +%Y%m%d%H%M%S).pre_restore"
  histdump >/dev/null || return 1
  cp "$HISTFILE" "$rollback" || return 1
  cp "$source_file" "$HISTFILE" || return 1
  fc -p "$HISTFILE" "$HISTSIZE" "$SAVEHIST"
  fc -R "$HISTFILE"
  print -r -- "restored $HISTFILE from $source_file"
  print -r -- "rollback saved to $rollback"
}
bindkey -e

source <(fzf --zsh)

if [ -d "$HOME/.kube"  ]; then
    kubeconfigs=$(find "$HOME/.kube" -maxdepth 1 -type f | paste -sd ':' -)
    export KUBECONFIG="$KUBECONFIG:$kubeconfigs"
fi

export RIPGREP_CONFIG_PATH="$XDG_CONFIG_HOME/ripgrep/ripgreprc"
export LLM_USER_PATH="$XDG_CONFIG_HOME/io.datasette.llm"

. $XDG_CONFIG_HOME/zsh/theme.sh
. $XDG_CONFIG_HOME/zsh/functions.sh

export FZF_DEFAULT_OPTS="--ansi --no-height"
export FZF_DEFAULT_COMMAND='rg --files --hidden'
export FZF_CTRL_T_DIR_COMMAND=""
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_CTRL_T_OPTS="--preview 'bat --color=always {}'"
# eval "$(atuin init zsh --disable-ctrl-r)"  # Use atuin for history recording only
# source "$HOME/dotfiles/config/zsh/fzf-atuin.zsh"  # Custom fzf+atuin ctrl-r
# ctrl-y in history search copies command to clipboard
# awk removes leading tabs from continuation lines (fzf adds them for display)
export FZF_CTRL_R_OPTS="--bind 'ctrl-y:execute-silent(echo -n {2..} | awk \"NR>1{sub(/^\t/,\\\"\\\")}1\" | pbcopy)+abort'"

# Wrap fzf-history-widget to fix bracketed paste after fzf exits
fzf-history-widget-wrapper() {
  fzf-history-widget
  printf '\e[?2004h'
}
zle -N fzf-history-widget-wrapper
bindkey -M emacs '^R' fzf-history-widget-wrapper

export DISABLE_AUTOUPDATER=1

# work configuration
if [ -f ~/.workrc  ]; then
    source ~/.workrc
fi
[[ -f ~/dev/workfiles/workfiles.sh ]] && source ~/dev/workfiles/workfiles.sh
source "${HOMEBREW_PREFIX}/share/zsh-autosuggestions/zsh-autosuggestions.zsh"
source "${HOMEBREW_PREFIX}/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
# zprof

. "$HOME/.local/share/../bin/env"

export NVM_DIR="$HOME/.config/nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

if command -v wt >/dev/null 2>&1; then eval "$(command wt config shell init zsh)"; fi

# opencode
export PATH=/Users/mgrossman/.opencode/bin:$PATH
