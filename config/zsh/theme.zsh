autoload -U colors && colors

# set the reset_color back to defaults
reset_color="%{$bg[default]%}%{$fg[default]%}"

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
