local M = {}
vim.g.mapleader = " "

-- reload init.lua file
local luafileCmd = string.format(":luafile %s/nvim/init.lua<CR>", vim.env.XDG_CONFIG_HOME)
vim.keymap.set("n", "<leader>sl", luafileCmd, { noremap = true }) -- <leader> Source Lua
vim.keymap.set("n", "<leader>ll", ":luafile %<CR>", { noremap = true }) -- <leader> Lua Lua

-- bootstrap `packer.nvim`
local ensure_packer = function()
    local fn = vim.fn
    local install_path = fn.stdpath("data") .. "/site/pack/packer/start/packer.nvim"
    if fn.empty(fn.glob(install_path)) > 0 then
        fn.system({ "git", "clone", "--depth", "1", "https://github.com/wbthomason/packer.nvim", install_path })
        vim.cmd([[packadd packer.nvim]])
        return true
    end
    return false
end

local packer_bootstrap = ensure_packer()

-- start of plugins, maybe refactor into its own .lua someday
require("packer").startup(function(use)
    -- Packer can manage itself
    use("wbthomason/packer.nvim")

    use("nvim-lua/plenary.nvim")
    use("kyazdani42/nvim-web-devicons")
    use("antoinemadec/FixCursorHold.nvim")
    use("jose-elias-alvarez/null-ls.nvim")
    use("lewis6991/gitsigns.nvim")

    -- completion
    use("neovim/nvim-lspconfig")
    use("hrsh7th/nvim-cmp")
    use("hrsh7th/cmp-nvim-lsp")
    use("hrsh7th/cmp-buffer")
    use("hrsh7th/cmp-path")
    use("hrsh7th/cmp-cmdline")
    use("saadparwaiz1/cmp_luasnip")
    use("L3MON4D3/LuaSnip")
    use("onsails/lspkind-nvim")
    use("windwp/nvim-autopairs")

    -- file management
    use({ "junegunn/fzf", run = ":call fzf#install()" })
    use("junegunn/fzf.vim")
    use("tpope/vim-fugitive")
    use("tpope/vim-rhubarb")
    use("tpope/vim-eunuch")
    use("ludovicchabant/vim-gutentags")
    use("majutsushi/tagbar")

    use("mhinz/vim-sayonara") -- TODO replace with mini.nvim

    -- usability
    use("tpope/vim-commentary")
    use("nvim-telescope/telescope.nvim")
    use({ "nvim-telescope/telescope-fzf-native.nvim", run = "make" })
    -- use { "~/src/telescope-file-browser.nvim" }
    use({ "nvim-telescope/telescope-file-browser.nvim" })
    -- use 'lukas-reineke/indent-blankline.nvim'
    use("tpope/vim-repeat")
    -- use 'tpope/vim-rsi'
    use("tpope/vim-unimpaired")
    use({ "echasnovski/mini.nvim", branch = "stable" })

    use("machakann/vim-sandwich") -- TODO replace with mini.nvim?
    -- use {
    -- 'machakann/vim-sandwich',
    -- config = function()
    --   -- Use vim surround-like keybindings
    --   vim.cmd('runtime macros/sandwich/keymap/surround.vim')
    -- end
    -- }
    use("wellle/targets.vim")
    use("peterrincker/vim-argumentative")
    use("vim-test/vim-test")
    use("mhinz/vim-grepper")
    -- use 'romainl/vim-qf'
    use("stefandtw/quickfix-reflector.vim")
    use("junegunn/vim-easy-align")
    use("nelstrom/vim-visual-star-search")

    use("AndrewRadev/splitjoin.vim")

    -- ui
    use("rcarriga/nvim-notify")
    use({
        "nvim-treesitter/nvim-treesitter",
        run = ":TSUpdate",
    })
    use("RRethy/nvim-base16")
    -- use 'chriskempson/base16-vim'
    use("marko-cerovac/material.nvim")
    use("machakann/vim-highlightedyank")
    -- use 'ful1e5/onedark.nvim'
    use("navarasu/onedark.nvim")
    use("daschw/leaf.nvim")
    use("EdenEast/nightfox.nvim")
    use("sainnhe/sonokai")
    use({
        "nvim-lualine/lualine.nvim",
        requires = { "kyazdani42/nvim-web-devicons", opt = true },
    })
    use({
        "kevinhwang91/rnvimr",
        requires = {
            "kyazdani42/nvim-web-devicons",
        },
    })
    use("psliwka/termcolors.nvim")
    use("folke/lsp-colors.nvim")
    use("lewis6991/impatient.nvim")

    -- python
    use({
        "vim-python/python-syntax",
        ft = { "python" },
    })

    -- other languages
    use("sheerun/vim-polyglot")
    use({ "Glench/Vim-Jinja2-Syntax", ft = { "jinja.html" } })
    use({ "plasticboy/vim-markdown", ft = { "markdown" } })
    use({
        "iamcco/markdown-preview.nvim",
        run = function()
            vim.fn["mkdp#util#install"]()
        end,
    })
    use({ "rust-lang/rust.vim", ft = { "rust" } })
    use("junegunn/vader.vim")
    use("neoclide/jsonc.vim")

    if packer_bootstrap then
        require("packer").sync()
    end
end)

