#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "${BASH_SOURCE[0]}")"

# Each entry contains a source repository or local folder followed by its selected skills.
SKILLS=(
  "./skills *"
  "mattpocock/skills grill-me grilling tdd codebase-design"
  "herdrdev/herdr herdr"
  "humanlayer/skills show-me"
  "vercel-labs/open-agents code-review"
)
AGENTS=(claude-code opencode)

for entry in "${SKILLS[@]}"; do
  read -r -a selection <<< "$entry"
  npx skills add "${selection[0]}" \
    --skill "${selection[@]:1}" \
    --global --agent "${AGENTS[@]}" --yes
done

# Install work-specific skills after the shared selection.
if [[ -f "$HOME/dev/workfiles/install-skills.sh" ]]; then
  bash "$HOME/dev/workfiles/install-skills.sh"
fi
