#!/usr/bin/env zsh

autoload -U colors && colors

# set the reset_color back to defaults
reset_color="%{$bg[default]%}%{$fg[default]%}"

# function to colorize text
zc(){
    # print -P $(zc 'hello world' 'red' 'white')
    local text=$1  # text to colorize
    local cfg=$2  # foreground color
    local cbg=$3  # background color

    local colors="%{$bg[${cbg}]%}%{$fg[${cfg}]%}"
    echo "${colors} ${text} ${reset_color}"
}

# return git branch, yellow bg if there are diffs, green bg if there aren't
git_status() {
    local branch status_color

    if branch=$(git rev-parse --abbrev-ref HEAD 2>/dev/null); then
        if [[ $(git status --short --untracked-files=no) ]]; then
            status_color='yellow'
        else
            status_color='green'
        fi
        zc "$branch" 'black' "$status_color"
    fi
}

# return current k8s cluster:namespace
kube_status() {
    local current_context jsonpath cluster_namespace
    if current_context=$(kubectl config current-context 2> /dev/null); then
        jsonpath="{.contexts[?(@.name=='$current_context')].context['cluster', 'namespace']}"
        cluster_namespace=$(kubectl config view --output jsonpath="$jsonpath" | awk '{print $1 ":" $2}')
        zc "$cluster_namespace" 'black' 'magenta'
    fi
}

setopt prompt_subst
path_name=$(zc '%~' 'black' 'blue')
leading=$'\u00BB'
osc=$(printf "\033]133;A\007")
export PROMPT="${osc}${path_name}\$(git_status) ${leading} "
