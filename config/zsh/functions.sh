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

# cd to repo in dev/
dev () {
    local root_path repo_paths repo_path venv_path repo_basename open_tabs existing_tab_index current_tab
    open_tabs="$(wezterm cli list --format json | jq '.[] | "\(.cwd) \(.pane_id)"')"
    root_path="${PROJECT_ROOT:-$HOME/dev}"
    repo_paths=$(find "$root_path" -mindepth 1 -maxdepth 1 -type d)
    out=$(fzf --expect=ctrl-t <<< "$repo_paths")
    [[ -z "$out" ]] && return

    key=$(sed -n 1p <<< "$out")
    repo_path=$(sed -n 2p <<< "$out")

    if [[ -n "$repo_path" ]]; then

        repo_basename=$(basename "$repo_path")

        # if the chosen repo already has a tab and the user didn't explicitly
        # ask for a new tab via "ctrl-t", switch to the existing tab
        existing_tab_index=$(awk -v REPO="$repo_basename" '$1 == REPO { print $2 }' <<< "$open_tabs")
        if [[ -n "$existing_tab_index" && "$key" != "ctrl-t" ]]; then
            wezterm cli activate-pane --pane-id "$existing_tab_index"
            wezterm kill-pane
            return
        fi

        cd "$repo_path" || return

        # set tab title
        wezterm cli set-tab-title "$repo_basename" 2>/dev/null

        # overwrite the venv path if .venv is used, default in poetry
        # venv_path='venv'
        # [ -d ".venv" ] && venv_path='.venv'

        # deactivate 2>/dev/null  # deactivate python venv
        # shellcheck disable=SC1090
        # source "$venv_path/bin/activate" 2>/dev/null || true  # activate new python venv
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
    rsync --archive --progress --filter=":- .gitignore" --filter="- .git/" "$1" "$2"
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

sgs () {
    /opt/homebrew/bin/src search -stream -json "$@" | jq -c 'select(.repository != null) | { repo: .repository, match: .chunkMatches[]?.content, path: .path}'
}

pjq () {
    if [[ -z $1 ]] || [[ $1 == "-" ]]; then
        input=$(mktemp)
        trap 'rm -f $input' EXIT
        cat /dev/stdin > "$input"
    else
        input=$1
    fi

    echo '' \
        | fzf --phony \
              --preview-window='up:90%' \
              --print-query \
              --preview "jq --color-output -r {q} $input"
}

nmapm () {
    sudo nmap -sn "$@" -oX - | xq -r '
    .nmaprun.host[].address
    | select(type == "array")
    | map({(."@addrtype"): ."@addr", vendor: ."@vendor"})
    | add
    | "\(.ipv4)\t\(.mac)\t\(.vendor)"'
}

function lz() {
    filename="$HOME/dev/repos.txt"
    if [[ ! -f "$filename" || $(find "$filename" -mtime +30) ]]; then
        echo "Refreshing repos list"
        echo "" > "$filename"
        orgs=("gretelai" "gretellabs")
        for repo in "${orgs[@]}"; do
            gh repo list "$repo" --json nameWithOwner,name,sshUrl --jq '.[] | [.nameWithOwner, .name, .sshUrl] | @tsv' >> "$filename"
        done
    fi
    out=$(fzf --with-nth 1 < "$filename")
    [[ -z "$out" ]] && return

    IFS=$'\t' read -r nameWithOwner repo sshUrl <<< "$out"
    if [[ -d "$HOME/dev/$repo" ]]; then
        cd "$HOME/dev/$repo"
    else
        cd "$HOME/dev"
        gh repo clone "$nameWithOwner"
        cd "$repo"
    fi

}

function jvenv() {
    uv pip install --resolution highest jupyter ipykernel ipdb notebook jupyterlab-vim jupyterlab-code-formatter ruff pynvim
    uv run python -m ipykernel install --user --name=$(basename "$PWD")_venv
}

function lc() {
    local cmd
    cmd=$(fc -ln -50 | awk '!/lc/' | fzf --tac)
    [ -n "$cmd" ] && echo -n "$cmd" | sed 's/\\n/\\\n/g' | pbcopy
}

function y() {
	local tmp="$(mktemp -t "yazi-cwd.XXXXXX")" cwd
	yazi "$@" --cwd-file="$tmp"
	if cwd="$(command cat -- "$tmp")" && [ -n "$cwd" ] && [ "$cwd" != "$PWD" ]; then
		builtin cd -- "$cwd"
	fi
	rm -f -- "$tmp"
}

function fzf_ctrl_t_cmd() {
    local type="${1:-files}"  # Default to 'files' if no argument provided
    
    if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
        # Outside a git repo - use the default find command
        if [[ "$type" == "files" ]]; then
            fd --type f
        else
            fd --type d --hidden --exclude .git
        fi
        return
    fi
    
    # If we reach here, we're inside a git repo
    local git_root=$(git rev-parse --show-toplevel)
    local pwd_path=$(pwd)
    
    if [[ "$type" == "files" ]]; then
        # List files in git repo
        git ls-files --cached --others --exclude-standard | while read -r file; do
            local abs_path="${git_root}/${file}"
            local rel_path=$(realpath --relative-to="$pwd_path" "$abs_path")
            echo -e "${abs_path}\t${rel_path}"
        done
    elif [[ "$type" == "dirs" ]]; then
        # List directories in git repo
        git ls-files --cached --others --exclude-standard | 
            xargs -I{} dirname {} | 
            sort -u | 
            while read -r dir; do
                # Skip the root directory (which shows up as ".")
                if [[ "$dir" == "." ]]; then
                    continue
                fi
                
                local abs_path="${git_root}/${dir}"
                local rel_path=$(realpath --relative-to="$pwd_path" "$abs_path")
                echo -e "${abs_path}\t${rel_path}"
            done
    fi
}

function gl() {

    local git_root=$(git rev-parse --show-toplevel 2>/dev/null)
    
    if [[ -z "$git_root" ]]; then
        echo "Not in a git repository"
        return 1
    fi
    
    # Use rg to list directories, respecting gitignore
    # --files lists files
    # --null uses null character as separator
    # --hidden includes hidden directories
    # xargs -0 processes null-delimited input
    # dirname gets the directory paths
    # sort -u sorts and removes duplicates
    local selected_dir=$(cd "$git_root" && 
                        rg --files --null --hidden |
                        xargs -0 dirname |
                        sort -u |
                        fzf --height 40% --reverse --header="Select directory to navigate to:")
    
    if [[ -n "$selected_dir" ]]; then
        cd "$git_root/$selected_dir"
    fi

}

gg() {
    local git_root
    git_root=$(git rev-parse --show-toplevel 2>/dev/null)
    if [[ $? -eq 0 ]]; then
        cd "$git_root"
    fi
}

function y() {
	local tmp="$(mktemp -t "yazi-cwd.XXXXXX")" cwd
	command yazi "$@" --cwd-file="$tmp"
	IFS= read -r -d '' cwd < "$tmp"
	[ -n "$cwd" ] && [ "$cwd" != "$PWD" ] && builtin cd -- "$cwd"
	rm -f -- "$tmp"
}

alias kgpu='kubectl view-allocations -r nvidia.com/gpu'
alias ls="ls -AGltr"
alias dotf='cd $HOME/dotfiles; wezterm cli set-tab-title "dotfiles" 2>/dev/null'
alias g="git"

alias vim='nvim'
alias k='kubectl'
alias icat="kitty +kitten icat"
alias rn='ranger --choosedir=$HOME/.rangerdir; LASTDIR=`cat $HOME/.rangerdir`; cd "$LASTDIR"'
