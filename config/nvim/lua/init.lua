local M = {}
local map = vim.api.nvim_set_keymap

-- bootstrap `packer.nvim`
local fn = vim.fn
local install_path = fn.stdpath('data')..'/site/pack/packer/start/packer.nvim'
if fn.empty(fn.glob(install_path)) > 0 then
  packer_bootstrap = fn.system({'git', 'clone', '--depth', '1', 'https://github.com/wbthomason/packer.nvim', install_path})
end
require('packer').startup(function()
  -- Packer can manage itself
  use 'wbthomason/packer.nvim'


  use 'nvim-lua/plenary.nvim'
  use 'kyazdani42/nvim-web-devicons'
  use 'antoinemadec/FixCursorHold.nvim'
  use 'lewis6991/gitsigns.nvim'
  use 'jose-elias-alvarez/null-ls.nvim'

  -- completion
  use 'neovim/nvim-lspconfig'
  use 'hrsh7th/nvim-cmp'
  use 'hrsh7th/cmp-nvim-lsp'
  use 'hrsh7th/cmp-buffer'
  use 'hrsh7th/cmp-path'
  use 'hrsh7th/cmp-cmdline'
  use 'saadparwaiz1/cmp_luasnip'
  use 'L3MON4D3/LuaSnip'
  use 'onsails/lspkind-nvim'
  use 'windwp/nvim-autopairs'

  -- file management
  -- use 'junegunn/fzf', { 'dir': '~/.fzf', 'do': './install --all'  }
  -- use 'junegunn/fzf.vim'
  use 'tpope/vim-fugitive'
  use 'tpope/vim-rhubarb'
  use 'tpope/vim-eunuch'
  use 'ludovicchabant/vim-gutentags'
  use 'majutsushi/tagbar'
  use 'francoiscabrol/ranger.vim'

  use 'mhinz/vim-sayonara'  -- TODO replace with mini.nvim

  -- usability
  use 'tpope/vim-commentary'
  use 'nvim-telescope/telescope.nvim'
  use {'nvim-telescope/telescope-fzf-native.nvim', run = 'make' }
  -- use 'lukas-reineke/indent-blankline.nvim'
  use 'tpope/vim-repeat'
  -- use 'tpope/vim-rsi'
  use 'tpope/vim-unimpaired'
  use 'tpope/vim-abolish'
  use { 'echasnovski/mini.nvim', branch = 'stable' }

  use 'machakann/vim-sandwich'  -- TODO replace with mini.nvim?
  -- use {
    -- 'machakann/vim-sandwich',
    -- config = function()
    --   -- Use vim surround-like keybindings
    --   vim.cmd('runtime macros/sandwich/keymap/surround.vim')
    -- end
  -- }
  use 'wellle/targets.vim'
  use 'kana/vim-textobj-indent'
  use 'peterrincker/vim-argumentative'
  use 'vim-test/vim-test'
  use 'mhinz/vim-grepper'
  -- use 'romainl/vim-qf'
  use 'kana/vim-textobj-user'
  use 'stefandtw/quickfix-reflector.vim'
  use 'junegunn/vim-easy-align'
  use 'nelstrom/vim-visual-star-search'
  use 'AndrewRadev/splitjoin.vim'

  -- ui
  -- use 'mhinz/vim-signify'
  use 'chriskempson/base16-vim'
  use 'machakann/vim-highlightedyank'
  -- use 'psliwka/vim-smoothie'
  use 'nvim-lualine/lualine.nvim'
  use 'folke/lsp-colors.nvim'

  -- productivity
  use 'junegunn/goyo.vim'

  -- python
  use {
    'vim-python/python-syntax',
    ft = {'python'}
  }

  -- other languages
  use 'sheerun/vim-polyglot'
  use {'Glench/Vim-Jinja2-Syntax', ft = {"jinja.html"}}
  use {'plasticboy/vim-markdown', ft= {"markdown"}}
  use({
      "iamcco/markdown-preview.nvim",
      run = function() vim.fn["mkdp#util#install"]() end,
  })
  use {'rust-lang/rust.vim', ft= {"rust"}}
  use 'junegunn/vader.vim'
  use 'neoclide/jsonc.vim'

--- copied in above

  -- Simple plugins can be specified as strings
  -- use '9mm/vim-closer'

  -- Lazy loading:
  -- Load on specific commands
  -- use {'tpope/vim-dispatch', opt = true, cmd = {'Dispatch', 'Make', 'Focus', 'Start'}}

  -- Load on an autocommand event
  -- use {'andymass/vim-matchup', event = 'VimEnter'}

  -- Load on a combination of conditions: specific filetypes or commands
  -- Also run code after load (see the "config" key)
  -- use {
  --   'w0rp/ale',
  --   ft = {'sh', 'zsh', 'bash', 'c', 'cpp', 'cmake', 'html', 'markdown', 'racket', 'vim', 'tex'},
  --   cmd = 'ALEEnable',
  --   config = 'vim.cmd[[ALEEnable]]'
  -- }

  -- Plugins can have dependencies on other plugins
  -- use {
  --   'haorenW1025/completion-nvim',
  --   opt = true,
  --   requires = {{'hrsh7th/vim-vsnip', opt = true}, {'hrsh7th/vim-vsnip-integ', opt = true}}
  -- }

  -- Plugins can also depend on rocks from luarocks.org:
  -- use {
  --   'my/supercoolplugin',
  --   rocks = {'lpeg', {'lua-cjson', version = '2.1.0'}}
  -- }

  -- You can specify rocks in isolation
  -- use_rocks 'penlight'
  -- use_rocks {'lua-resty-http', 'lpeg'}

  -- Local plugins can be included
  -- use '~/projects/personal/hover.nvim'

  -- Plugins can have post-install/update hooks
  -- use {'iamcco/markdown-preview.nvim', run = 'cd app && yarn install', cmd = 'MarkdownPreview'}

  -- Post-install/update hook with neovim command
  -- use { 'nvim-treesitter/nvim-treesitter', run = ':TSUpdate' }

  -- Post-install/update hook with call of vimscript function with argument
  -- use { 'glacambre/firenvim', run = function() vim.fn['firenvim#install'](0) end }

  -- Use specific branch, dependency and run lua file after load
  -- use {
  --   'glepnir/galaxyline.nvim', branch = 'main', config = function() require'statusline' end,
  --   requires = {'kyazdani42/nvim-web-devicons'}
  -- }

  -- Use dependency and run lua function after load
  -- use {
  --   'lewis6991/gitsigns.nvim', requires = { 'nvim-lua/plenary.nvim' },
  --   config = function() require('gitsigns').setup() end
  -- }

  -- You can specify multiple plugins in a single call
  -- use {'tjdevries/colorbuddy.vim', {'nvim-treesitter/nvim-treesitter', opt = true}}

  -- You can alias plugin names
  -- use {'dracula/vim', as = 'dracula'}
  if packer_bootstrap then
    require('packer').sync()
  end
end)

