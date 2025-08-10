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
unsetopt SHARE_HISTORY
setopt autocd extendedglob
setopt INC_APPEND_HISTORY
setopt HIST_EXPIRE_DUPS_FIRST
setopt CLOBBER
alias hist="fc -RI"
bindkey -e

# fzf
source <(fzf --zsh)
export FZF_DEFAULT_OPTS="--ansi --no-height"
export FZF_DEFAULT_COMMAND='rg --files --hidden'
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_CTRL_T_OPTS="--preview 'bat --color=always {}'"

if [ -d "$HOME/.kube"  ]; then
    kubeconfigs=$(find "$HOME/.kube" -maxdepth 1 -type f | paste -sd ':' -)
    export KUBECONFIG="$KUBECONFIG:$kubeconfigs"
fi

export RIPGREP_CONFIG_PATH="$XDG_CONFIG_HOME/ripgrep/ripgreprc"
export LLM_USER_PATH="$XDG_CONFIG_HOME/io.datasette.llm"

. $XDG_CONFIG_HOME/zsh/alias.sh
. $XDG_CONFIG_HOME/zsh/theme.sh
. $XDG_CONFIG_HOME/zsh/functions.sh

# work configuration
if [ -f ~/.workrc  ]; then
    source ~/.workrc
fi
source "${HOMEBREW_PREFIX}/share/zsh-autosuggestions/zsh-autosuggestions.zsh"
source "${HOMEBREW_PREFIX}/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
# zprof

. "$HOME/.local/share/../bin/env"
