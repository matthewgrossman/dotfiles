# Automatic Herdr agent aliases

Trailing `_` means **automatically managed**: `openshell-test-runner_`.
Agents without aliases receive one; aliases ending in `_` are recomputed from
the current workspace/tab labels. All other aliases are left alone, including
existing Spork names. Remove the trailing `_` to take manual control.

There is no ownership database or cache. Herdr's current snapshot is the source
of truth. When labels collide (including multiple agents in one tab), the full
pane ID disambiguates them: `openshell-test-runner-w41-p3_`. Names are normalized
to Herdr's alphabet and 32-character limit, retaining the trailing marker.

Startup and event hooks handle detection, workspace/tab renames, pane moves and
closures, and tab moves. Only actual naming changes make rename calls. Overlapping
hooks are serialized with an inode lock on the script itself; no lock/state file
is created. Temporary aliases also end in `_`, so an interrupted update can be
repaired by the next sync. Explicit renames are rechecked before applying changes
(Herdr has no atomic compare-and-rename, so concurrent external edits can race).

Requires Python 3 on macOS/Linux. Preview before enabling:

```sh
python3 -B plugins/herdr/auto-alias/sync_aliases.py
herdr plugin link ~/dotfiles/plugins/herdr/auto-alias
herdr server reload-config
```

The **Synchronize automatic agent aliases** action also runs a sync on demand.
Clearing an alias makes it eligible again at the next sync. Disabling the plugin
stops synchronization but leaves existing aliases in Herdr.

```sh
python3 -B -m unittest discover -s plugins/herdr/auto-alias
```
