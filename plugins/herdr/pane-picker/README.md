# Herdr pane reference picker

Press **Ctrl+/ then F**, fuzzy-find a pane, and press Enter to copy its ID
(e.g. `w2G:p1`) to the macOS clipboard, without a trailing newline. Escape
cancels without changing the clipboard. The popup closes after selection.

Search matches workspace/tab names, pane titles, directories, agent types, and
IDs. **Agents-only is the default. Ctrl+A toggles between agents and all panes**,
including ordinary terminals and the pane you're currently in. The prompt shows
the current mode; toggling preserves your query. A single `herdr api snapshot` supplies the
list. The picker never reads messages, calls OpenCode, types into panes, or
submits prompts. No agent integrations are required.

Panes in the current tab appear first, followed by other tabs in the current
workspace, then other workspaces. Herdr's original order is preserved within
each group. Typing filters matches without overriding this locality ordering.

## Setup

Requires macOS, Herdr 0.9.1+, Python 3, and `fzf` on PATH.

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

Tests mock the picker and clipboard; they don't change your clipboard or send
input to real panes.