if packer_bootstrap then
    print("Packer needed boostrap; rerun neovim after sync finishes")
    return
end

local nvim_lsp = require("lspconfig")
require("nightfox").setup({
    options = {
        dim_inactive = true,
        styles = {
            comments = "italic",
            keywords = "bold",
            types = "italic,bold",
        },
        -- inverse = {
        --     search = true,
        -- },
    },
})
vim.cmd("colorscheme nightfox")
-- vim.pretty_print(require('nightfox.palette').load('nightfox'))

require("gitsigns").setup({
    on_attach = function(bufnr)
        local gs = package.loaded.gitsigns

        local function localmap(mode, l, r, opts)
            opts = opts or {}
            opts.buffer = bufnr
            vim.keymap.set(mode, l, r, opts)
        end

        -- Navigation
        localmap("n", "]c", function()
            if vim.wo.diff then
                return "]c"
            end
            vim.schedule(function()
                gs.next_hunk({ wrap = false })
            end)
            return "<Ignore>"
        end, { expr = true })

        localmap("n", "[c", function()
            if vim.wo.diff then
                return "[c"
            end
            vim.schedule(function()
                gs.prev_hunk({ wrap = false })
            end)
            return "<Ignore>"
        end, { expr = true })

        -- Text object
        localmap({ "o", "x" }, "ih", ":<C-U>Gitsigns select_hunk<CR>")
    end,
})
require("nvim-treesitter.configs").setup({
    -- Modules and its options go here
    ensure_installed = {
        "python",
        "lua",
        "typescript",
        "yaml",
        "cpp",
        "go",
        "hcl",
        "html",
        "markdown",
        "tsx",
        "vim",
        "regex",
        "json",
        "json5",
    },
    -- indent = { enable = true },
    -- highlight = { enable = true },
    -- incremental_selection = { enable = true },
    -- textobjects = { enable = true },
})

require("nvim-autopairs").setup({})

vim.cmd("set termguicolors")
require("onedark").setup({
    style = "warm",
    highlights = {
        TelescopeBorder = { fg = "$grey" },
        TelescopePromptBorder = { fg = "$grey" },
        TelescopeResultsBorder = { fg = "$grey" },
        TelescopePreviewBorder = { fg = "$grey" },
    },
})
-- require("onedark").load()
-- require('base16-colorscheme').setup()
-- require('base16-colorscheme').with_config {
--     telescope = false,
-- }
-- vim.cmd('colorscheme base16-default-dark')
require("lualine").setup({})

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
        ["<C-b>"] = cmp.mapping.scroll_docs(-4),
        ["<C-f>"] = cmp.mapping.scroll_docs(4),
        ["<C-Space>"] = cmp.mapping.complete(),
        ["<C-e>"] = cmp.mapping.abort(),
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
    mapping = cmp.mapping.preset.cmdline(),
    sources = {
        { name = "buffer" },
    },
})

