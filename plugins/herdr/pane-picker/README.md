# Herdr pane reference picker

Press **Ctrl+/ then F**, fuzzy-find a pane, and press **Enter** to insert
`herdr <pane-id>` (e.g. `herdr w2G:p1`) into the pane that opened the picker,
without submitting it. **Ctrl+Y** copies the same text to the macOS clipboard
instead. Escape cancels without typing or changing the clipboard. The popup
closes after selection.

Search matches workspace/tab names, pane titles, directories, agent types, and
IDs. **Agents-only is the default. Ctrl+A toggles between agents and all panes**,
including ordinary terminals and the pane you're currently in. The prompt shows
the current mode; toggling preserves your query. Each toggle reloads a fresh
`herdr api snapshot` through `jq`. No temporary files are needed.
The picker never reads messages, calls OpenCode, or submits prompts. Insertion
uses `herdr pane send-text`, so the original pane should be at an input prompt.
No agent integrations are required.

With an empty query, panes in the current tab appear first, followed by other
tabs in the current workspace, then other workspaces. Typing ranks results by
fuzzy-match quality; equal-score matches retain that locality ordering.

## Setup

Requires macOS, Herdr 0.9.1+, Bash, `jq`, and `fzf` on PATH.

```sh
herdr plugin link ~/dotfiles/plugins/herdr/pane-picker
herdr server reload-config
```

`config/herdr/config.toml` binds `prefix+f` to `local.pane-picker.open`.
The **Ctrl+/ then Y** shortcut still copies the current pane's ID directly.

## Tests

```sh
cd ~/dotfiles/plugins/herdr/pane-picker
PYTHONDONTWRITEBYTECODE=1 python3 -m unittest -v
```

Python 3 is only needed to run tests. Tests execute the Bash script with mocked
Herdr, fzf, and clipboard commands; they don't change your clipboard or send
input to real panes.
