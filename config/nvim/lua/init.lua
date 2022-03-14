local M = {}
local nvim_lsp = require("lspconfig")
local map = vim.api.nvim_set_keymap

require("gitsigns").setup()
require("nvim-autopairs").setup({})
require('lualine').setup {
  options = { theme  = 'auto' },
}

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
cmp.setup.cmdline("/", {
	sources = {
		{ name = "buffer" },
	},
})

-- Use cmdline & path source for ':' (if you enabled `native_menu`, this won't work anymore).
cmp.setup.cmdline(":", {
	sources = cmp.config.sources({
		{ name = "path" },
	}, {
		{ name = "cmdline" },
	}),
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
	-- buf_set_keymap('n', '<leader>rn', '<cmd>lua vim.lsp.buf.rename()<cr>', opts)
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
require("telescope").setup({
	defaults = {
		layout_strategy = "flex",
		mappings = {
			n = {
				["<C-f>"] = action_layout.toggle_preview,
			},
			i = {
				["<C-f>"] = action_layout.toggle_preview,
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
map("n", "<C-p>", "<Cmd>lua require('init').project_files()<CR>", { noremap = true })
-- }}}

return M
