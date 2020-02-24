#!/usr/bin/env bash

# open files
fo() {
    local files
    IFS=$'\n' files=( $(fzf --query="$1" --multi --exit-0 --preview 'bat --color=always {}') )
    if [ "${#files}" -ne 0 ]; then
        $VISUAL "${files[@]}"
    fi
}

# checkout recent branches
co() {
    local branch branches
    branches=$(git branch --sort=committerdate | awk '/^[^*]/ {print $1}')
    branch=$(fzf --tac --no-sort <<< "$branches")
    [ -n "$branch" ] && git checkout "$branch"
}

# attach to abduco session
ab() {
    if [[ $1 ]]; then
        abduco -c "$1" "$SHELL"
    else
        local session sessions
        sessions=$(abduco | tail -n +2 | sed 's/*//' | awk '{print $4}')
        session=$(fzf --tac --no-sort <<< "$sessions")
        abduco -a "$session"
    fi
}

# cd to repo in src/
src() {
    local root_path repos repo
    root_path="${PROJECT_ROOT:-$HOME/src/}"
    repos=$(find "$root_path" -mindepth 1 -maxdepth 1 -type d -exec basename {} +)
    repo=$(fzf <<< "$repos")
    if [[ -n "$repo" ]]
    then
        deactivate 2>/dev/null  # deactivate python venv
        cd "$root_path$repo" || return

        # shellcheck disable=SC1091
        source "venv/bin/activate" 2>/dev/null || true  # activate new python venv
    fi
}

kc() {
    local context
    context=$(kubectl config get-contexts --output name | fzf)
    if [[ -n "$context" ]]; then
        kubectl config use-context "$context"
    fi
}

kn() {
    local namespace
    namespace=$(kubectl get namespace | awk 'NR>1 {print $1}' | fzf)
    if [[ -n "$namespace" ]]; then
        kubectl config set-context --current --namespace="$namespace"
    fi
}