local nvim_lsp = require("lspconfig")
require('mini.surround').setup()

require('gitsigns').setup{
  on_attach = function(bufnr)
    local gs = package.loaded.gitsigns

    local function map(mode, l, r, opts)
      opts = opts or {}
      opts.buffer = bufnr
      vim.keymap.set(mode, l, r, opts)
    end

    -- Navigation
    map('n', ']c', function()
      if vim.wo.diff then return ']c' end
      vim.schedule(function() gs.next_hunk{wrap=false} end)
      return '<Ignore>'
    end, {expr=true})

    map('n', '[c', function()
      if vim.wo.diff then return '[c' end
      vim.schedule(function() gs.prev_hunk{wrap=false} end)
      return '<Ignore>'
    end, {expr=true})

    -- Text object
    map({'o', 'x'}, 'ih', ':<C-U>Gitsigns select_hunk<CR>')
  end
  }

require("nvim-autopairs").setup({})
require('lualine').setup()

-- nvim-cmp {{{
vim.o.completeopt = "menu,menuone,noselect"
local cmp = require("cmp")
local lspkind = require("lspkind")

local has_words_before = function()
	local line, col = unpack(vim.api.nvim_win_get_cursor(0))
	return col ~= 0 and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match("%s") == nil
end

local luasnip = require("luasnip")
cmp.setup({
	formatting = {
		format = lspkind.cmp_format(),
	},
	snippet = {
		expand = function(args)
			require("luasnip").lsp_expand(args.body) -- For `luasnip` users.
		end,
	},
	mapping = {
		["<C-b>"] = cmp.mapping(cmp.mapping.scroll_docs(-4), { "i", "c" }),
		["<C-f>"] = cmp.mapping(cmp.mapping.scroll_docs(4), { "i", "c" }),
		["<C-Space>"] = cmp.mapping(cmp.mapping.complete(), { "i", "c" }),
		["<C-y>"] = cmp.config.disable, -- Specify `cmp.config.disable` if you want to remove the default `<C-y>` mapping.
		["<C-e>"] = cmp.mapping({
			i = cmp.mapping.abort(),
			c = cmp.mapping.close(),
		}),
		["<CR>"] = cmp.mapping.confirm({ select = false }),
		["<Tab>"] = cmp.mapping(function(fallback)
			if cmp.visible() then
				cmp.select_next_item()
			elseif luasnip.expand_or_jumpable() then
				luasnip.expand_or_jump()
			elseif has_words_before() then
				cmp.complete()
			else
				fallback()
			end
		end, { "i", "s" }),

		["<S-Tab>"] = cmp.mapping(function(fallback)
			if cmp.visible() then
				cmp.select_prev_item()
			elseif luasnip.jumpable(-1) then
				luasnip.jump(-1)
			else
				fallback()
			end
		end, { "i", "s" }),
	},
	sources = cmp.config.sources({
		{ name = "nvim_lsp" },
		{ name = "luasnip" },
	}, {
		{ name = "buffer" },
	}),
})

  -- Use buffer source for `/` (if you enabled `native_menu`, this won't work anymore).
  cmp.setup.cmdline('/', {
    mapping = cmp.mapping.preset.cmdline(),
    sources = {
      { name = 'buffer' }
    }
  })

  -- Use cmdline & path source for ':' (if you enabled `native_menu`, this won't work anymore).
  cmp.setup.cmdline(':', {
    mapping = cmp.mapping.preset.cmdline(),
    sources = cmp.config.sources({
      { name = 'path' }
    }, {
      { name = 'cmdline' }
    })
  })
-- automatically insert parens for methods/functions
local cmp_autopairs = require("nvim-autopairs.completion.cmp")
cmp.event:on("confirm_done", cmp_autopairs.on_confirm_done({ map_char = { tex = "" } }))

-- }}}

-- vim.lsp.handlers["textDocument/publishDiagnostics"] = function() end
vim.lsp.handlers["textDocument/publishDiagnostics"] = vim.lsp.with(vim.lsp.diagnostic.on_publish_diagnostics, {
	-- Enable underline, use default values
	underline = true,
	-- Enable virtual text, override spacing to 4
	virtual_text = {
		spacing = 4,
	},
	-- Disable a feature
	update_in_insert = false,
})

-- keybinds for formatting/diagnostics
local on_attach_null_ls = function(client, bufnr) -- luacheck: ignore
	local opts = { noremap = true, silent = true }
	local function buf_set_keymap(...)
		vim.api.nvim_buf_set_keymap(bufnr, ...)
	end

	buf_set_keymap("n", "gf", "<cmd>lua vim.lsp.buf.formatting_seq_sync()<CR>", opts)

	buf_set_keymap("n", "[d", "<cmd>lua vim.lsp.diagnostic.goto_prev()<CR>", opts)
	buf_set_keymap("n", "]d", "<cmd>lua vim.lsp.diagnostic.goto_next()<CR>", opts)
	buf_set_keymap("n", "<leader>e", "<cmd>lua vim.lsp.diagnostic.show_line_diagnostics()<CR>", opts)
end

local on_attach = function(client, bufnr) -- luacheck: ignore
	local function buf_set_keymap(...)
		vim.api.nvim_buf_set_keymap(bufnr, ...)
	end
	local function buf_set_option(...)
		vim.api.nvim_buf_set_option(bufnr, ...)
	end

	-- enable completion triggered by <c-x><c-o>
	buf_set_option("omnifunc", "v:lua.vim.lsp.omnifunc")

	-- mappings.
	local opts = { noremap = true, silent = true }

	-- see `:help vim.lsp.*` for documentation on any of the below functions
	-- buf_set_keymap('n', 'gd', '<cmd>lua vim.lsp.buf.declaration()<cr>', opts)
	buf_set_keymap("n", "<c-]>", "<cmd>lua vim.lsp.buf.definition()<cr>", opts)
	buf_set_keymap("n", "K", "<cmd>lua vim.lsp.buf.hover()<cr>", opts)
	-- buf_set_keymap('n', 'gi', '<cmd>lua vim.lsp.buf.implementation()<cr>', opts)
	-- buf_set_keymap('n', '<c-k>', '<cmd>lua vim.lsp.buf.signature_help()<cr>', opts)
	-- buf_set_keymap('n', '<leader>wa', '<cmd>lua vim.lsp.buf.add_workspace_folder()<cr>', opts)
	-- buf_set_keymap('n', '<leader>wr', '<cmd>lua vim.lsp.buf.remove_workspace_folder()<cr>', opts)
	-- buf_set_keymap('n', '<leader>wl', '<cmd>lua print(vim.inspect(vim.lsp.buf.list_workspace_folders()))<cr>', opts)
	buf_set_keymap('n', '<leader>rn', '<cmd>lua vim.lsp.buf.rename()<cr>', opts)
	-- buf_set_keymap('n', '<leader>ca', '<cmd>lua vim.lsp.buf.code_action()<cr>', opts)
	buf_set_keymap("n", "gr", "<cmd>lua vim.lsp.buf.references()<cr>", opts)
	-- buf_set_keymap('n', '<leader>q', '<cmd>lua vim.lsp.diagnostic.set_loclist()<cr>', opts)
	-- buf_set_keymap("n", "<leader>f", "<cmd>lua vim.lsp.buf.formatting()<cr>", opts)

	on_attach_null_ls(client, bufnr)
	-- vim.api
	--     .nvim_command [[autocmd bufwritepre <buffer> lua vim.lsp.buf.formatting()]]
end

-- to debug do this:
vim.lsp.set_log_level("debug")
-- :lua vim.cmd('e'..vim.lsp.get_log_path())

-- TODO get clangd working w/ envoy
-- nvim_lsp.clangd.setup {
--     cmd = {"clangd", "--background-index"},
--     on_attach = on_attach
-- }

require("null-ls").setup({
	debug = true,
	sources = {
		require("null-ls").builtins.formatting.stylua,
		require("null-ls").builtins.formatting.black,
		require("null-ls").builtins.diagnostics.luacheck.with({
			extra_args = { "--config", vim.fn.expand("$XDG_CONFIG_HOME/luacheck/.luacheckrc") },
		}),
		require("null-ls").builtins.diagnostics.mypy.with({
			extra_args = { "--ignore-missing-imports" },
		}),
		require("null-ls").builtins.formatting.reorder_python_imports,
		require("null-ls").builtins.diagnostics.shellcheck,
		require("null-ls").builtins.diagnostics.mypy,
		require("null-ls").builtins.formatting.trim_whitespace,
	},
	on_attach = on_attach_null_ls,
})
-- Setup lspconfig.
local capabilities = require("cmp_nvim_lsp").update_capabilities(vim.lsp.protocol.make_client_capabilities())
local servers = { "pylsp", "tsserver", "gopls", "rust_analyzer" }
for _, lsp in ipairs(servers) do
	nvim_lsp[lsp].setup({
		on_attach = on_attach,
		flags = { debounce_text_changes = 250 },
		capabilities = capabilities,
		settings = {
			pylsp = {
				configurationSources = { "flake8" },
			},
		},
	})
end

-- telescope {{{
local action_layout = require("telescope.actions.layout")
local actions = require("telescope.actions")
require("telescope").setup({
	defaults = {
		layout_strategy = "flex",
		mappings = {
			n = {
				["<C-o>"] = action_layout.toggle_preview,
			},
			i = {
				["<C-o>"] = action_layout.toggle_preview,
			},
			i = {
				["<C-q>"] = actions.smart_send_to_qflist + actions.open_qflist,
			},
		},
	},
})
require("telescope").load_extension("fzf")
M.project_files = function()
	local ok = pcall(require("telescope.builtin").git_files, { show_untracked = false })
	if not ok then
		require("telescope.builtin").find_files()
	end
end

-- TODO: implement own `src` kitty picker
-- local telescope = require "telescope"
-- local pickers = require "telescope.pickers"
-- local finders = require "telescope.finders"
-- local conf = require("telescope.config").values
-- local utils = require "telescope.utils"
-- local output = utils.get_os_command_output({ "kitty", "@", "ls" }, cwd)

-- local colors = function(opts)
-- 	local command = { "kitty", "@", "ls"}
-- 	opts = opts or {}
-- 	pickers.new(opts, {
-- 			prompt_title = "~/src",
-- 			finder = finders.new_oneshot_job ( command, opts ),
-- 			sorter = conf.generic_sorter(opts),
-- 		}):find()
-- end
-- colors()
map("n", "<C-p>", "<Cmd>lua require('init').project_files()<CR>", { noremap = true })
-- }}}

return M
