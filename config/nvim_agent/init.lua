-- nvim_agent: minimal neovim config for agentic coding
-- Launch with: NVIM_APPNAME=nvim_agent nvim
-- or: nagent (shell alias)
-- Requires: nvim 0.12+

vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

-- [[ Options ]]
vim.opt.number = true
vim.schedule(function()
  vim.opt.clipboard = 'unnamedplus'
end)
vim.opt.breakindent = true
vim.opt.expandtab = true
vim.opt.shiftwidth = 2
vim.opt.tabstop = 4
vim.opt.undofile = true
vim.opt.backupdir = vim.fn.stdpath('state') .. '/backup'
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.splitright = true
vim.opt.splitbelow = true
vim.opt.list = true
vim.opt.listchars = { tab = '» ', trail = '·', nbsp = '␣' }
vim.opt.signcolumn = 'yes'
vim.opt.cursorline = true
vim.opt.scrolloff = 10
vim.opt.diffopt:append({ 'algorithm:patience' })
vim.opt.winbar = ' %f'
vim.opt.laststatus = 3

-- [[ Keymaps ]]

-- Clear search highlight on Esc
vim.keymap.set('n', '<C-[>', function()
  vim.cmd('nohlsearch')
end)

-- Diagnostics
vim.diagnostic.config({ virtual_text = true, jump = { float = true } })
vim.keymap.set('n', '<leader>d', vim.diagnostic.setqflist, { desc = 'Open diagnostic quickfix list' })

-- Split navigation
vim.keymap.set('n', '<C-h>', '<C-w><C-h>', { desc = 'Move focus to the left window' })
vim.keymap.set('n', '<C-l>', '<C-w><C-l>', { desc = 'Move focus to the right window' })
vim.keymap.set('n', '<C-j>', '<C-w><C-j>', { desc = 'Move focus to the lower window' })
vim.keymap.set('n', '<C-k>', '<C-w><C-k>', { desc = 'Move focus to the upper window' })

-- Save
vim.keymap.set('n', '<C-s>', ':w<CR>')
vim.keymap.set('v', '<C-s>', '<esc>:w<CR>gv')

-- Repeat / macro
vim.keymap.set('v', '.', ':normal .<CR>')
vim.keymap.set('v', 'Q', ':normal @q<CR>')
vim.keymap.set('n', 'Q', '@q')

-- Emacs-style insert/cmdline navigation
vim.keymap.set('i', '<C-a>', '<c-o>^')
vim.keymap.set('i', '<C-b>', '<Left>')
vim.keymap.set('i', '<C-d>', '<Del>')
vim.keymap.set('i', '<C-e>', '<c-o>$')
vim.keymap.set('i', '<C-f>', '<Right>')
vim.keymap.set('c', '<C-a>', '<Home>')
vim.keymap.set('c', '<C-b>', '<Left>')
vim.keymap.set('c', '<C-d>', '<Del>')
vim.keymap.set('c', '<C-e>', '<End>')
vim.keymap.set('c', '<C-f>', '<Right>')

