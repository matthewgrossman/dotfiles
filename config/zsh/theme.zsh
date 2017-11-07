# background color
BASE16_SHELL=$XDG_CONFIG_HOME/base16-shell/
[ -n "$PS1"  ] && [ -s $BASE16_SHELL/profile_helper.sh  ] && eval "$($BASE16_SHELL/profile_helper.sh)"
[ ! -f $HOME/.vimrc_background ] && base16_default-dark

autoload -U colors && colors

# set the reset_color to black and white
reset_color="%{$bg[black]%}%{$fg[white]%}"

# function to colorize text
zc(){
    # $ zc 'hello world' 'red' 'white'
    local text=$1  # text to colorize
    local cfg=$2  # foreground color
    local cbg=$3  # background color

    local colors="%{$bg[${cbg}]%}%{$fg[${cfg}]%}"
    echo "${colors} ${text} ${reset_color}"
}

# return git branch, yellow bg if there are diffs, green bg if there aren't
git_status() {
    local branch=$(git rev-parse --abbrev-ref HEAD 2>/dev/null)
    if [ "$branch" ]; then
        local gstatus=$(git status --short --untracked-files=no)
        [ -n "$gstatus" ] && local status_color='yellow' || local status_color='green'
        zc $branch 'black' $status_color
    fi
}

setopt prompt_subst
local path_name=$(zc '%~' 'black' 'blue')
local leading=$'\u00BB'
PROMPT="${path_name}\$(git_status) ${leading} "
