git_status() {
    local gstatus=$(git status --short --untracked-files=no)
    [ -n "$gstatus" ] && local status_color='yellow' || local status_color='green'
    local color="%{$bg[${status_color}]%}%{$fg[black]%}"
    local branch=$(git rev-parse --abbrev-ref HEAD)
    echo "${color} ${branch}"
}


setopt prompt_subst
local path_name="%{$bg[blue]%}%{$fg[black]%} %~"
local leading=$'\u00BB'
PROMPT="${path_name} \$(git_status) %{$reset_color%} ${leading} "