-- Word wrap navigation
vim.keymap.set({ 'n', 'v' }, 'k', "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true })
vim.keymap.set({ 'n', 'v' }, 'j', "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true })

-- Line navigation
vim.keymap.set({ 'n', 'v' }, 'H', '^')
vim.keymap.set({ 'n', 'v' }, 'L', '$')

-- Match pair
vim.keymap.set('n', 'mm', '%')

-- macOS word deletion
vim.keymap.set('i', '<A-BS>', '<C-W>')

-- Zoom split
vim.keymap.set('n', '<C-w>z', ':tab split<CR>')

-- Highlight pasted text
vim.keymap.set('n', 'gp', '`[v`]')

-- Copy file path
vim.keymap.set('n', '<leader>c', ":let @+ = expand('%')<CR>", { silent = true })
vim.keymap.set('n', '<leader>C', ":let @+ = expand('%:p')<CR>", { silent = true })

-- Yank register paste
vim.keymap.set({ 'n', 'v' }, 'X', '"0p')

-- Search and replace from last search
vim.keymap.set('n', '<leader>/', function()
  local search_pattern = vim.fn.getreg('/')
  search_pattern = search_pattern:gsub('\\<', ''):gsub('\\>', ''):gsub('\\V', '')
  local cmd = ':%s//' .. search_pattern .. '/g' .. '<left><left>'
  local escaped = vim.api.nvim_replace_termcodes(cmd, true, true, true)
  vim.api.nvim_feedkeys(escaped, 'n', false)
end, { silent = true })

-- Neovim remote (needed until --remote-wait lands in nvim)
vim.env.EDITOR = "nvr -cc split --remote-wait +'set bufhidden=wipe'"
vim.env.VISUAL = "nvr -cc split --remote-wait +'set bufhidden=wipe'"

-- [[ Terminal keymaps ]]
vim.api.nvim_create_autocmd('TermOpen', {
  desc = 'Set terminal keymaps',
  group = vim.api.nvim_create_augroup('terminal-keymaps', { clear = true }),
  callback = function(ev)
    local opts = { buffer = ev.buf }
    vim.keymap.set('t', '<esc>', [[<C-\><C-n>]], opts)
    vim.keymap.set('n', '<C-e>', ':startinsert<CR><C-e>', opts)
    vim.keymap.set('n', '<C-a>', ':startinsert<CR><C-a>', opts)
    vim.keymap.set('n', '<C-c>', ':startinsert<CR>', opts)
    vim.keymap.set('n', '<C-p>', ':startinsert<CR><C-p>', opts)
    vim.keymap.set('t', '<S-CR>', '<C-v><C-j>', opts)
    vim.wo[vim.fn.bufwinid(ev.buf)].foldmethod = 'manual'
  end,
})

-- [[ Autocommands ]]
vim.api.nvim_create_autocmd('TextYankPost', {
  desc = 'Highlight when yanking text',
  group = vim.api.nvim_create_augroup('highlight-yank', { clear = true }),
  callback = function()
    vim.highlight.on_yank()
  end,
})

-- [[ Plugins ]]
-- use() collects specs and deferred configs; pack_install() batches the
-- download then runs all configs once plugins are on the runtimepath.
local _pack_specs = {}
local _pack_configs = {}
local function use(spec, config)
  -- spec can be a URL string or a table like { src = '...', version = '...' }
  table.insert(_pack_specs, spec)
  if config then table.insert(_pack_configs, config) end
end

use('https://github.com/tpope/vim-sleuth')

use('https://github.com/arborist-ts/arborist.nvim', function()
  require('arborist').setup({ prefer_wasm = false })
end)

use('https://github.com/stevearc/oil.nvim', function()
  require('oil').setup({
    view_options = { show_hidden = true },
    keymaps = {
      ['<C-h>'] = false,
      ['<C-l>'] = false,
      ['<C-s>'] = false,
      ['<C-r>'] = 'actions.refresh',
      ['<C-\\>'] = { 'actions.select', opts = { vertical = true }, desc = 'Open in vertical split' },
      ['<C-_>'] = { 'actions.select', opts = { horizontal = true }, desc = 'Open in horizontal split' },
    },
    git = {
      add = function(_) return true end,
      mv = function(_, _) return true end,
      rm = function(_) return true end,
    },
  })
  vim.keymap.set('n', '-', '<cmd>Oil<CR>')
end)

-- [[ LSP ]]
-- lspconfig provides lsp/*.lua configs; custom overrides in our lsp/ dir.
-- Servers installed via brew: ruff, ty, lua-language-server, gopls, rust-analyzer, etc.
use('https://github.com/neovim/nvim-lspconfig', function()
  vim.lsp.enable({ 'ruff', 'ty', 'lua_ls', 'gopls', 'rust_analyzer' })
end)

vim.api.nvim_create_autocmd('LspAttach', {
  group = vim.api.nvim_create_augroup('lsp-attach', { clear = true }),
  callback = function(ev)
    local client = vim.lsp.get_client_by_id(ev.data.client_id)
    if not client then return end

    client.server_capabilities.semanticTokensProvider = nil

    if client:supports_method(vim.lsp.protocol.Methods.textDocument_inlayHint) then
      vim.keymap.set('n', '<leader>th', function()
        vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled({ bufnr = ev.buf }))
      end, { buffer = ev.buf, desc = 'Toggle inlay hints' })
    end
  end,
})

use({ src = 'https://github.com/saghen/blink.cmp', version = 'v1' }, function()
  require('blink.cmp').setup({
    keymap = {
      preset = 'enter',
      ['<C-CR>'] = { 'select_and_accept' },
    },
    completion = {
      documentation = { auto_show = true, auto_show_delay_ms = 0 },
    },
    signature = { enabled = true },
    sources = {
      default = { 'lsp', 'path', 'snippets', 'buffer' },
    },
    fuzzy = { implementation = 'prefer_rust_with_warning' },
  })
end)

use('https://github.com/echasnovski/mini.nvim', function()
  require('mini.hues').setup({ background = '#192330', foreground = '#cdcecf' })

  require('mini.icons').setup()

  require('mini.pick').setup()
  vim.keymap.set('n', '<C-p>', '<cmd>Pick files<CR>')
  vim.keymap.set('n', '<leader>sf', '<cmd>Pick files<CR>', { desc = 'Search files' })
  vim.keymap.set('n', '<leader>sg', '<cmd>Pick grep_live<CR>', { desc = 'Search grep' })
  vim.keymap.set('n', '<leader>sw', '<cmd>Pick grep pattern="<cword>"<CR>', { desc = 'Search word' })
  vim.keymap.set('n', '<leader>sh', '<cmd>Pick help<CR>', { desc = 'Search help' })
  vim.keymap.set('n', '<leader>sr', '<cmd>Pick resume<CR>', { desc = 'Search resume' })
  vim.keymap.set('n', '<leader><leader>', '<cmd>Pick buffers<CR>', { desc = 'Find buffers' })

  require('mini.ai').setup({ n_lines = 500 })
  vim.keymap.set('x', 'il', 'g_o^')
  vim.keymap.set('o', 'il', ':normal vil<CR>')

  require('mini.surround').setup()

  local miniBufremove = require('mini.bufremove')
  miniBufremove.setup()
  vim.keymap.set('n', '<C-q>', miniBufremove.delete)

  require('mini.diff').setup()

  require('mini.statusline').setup()

  require('mini.tabline').setup()
end)

-- Install all plugins (parallel), then run configs
vim.pack.add(_pack_specs)
for _, config in ipairs(_pack_configs) do
  config()
end

-- vim: ts=2 ss=2 sw=2 et
