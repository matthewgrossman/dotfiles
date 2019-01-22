# custom functions
fo() {
  local out file key
  files=$(fzf --query="$1" --multi --exit-0)
  if [ -n "$files" ]; then
      $EDITOR -o $(tr '\n' ' ' <<< $files)
  fi
}

# checkout recent branches
co() {
    local branches=$(git branch --sort=committerdate | awk '/^[^*]/ {print $1}')
    local branch=$(fzf --tac --no-sort <<< $branches)
    git checkout $branch
}

# attach to abduco session
ab() {
  [[ $1 ]] && abduco -c "$1" "$SHELL" || (
    local sessions=$(abduco | tail -n +2 | sed 's/*//' | awk '{print $4}')
    local session=$(fzf --tac --no-sort <<< $sessions)
    abduco -a "$session"
  )
}

# cd to repo in src/
src() {
    local project_root="$HOME/src/"
    local repos=$(ls -ltr "$project_root" | awk '/^d/{print $NF}')
    local repo=$(fzf --tac --no-sort <<< $repos)
    if [[ -n "$repo" ]]
    then
        deactivate 2>/dev/null  # deactivate python venv
        cd "$project_root$repo"
        source venv/bin/activate 2>/dev/null || true  # activate new python venv
    fi
}
