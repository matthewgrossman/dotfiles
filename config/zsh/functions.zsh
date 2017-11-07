# custom functions
fo() {
  local out file key
  out=$(fzf-tmux --query="$1" --exit-0 --expect=ctrl-o,ctrl-e)
  key=$(head -1 <<< "$out")
  file=$(head -2 <<< "$out" | tail -1)
  if [ -n "$file" ]; then
    [ "$key" = ctrl-o ] && open "$file" || ${EDITOR} "$file"
  fi
}

# checkout recent branches
co() {
    local branches=$(git branch --sort=committerdate | awk '/^[^*]/ {print $1}')
    local branch=$(fzf --tac --no-sort <<< $branches)
    git checkout $branch
}
