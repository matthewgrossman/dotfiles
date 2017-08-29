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
    local gstatus=$(git status --short --untracked-files=no)
    [ -n "$gstatus" ] && local status_color='yellow' || local status_color='green'
    local branch=$(git rev-parse --abbrev-ref HEAD)
    zc $branch 'black' $status_color
}

setopt prompt_subst
local path_name=$(zc '%~' 'black' 'blue')
local leading=$'\u00BB'
PROMPT="${path_name}\$(git_status) ${leading} "