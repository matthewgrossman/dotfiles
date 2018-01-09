# custom functions
fo() {
  local out file key
  files=$(fzf --query="$1" --multi --exit-0)
  if [ -n "$files" ]; then
      nvim -o $(tr '\n' ' ' <<< $files)
  fi
}

# checkout recent branches
co() {
    local branches=$(git branch --sort=committerdate | awk '/^[^*]/ {print $1}')
    local branch=$(fzf --tac --no-sort <<< $branches)
    git checkout $branch
}
