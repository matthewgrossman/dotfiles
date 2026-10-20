# Herdr session titles

One client-side OpenCode plugin: `tui.ts`. It reads the terminal's Herdr context
and updates the actual session title to `project:worktree:tab`, also visible in
the web UI. No launcher, shell wrapper, custom RPC, or server plugin.

Enabled in `~/.config/opencode/cli.json` alongside the existing Herdr integration.
Loads automatically when OpenCode starts. Handles both new instances and `/new`.
Only root sessions created since this client started are named; resumed sessions,
forks, subagents, and non-Herdr clients are left alone.

The plugin waits for OpenCode's initial title, then replaces it once (avoiding an
in-flight AI title overwriting the Herdr name). It does not synchronize subsequent
tab renames or overwrite later manual session renames.

Project is Herdr's repository name; worktree is the linked workspace's label, or
`main` for the main checkout. Example: `dotfiles:main:opencode-name`.

```sh
bun test plugins/opencode/herdr-title/tui.test.ts
```