-- Use cmdline & path source for ':' (if you enabled `native_menu`, this won't work anymore).
cmp.setup.cmdline(":", {
    mapping = cmp.mapping.preset.cmdline(),
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
local on_attach_null_ls = function(_, bufnr) -- luacheck: ignore
    local bufopts = { noremap = true, silent = true, buffer = bufnr }
    vim.keymap.set("n", "gf", function()
        vim.lsp.buf.format({ async = true })
    end, bufopts)

    vim.keymap.set("n", "[d", vim.diagnostic.goto_prev, bufopts)
    vim.keymap.set("n", "]d", vim.diagnostic.goto_next, bufopts)
    vim.keymap.set("n", "<space>e", vim.diagnostic.open_float, bufopts)
end

local on_attach = function(client, bufnr) -- luacheck: ignore
    -- Enable completion triggered by <c-x><c-o>
    vim.api.nvim_buf_set_option(bufnr, "omnifunc", "v:lua.vim.lsp.omnifunc")

    -- new below
    -- see `:help vim.lsp.*` for documentation on any of the below functions
    local bufopts = { noremap = true, silent = true, buffer = bufnr }
    vim.keymap.set("n", "<c-]>", vim.lsp.buf.definition, bufopts)
    vim.keymap.set("n", "K", vim.lsp.buf.hover, bufopts)
    vim.keymap.set("n", "gi", vim.lsp.buf.implementation, bufopts)
    vim.keymap.set("n", "<space>rn", vim.lsp.buf.rename, bufopts)
    vim.keymap.set("n", "gr", vim.lsp.buf.references, bufopts)
    on_attach_null_ls(client, bufnr)
    -- vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, bufopts)
    -- vim.keymap.set('n', '<C-k>', vim.lsp.buf.signature_help, bufopts)
    -- vim.keymap.set('n', '<space>wa', vim.lsp.buf.add_workspace_folder, bufopts)
    -- vim.keymap.set('n', '<space>wr', vim.lsp.buf.remove_workspace_folder, bufopts)
    -- vim.keymap.set('n', '<space>wl', function()
    --   print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
    -- end, bufopts)
    -- vim.keymap.set('n', '<space>D', vim.lsp.buf.type_definition, bufopts)
    -- vim.keymap.set('n', '<space>ca', vim.lsp.buf.code_action, bufopts)
    -- vim.api
    --     .nvim_command [[autocmd bufwritepre <buffer> lua vim.lsp.buf.formatting()]]
end

-- DEBUGGING LSP
-- vim.lsp.set_log_level("debug")
-- :lua vim.cmd('e'..vim.lsp.get_log_path())

require("null-ls").setup({
    debug = true,
    sources = {
        require("null-ls").builtins.formatting.stylua.with({
            extra_args = { "--indent-type", "Spaces" },
        }),
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
local capabilities = require("cmp_nvim_lsp").default_capabilities()

require('lspconfig')['tsserver'].setup{
    on_attach = on_attach,
}

require('lspconfig')['gopls'].setup{
    on_attach = on_attach,
}

require('lspconfig')['rust_analyzer'].setup{
    on_attach = on_attach,
}

require('lspconfig')['pylsp'].setup{
    on_attach = on_attach,
    settings = {
        pylsp = {
            configurationSources = { "flake8" },
        },
    },
}

local hammerspoon = string.format("%s/hammerspoon/Spoons/EmmyLua.spoon/annotations", vim.env.XDG_CONFIG_HOME)
nvim_lsp.sumneko_lua.setup({
    on_attach = on_attach,
    capabilities = capabilities,
    settings = {
        Lua = {
            runtime = {
                -- Tell the language server which version of Lua you're using (most likely LuaJIT in the case of Neovim)
                version = "LuaJIT",
            },
            diagnostics = {
                -- Get the language server to recognize the globals
                globals = { "vim", "hs", "spoon" },
            },
            workspace = {
                -- Make the server aware of runtime files
                library = { vim.api.nvim_get_runtime_file("", true), hammerspoon },
            },
            -- Do not send telemetry data containing a randomized but unique identifier
            telemetry = {
                enable = false,
            },
        },
    },
})

-- telescope {{{
-- individual pickers are in telescope.lua
local action_layout = require("telescope.actions.layout")
local actions = require("telescope.actions")
local fb_actions = require("telescope").extensions.file_browser.actions
require("telescope").setup({
    defaults = {
        layout_strategy = "flex",
        mappings = {
            n = {
                ["<C-o>"] = action_layout.toggle_preview,
            },
            i = {
                ["<C-o>"] = action_layout.toggle_preview,
                ["<C-q>"] = actions.smart_send_to_qflist + actions.open_qflist,
            },
        },
    },
    extensions = {
        file_browser = {
            initial_mode = "normal",
            theme = "ivy",
            hidden = true,
            hide_parent_dir = true,
            mappings = {
                ["n"] = {
                    ["h"] = fb_actions.goto_parent_dir,
                    ["l"] = actions.select_default,
                    ["q"] = actions.close,
                },
            },
        },
    },
})
require("telescope").load_extension("fzf")
require("telescope").load_extension("file_browser")
vim.keymap.set("n", "<C-p>", "<Cmd>lua require('telescope_custom').project_files()<CR>", { noremap = true })
vim.keymap.set("n", "<leader>p", "<Cmd>lua require('telescope_custom').src_dir()<CR>", { noremap = true })
-- }}}

-- user commands {{{
local cScratch = function()
    vim.cmd("split")
    local win = vim.api.nvim_get_current_win()
    local buf = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_win_set_buf(win, buf)
    return buf
end
local cMessages = function()
    cScratch()
    vim.cmd("put = execute('messages')")
end
vim.api.nvim_create_user_command("Scratch", cScratch, {})
vim.api.nvim_create_user_command("Messages", cMessages, {})
-- }}}

vim.cmd("runtime vimscript/init.vim")

if vim.env.WSL_DISTRO_NAME then
    vim.g.netrw_browsex_viewer = 'cmd.exe /c start ""'
end

return M
