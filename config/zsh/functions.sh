#!/usr/bin/env bash

# split single line into their own lines
splitl () {
    awk '{$1=$1}1' OFS='\n' "$@"
}

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
    local root_path repo_paths repo_path venv_path repo_basename
    root_path="${PROJECT_ROOT:-$HOME/src}"
    repo_paths=$(find "$root_path" -mindepth 1 -maxdepth 1 -type d)
    repo_path=$(fzf <<< "$repo_paths")
    if [[ -n "$repo_path" ]]; then
        cd "$repo_path" || return

        # set kitty's tab title
        repo_basename=$(basename "$repo_path")
        kitty @ set-tab-title "$repo_basename" 2>/dev/null

        # overwrite the venv path if .venv is used, default in poetry
        venv_path='venv'
        [ -d ".venv" ] && venv_path='.venv'

        deactivate 2>/dev/null  # deactivate python venv
        # shellcheck disable=SC1090
        source "$venv_path/bin/activate" 2>/dev/null || true  # activate new python venv
    fi
}

kc() {
    local out key cluster
    out=$(kubectl config get-contexts --output name | fzf --expect=ctrl-t)
    [[ -z "$out" ]] && return

    key=$(sed -n 1p <<< "$out")
    cluster=$(sed -n 2p <<< "$out")
    if [[ "$key" == "ctrl-t" ]]; then
        export KUBE_CLUSTER="$cluster"
    else
        kubectl config use-context "$cluster"
    fi
}

kn() {
    local namespace
    namespace=$(kubectl get namespace --no-headers | awk '{print $1}' | fzf)
    if [[ -n "$namespace" ]]; then
        kubectl config set-context --current --namespace="$namespace"
    fi
}

scratchvenv() {
    python3 -m venv venv
    source venv/bin/activate
    pip install black reorder-python-imports ipdb pynvim
}

_sync_once() {
    rsync --archive --delete --progress --filter=":- .gitignore" --filter="- .git/" "$1" "$2"
}

sync() {
    # $> sync ~/my/local/dir user@remote:~/my/remote/dir
    local src src_trailing_slash dst
    if [ "$#" -eq 1 ]; then
        src='.'
        dst="$1"
    else
        src="$1"
        dst="$2"
    fi
    src_trailing_slash=$(sed 's|[^/]$|&/|' <<< "$src")
    _sync_once "$src_trailing_slash" "$dst"
    fswatch --exclude='.git/' -o "$src" | while read -r; do
        _sync_once "$src_trailing_slash" "$dst"
    done
}

lkssh() {
    # $> lkssh ufo 06a26
    local service sha pod pods
    service="$1"
    sha="${2:0:5}" # grab only first 5 characters of arg $2
    pods=$(lyftkube -e staging -p "$service" get pods)
    pod=$(awk -v sha="$sha" '$3==sha {print $2;exit}' <<< "$pods")
    lyftkube ssh "$pod"
}

deloffloaded() {
    # $> deloffloaded ufo 8fad6
    local service sha deployments
    service="$1"
    sha="${2:0:5}" # grab only first 5 characters of arg $2
    deployments=$(lyftkube -e staging --cluster core-staging-1 kubectl -- -n "$service"-staging get deployments --selector='lyft.net/offloaded-facet=true')
    deployment=$(awk -v sha="$sha" '$1 ~ sha {print $1;exit}' <<< "$deployments")
    [ -z "$deployment" ] && echo "No deployment found for service {$service} and sha {$sha}" && return 1
    lyftkube -e staging --cluster core-staging-1 kubectl -- delete --now -n "$service"-staging deployment/"$deployment"
}

deloff () {
    local service deployment deployments
    service="$1"
    deployments=$(lyftkube -e staging --cluster core-staging-1 kubectl -- -n "$service"-staging get deployments --selector='lyft.net/offloaded-facet=true' | awk 'NR>1 {print $1}')
    deployment=$(fzf --tac --no-sort <<< "$deployments")
    [[ -z "$deployment" ]] && echo 'cancelling offloaded-facet deletion' && return
    lyftkube -e staging --cluster core-staging-1 kubectl -- delete --now -n "$service"-staging deployment/"$deployment"
}
