#!/usr/bin/env bash

# open files
fo() {
    local files
    IFS=$'\n' files=( $(fzf --query="$1" --multi --exit-0 --preview 'bat --color=always {}') )
    if [ "${#files}" -ne 0 ]; then
        $EDITOR "${files[@]}"
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

_fzf_complete_git() {
    local branches
    if [ "$*" = "git co " ]; then
        echo "inside"
        branches=$(git branch --sort=committerdate | awk '/^[^*]/ {print $1}')
        _fzf_complete "--tac --no-sort" "$*" < <(echo "$branches")
    fi
}
