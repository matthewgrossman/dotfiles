# nvim_agent TODO

Tracking remaining work for the agentic nvim config.

## Syntax Highlighting / Colorscheme

- [x] Debug why Python files don't have syntax highlighting
  - Root cause: nvim 0.12 only bundles 7 parsers (c, lua, markdown, etc.) — no Python
  - Fixed: added arborist.nvim (auto-installs parsers on file open, `prefer_wasm = false`)
  - Added `tree-sitter-cli` to Brewfile for native compilation
- [x] Switched to kanagawa.nvim colorscheme
  - Full terminal palette (0-17), best dim/faint text differentiation
  - `dimInactive = true` for clear split delineation
  - `terminalColors = true` for proper terminal ANSI colors
- [ ] Verify parsers install correctly on first launch

## LSP

- [x] LSP setup — fully native 0.12, zero plugins
  - Astral suite: `ruff` (lint/format) + `ty` (type check/completions/hover/go-to-def)
  - `lua_ls` for editing this config
  - Server configs in `lsp/*.lua` files, enabled via `vim.lsp.enable()`
  - Servers installed via brew (added ruff, ty to Brewfile)
  - No lspconfig, no Mason
- [x] `gd` keymap (go to definition) — the only LSP keymap not built-in
- [x] Built-in completion via `vim.lsp.completion.enable()` on LspAttach
- [ ] Add more LSP servers as needed (gopls, rust_analyzer, etc.) — just add `lsp/*.lua` + brew install
- [ ] Decide: Mason vs brew-managed servers
  - Currently: servers installed manually via brew, tracked in Brewfile
  - **Pro Mason**: auto-installs servers from within nvim, no brew dependency, works on Linux too
  - **Pro brew**: simpler, no extra plugin, already have a Brewfile, one fewer abstraction layer
  - **Hybrid**: use Mason only as a fallback for servers not in brew?
  - Note: mason-lspconfig bridges Mason ↔ lspconfig but adds another plugin

## Diagnostics

- [x] `<leader>td` to toggle diagnostics on/off when they're noisy
- [x] Can't see diagnostic messages — fixed
  - Default `virtual_text` is actually `false`, not `true` (earlier research was wrong)
  - Added `vim.diagnostic.config({ virtual_text = true, jump = { float = true } })`
  - Now: inline text at end of line + float popup when jumping with `[d`/`]d`
  - Also: `<C-W>d` is built-in to open diagnostic float at cursor

## Autocomplete

- [x] Using blink.cmp — fuzzy matching, LSP + buffer + path + snippets, signature help
  - Pinned to v1.* for stability
  - Default keymap preset (Tab/S-Tab to navigate, CR to accept)

## Plugin Management

- [ ] Auto-cleanup stale plugins when removed from config
  - `vim.pack` does NOT auto-uninstall — removed plugins stay on disk
  - `:checkhealth vim.pack` flags inactive plugins
  - Could add a helper that diffs `_pack_specs` against installed and runs `vim.pack.del()`
  - Or just document a manual `:packdel` workflow

## Python Environment

- [x] Get LSP servers working with the local uv `.venv`
  - Tested: both ruff and ty auto-discover `.venv` — no config needed
  - All third-party imports (fastapi, etc.) resolve without errors
- [ ] ty doesn't find local project imports in `src/` layout monorepos
  - ty CLI works from sub-project dir (`ty check` passes), but LSP completions don't offer local imports
  - `root_dir` correctly finds nearest `pyproject.toml` (sub-package level)
  - ty auto-detects `src/` as source root (no `__init__.py` in `src/`)
  - 0 diagnostics on existing imports, but new completions don't suggest local symbols
  - Removed `configurationFile` override (was making it worse)
  - Relevant issues: astral-sh/ty#2633, #819, #1653
  - May be a ty LSP completion limitation vs CLI check working

## Keymaps

- [x] `<Esc>` in normal mode should run `:noh` (clear search highlight)
  - `<C-[>` is Esc in terminals — added back from old config
- [x] Blink.cmp keybinds — switched to `enter` preset + `<C-CR>` to accept
  - Enter to accept, Esc to dismiss, C-n/C-p to navigate
- [x] Insert-mode indent/dedent — `<C-t>` indent (built-in), `<C-S-t>` dedent (added)
- [x] Auto-indent after colon — arborist.nvim sets treesitter indentexpr automatically
  - Verify it works in practice (should be working already)
- [x] `gf` to format buffer via LSP (`vim.lsp.buf.format()`)
  - Overrides built-in `gf` (go to file), but matches old config
- [ ] Treesitter keybinds
  - Incremental selection: old config used `<CR>` / `<S-CR>` for node expand/shrink
  - 0.12 built-ins: `v_an` / `v_in` (parent/child node), `v_]n` / `v_[n` (sibling nav)
  - Textobjects: old config had `af`/`if` for function outer/inner via nvim-treesitter-textobjects
  - nvim-treesitter-textobjects is archived — check if mini.ai covers this or need alternative
- [ ] Readline / emacs-style bindings in insert + cmdline mode
  - Currently inlined manually (C-a, C-b, C-d, C-e, C-f in both insert and cmdline)
  - Options:
    - **tpope/vim-rsi** — plugin that provides readline bindings + the C-t/C-S-t indent trick
    - **Keep inline** — we already have ~10 lines doing this, no plugin needed
  - vim-rsi also handles edge cases (C-a in cmdline = insert-all-completions vs Home)

## Git

- [x] Use mini.diff + Neogit + CodeDiff as the Git stack
  - mini.diff owns lightweight indicators, hunk actions, and the existing-buffer overlay
  - Neogit owns repository status and Git operations
  - CodeDiff owns dedicated repository/file review views
- [x] Keep mini.diff for buffer-level diff indicators and hunk operations
  - `[c` / `]c` navigate previous/next hunks; `[H` / `]H` jump to first/last
  - `yog` toggles the persistent inline overlay with added, deleted, and character-level changes
  - `ghgh` stages the hunk under the cursor; `gHgh` resets it
  - Compares the working buffer against the Git index, so staged changes disappear from its view
  - Can stage but cannot unstage hunks; use Neogit to inspect or unstage the index
  - With line numbers enabled, the default view highlights line numbers rather than sign-column glyphs
  - Uses mini.diff's own histogram/indent-heuristic/linematch defaults; global `diffopt` does not control it
- [x] Add Neogit for repository status and Git operations
  - `<leader>gg` / `:Neogit` opens staged, unstaged, untracked, and conflicted sections
  - Stage with `s`, unstage with `u`, and discard with `x`
  - Uses mini.pick for selections and CodeDiff as its supported external diff viewer
- [x] Add CodeDiff for standalone diff and repository review
  - `<leader>gd` / `:CodeDiff` opens its Git status explorer
  - `:CodeDiffMain` reviews committed branch changes with `main...HEAD`, excluding working-tree changes
  - Supports arbitrary file/directory comparisons, inline and side-by-side layouts, history, staging, and conflicts
  - Always opens a dedicated tab; CodeDiff's "inline" mode means unified layout inside that tab
- [x] Do not add Gitsigns, Fugitive, or Diffview alongside the selected stack
  - Gitsigns overlaps mini.diff; reconsider only for buffer-level unstaging, blame, or dedicated gutter signs
  - Fugitive provides native Git-object diff buffers, but overlaps Neogit's repository workflow
  - Diffview delegates native diff windows but is unnecessary when Neogit uses CodeDiff
- [x] Keep the original global `diffopt` customization (`algorithm:patience`)
  - It affects only native diff mode, not mini.diff or CodeDiff
- [ ] Local review comments for feeding structured feedback back to coding agents
  - `review.nvim` integrates with codediff.nvim and exports AI-ready Markdown
  - Other options persist agent-readable files directly (agent-review.nvim, wishes.nvim, local-review.nvim)

## Terminal Panels

- [x] Fix terminal escape keybind — `<M-[>` (Alt-[) exits terminal mode, Esc passes through
- [x] Bottom panel terminals via snacks.nvim (basic toggle with `<C-/>`)
- [ ] Ghost text / dim text not visible in embedded terminal — **nvim limitation**
  - Root cause: libvterm silently drops SGR 2 (dim/faint attribute)
  - Confirmed: `printf '\x1b[2mDIM\x1b[22m'` renders identically to normal text in nvim terminal
  - Claude Code uses `chalk.dim()` which emits SGR 2 for ghost text
  - PR #39773 (open) would replace libvterm with ghostty-vt — revisit when it ships
  - Possible workaround: wrapper script that replaces `\x1b[2m` with `\x1b[90m` (bright black)
    - e.g. `claude "$@" | sed 's/\x1b\[2m/\x1b[90m/g'` — but may break interactive input
    - Or a `script`/`unbuffer` approach to preserve PTY behavior
- [ ] Integrate cmux for terminal management outside nvim
  - Pivot: nvim's embedded terminal has rendering limitations (no dim/faint text)
  - Use cmux to manage terminals alongside nvim instead of inside it
  - Research: keybinds to switch between cmux panes and nvim
  - Research: how to send commands from nvim to a cmux terminal (e.g., run tests)
  - May want to remove or simplify snacks terminal setup if cmux handles everything

## Open Questions

- Should we add a formatter (conform.nvim) or rely on LSP formatting (ruff)?
