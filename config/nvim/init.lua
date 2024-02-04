local M = {}

-- disable matchparen before any config
vim.g.loaded_matchparen = 1

-- if vim.g.vscode then
--     -- vscode extension
--     vim.print("inside vscode neovim")
-- else
-- end

-- Install packer
local install_path = vim.fn.stdpath("data") .. "/site/pack/packer/start/packer.nvim"
local is_bootstrap = false
if vim.fn.empty(vim.fn.glob(install_path)) > 0 then
    is_bootstrap = true
    vim.fn.system({ "git", "clone", "--depth", "1", "https://github.com/wbthomason/packer.nvim", install_path })
    vim.cmd([[packadd packer.nvim]])
end

-- start of plugins, maybe refactor into its own .lua someday
require("packer").startup(function(use)
    -- Packer can manage itself
    use("wbthomason/packer.nvim")

    use("nvim-lua/plenary.nvim")
    use("kyazdani42/nvim-web-devicons")
    use("jose-elias-alvarez/null-ls.nvim")
    use("lewis6991/gitsigns.nvim")

    -- completion
    use("jayp0521/mason-null-ls.nvim")

    use({ -- LSP Configuration & Plugins
        "neovim/nvim-lspconfig",
        requires = {
            -- Automatically install LSPs to stdpath for neovim
            "williamboman/mason.nvim",
            "williamboman/mason-lspconfig.nvim",

            -- Useful status updates for LSP
            -- "j-hui/fidget.nvim",

            -- Additional lua configuration, makes nvim stuff amazing
            "folke/neodev.nvim",
        },
    })
    use { "rcarriga/nvim-dap-ui", requires = { "mfussenegger/nvim-dap" } }
    use { 'mfussenegger/nvim-dap-python', requires = { "mfussenegger/nvim-dap" } }
    use { "nvim-telescope/telescope-dap.nvim" }
    use { 'theHamsta/nvim-dap-virtual-text' }
    -- use("SmiteshP/nvim-navic")
    use({ -- Autocompletion
        "hrsh7th/nvim-cmp",
        requires = {
            "hrsh7th/cmp-nvim-lsp",
            "L3MON4D3/LuaSnip",
            "saadparwaiz1/cmp_luasnip",
            "hrsh7th/cmp-buffer",
            "hrsh7th/cmp-path",
            "hrsh7th/cmp-cmdline",
        },
    })
    use("onsails/lspkind-nvim")
    use("windwp/nvim-autopairs")

    -- file management
    use({ "junegunn/fzf", run = ":call fzf#install()" })
    use("junegunn/fzf.vim")
    use("tpope/vim-fugitive")
    use("tpope/vim-rhubarb")
    use("tpope/vim-eunuch")
    use("tpope/vim-sleuth")
    use("majutsushi/tagbar")

    -- usability
    use("numToStr/Comment.nvim")
    use { 'stevearc/dressing.nvim' }
    use("nvim-telescope/telescope.nvim")
    use({ "nvim-telescope/telescope-fzf-native.nvim", run = "make" })
    -- use({ "~/src/telescope-file-browser.nvim" })
    use({ "nvim-telescope/telescope-file-browser.nvim" })
    use { 'nvim-telescope/telescope-ui-select.nvim',
        config = function()
            require("telescope").load_extension("ui-select")
        end
    }
    use {
        "nvim-telescope/telescope-frecency.nvim",
        config = function()
            require("telescope").load_extension "frecency"
        end,
    }
    use { "lukas-reineke/indent-blankline.nvim" }
    use("tpope/vim-repeat")
    -- use 'tpope/vim-rsi'
    use("tpope/vim-unimpaired")
    use("echasnovski/mini.nvim")
    use("famiu/bufdelete.nvim")
    use("vim-test/vim-test")
    use {
        "nvim-neotest/neotest",
        requires = {
            "nvim-lua/plenary.nvim",
            "antoinemadec/FixCursorHold.nvim",
            "nvim-treesitter/nvim-treesitter",
            "nvim-neotest/neotest-python",
        }
    }
    use("mhinz/vim-grepper")
    -- use 'romainl/vim-qf'
    use("stefandtw/quickfix-reflector.vim")
    use("junegunn/vim-easy-align")
    use("nelstrom/vim-visual-star-search")

    use("AndrewRadev/splitjoin.vim")

    -- ui
    -- use("karb94/neoscroll.nvim")
    use("rcarriga/nvim-notify")
    use({
        "nvim-treesitter/nvim-treesitter",
        run = ":TSUpdate",
    })
    use({ "nvim-treesitter/nvim-treesitter-textobjects", after = { "nvim-treesitter" } })
    use("RRethy/nvim-base16")
    -- use 'chriskempson/base16-vim'
    use("marko-cerovac/material.nvim")
    use("navarasu/onedark.nvim")
    use("daschw/leaf.nvim")
    use("EdenEast/nightfox.nvim")
    use("sainnhe/sonokai")
    use({
        "nvim-lualine/lualine.nvim",
        requires = { "kyazdani42/nvim-web-devicons", opt = true },
    })
    use("psliwka/termcolors.nvim")
    use("akinsho/toggleterm.nvim")
    use("folke/lsp-colors.nvim")
    use("lewis6991/impatient.nvim")
    use("monkoose/matchparen.nvim")
    use("folke/which-key.nvim")

    -- other languages
    use({ "plasticboy/vim-markdown", ft = { "markdown" } })
    use({
        "iamcco/markdown-preview.nvim",
        run = function()
            vim.fn["mkdp#util#install"]()
        end,
    })
    use({ "rust-lang/rust.vim", ft = { "rust" } })
    use("neoclide/jsonc.vim")

    if is_bootstrap then
        require("packer").sync()
    end
end)

if is_bootstrap then
    print("==================================")
    print("    Plugins are being installed")
    print("    Wait until Packer completes,")
    print("       then restart nvim")
    print("==================================")
    return
end

-- [[ Setting options ]]
-- See `:help vim.o`

-- Enable mouse mode
vim.o.mouse = "a"

-- Make line numbers default
vim.wo.number = true

-- Enable break indent
vim.o.breakindent = true

-- Save undo history
vim.o.undofile = true

-- Case insensitive searching UNLESS /C or capital in search
vim.o.ignorecase = true
vim.o.smartcase = true

-- Decrease update time
vim.o.updatetime = 250
vim.wo.signcolumn = "yes"

-- make splits more intuitive
vim.o.splitbelow = true
vim.o.splitright = true

-- make line-global replacements the default
vim.o.gdefault = true

-- enforce we are doing mac/linux files
vim.o.fileformat = "unix"

-- link to system clipboard
vim.o.clipboard = "unnamed"

-- diff
vim.o.diffopt = 'internal,algorithm:patience,indent-heuristic'

-- fold settings
vim.o.foldmethod = "indent"
vim.o.foldlevelstart = 99

-- don't redraw during macros
vim.o.lazyredraw = true
vim.o.cursorline = true

-- disable preview window
vim.o.pumheight = 30
vim.o.hidden = true

vim.o.autoread = true

vim.o.inccommand = "nosplit"

-- Set colorscheme
vim.o.termguicolors = true
vim.cmd([[colorscheme nightfox]])

-- Set completeopt to have a better completion experience
vim.o.completeopt = "menu,menuone,noselect"

-- [[ Basic Keymaps ]]
-- Set <space> as the leader key
-- See `:help mapleader`
--  NOTE: Must happen before plugins are required (otherwise wrong leader will be used)
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- Keymaps for better default experience
-- See `:help vim.keymap.set()`
vim.keymap.set({ "n", "v" }, "<Space>", "<Nop>", { silent = true })

-- Remap for dealing with word wrap
vim.keymap.set('n', 'k', "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true })
vim.keymap.set('n', 'j', "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true })

-- add line text object
vim.keymap.set("x", "il", "g_o^")
vim.keymap.set("o", "il", ":normal vil<CR>")

-- improved repeatibility
vim.keymap.set("v", "Q", ":normal @q<CR>")
vim.keymap.set("n", "Q", "@q")
vim.keymap.set("v", ".", ":normal .<CR>")

-- hop to the beginning and ends of line easily
vim.keymap.set("n", "H", "^")
vim.keymap.set("n", "L", "$")

-- highlight pasted text
vim.keymap.set("n", "gp", "`[v`]")

-- paste from the copy buffer
vim.keymap.set("v", "x", "0p")

-- search options
vim.keymap.set("n", "n", "nzz")
vim.keymap.set("n", "N", "Nzz")

-- zoom in function to take a split to the full screen
vim.keymap.set("n", "<C-w>z", ":tab split<CR>")

-- Remap tab/s-tab to change... tabs
vim.keymap.set("n", "<TAB>", "gt")
vim.keymap.set("n", "<S-TAB>", "gT")
vim.keymap.set("n", "<C-I>", "<C-I>")

-- match word-deletion to macOS
vim.keymap.set("i", "<A-BS>", "<C-W>")

-- clear highlighting
vim.keymap.set("n", "<C-/>", ":nohlsearch<CR>", { silent = true })
vim.keymap.set("t", "<C-/>", "<C-\\><C-N>:nohlsearch<CR>a", { silent = true })

-- clear things, like highlight
vim.keymap.set("n", "<C-[>", function()
    vim.cmd("nohlsearch")
end)

-- make saving easier
vim.keymap.set("n", "<C-s>", ":w<CR>")
vim.keymap.set("i", "<C-s>", "<c-o>:w<CR>")
vim.keymap.set("v", "<C-s>", "<esc>:w<CR>gv")

-- readline-esque bindings
vim.keymap.set("i", "<C-a>", "<c-o>^")
vim.keymap.set("i", "<C-b>", "<Left>")
vim.keymap.set("i", "<C-d>", "<Del>")
vim.keymap.set("i", "<C-e>", "<c-o>$")
vim.keymap.set("i", "<C-f>", "<Right>")
vim.keymap.set("c", "<C-a>", "<Home>")
vim.keymap.set("c", "<C-b>", "<Left>")
vim.keymap.set("c", "<C-d>", "<Del>")
vim.keymap.set("c", "<C-e>", "<End>")
vim.keymap.set("c", "<C-f>", "<Right>")

-- allow indent/dedent now that we've clobbered ctrl-d
vim.keymap.set("i", "<C-s-t>", "<c-d>")

-- maps for "normal" buffers only, to exclude mappings in telescope, etc
local normalbuf = vim.api.nvim_create_augroup('normalbuf', { clear = true })
vim.api.nvim_create_autocmd("BufEnter", {
    group = normalbuf,
    callback = function(args)
        local buf = vim.bo[args.buf]
        if buf.filetype == "fugitive" then
            vim.wo.foldmethod = "syntax"
            vim.keymap.set("n", "<C-p>", "[c", { buffer = args.buf, remap = true })
            vim.keymap.set("n", "<C-n>", "]c", { buffer = args.buf, remap = true })
            -- print(string.format('inside fugitive: %s', vim.inspect(buf.filetype)))
            return
        end
        if buf.buftype ~= '' then return end

        -- change last-searched word, with no register-clobbering issues
        vim.keymap.set("n", "c/", ":%s//<C-r>=@/<CR>/g<left><left>", { buffer = args.buf })
        -- vim.keymap.set("n", "c/", ":%s///g<left><left>", { buffer = args.buf })
    end
})

-- general leader commands
vim.keymap.set("n", "<leader>c", ":let @+ = expand('%')<CR>", { silent = true })
vim.keymap.set("n", "<leader>l", ":redraw!<CR>", { silent = true })

-- neovim remote
vim.env.EDITOR = "nvr -cc split --remote-wait +'set bufhidden=wipe'"
vim.env.VISUAL = "nvr -cc split --remote-wait +'set bufhidden=wipe'"

-- terminal
require("toggleterm").setup{
    shade_terminals = false,
}
vim.keymap.set("n", "<C-w>t", ":tabnew <bar> :terminal<CR>a")
vim.keymap.set("n", "<C-w>-", ":ToggleTerm direction=horizontal<CR>")
vim.keymap.set({"n", "i", "t"}, "<C-;>", "<Cmd>ToggleTerm direction=float<CR>")

function _G.set_terminal_keymaps()
    local opts = { buffer = 0 }
    vim.keymap.set('t', '<esc>', [[<C-\><C-n>]], opts)
    vim.keymap.set('t', '<C-h>', [[<Cmd>wincmd h<CR>]], opts)
    vim.keymap.set('t', '<C-j>', [[<Cmd>wincmd j<CR>]], opts)
    vim.keymap.set('t', '<C-k>', [[<Cmd>wincmd k<CR>]], opts)
    vim.keymap.set('t', '<C-l>', [[<Cmd>wincmd l<CR>]], opts)
    vim.keymap.set("n", "<C-e>", ":startinsert<CR><C-e>", opts)
    vim.keymap.set("n", "<C-a>", ":startinsert<CR><C-a>", opts)
    vim.keymap.set("t", "<M-[>", "<esc>")
end

vim.cmd('autocmd! TermOpen term://* lua set_terminal_keymaps()')

vim.keymap.set("i", "<C-h>", "<C-\\><C-N><C-w>h")
vim.keymap.set("i", "<C-j>", "<C-\\><C-N><C-w>j")
vim.keymap.set("i", "<C-k>", "<C-\\><C-N><C-w>k")
vim.keymap.set("i", "<C-l>", "<C-\\><C-N><C-w>l")
vim.keymap.set("n", "<C-h>", "<C-w>h")
vim.keymap.set("n", "<C-j>", "<C-w>j")
vim.keymap.set("n", "<C-k>", "<C-w>k")
vim.keymap.set("n", "<C-l>", "<C-w>l")
vim.keymap.set("v", "<C-h>", "<esc><C-w>h")
vim.keymap.set("v", "<C-j>", "<esc><C-w>j")
vim.keymap.set("v", "<C-k>", "<esc><C-w>k")
vim.keymap.set("v", "<C-l>", "<esc><C-w>l")

-- vim-grepper
vim.keymap.set({ "n", "x" }, "gs", "<plug>(GrepperOperator)")
-- TODO this seems to break
-- vim.g.grepper.highlight = 1
-- vim.g.grepper.tools = { "rg" }

-- vim-test
vim.keymap.set("n", "<leader>r", ":TestNearest<CR>", { silent = true })
vim.keymap.set("n", "<leader>R", ":TestFile<CR>", { silent = true })

-- neotest
require("neotest").setup({
    adapters = {
        require("neotest-python")
    }
})

-- easyalign
vim.keymap.set({ "n", "x" }, "ga", "<Plug>(EasyAlign)")

-- vim-fugitive
vim.keymap.set("n", "<leader>gdm", function() -- diffsplit against main
    local branch = vim.fn.system("git default-branch")
    return string.format(":Gvdiffsplit %s:%%<CR>", branch)
end, { expr = true, silent = true })

vim.keymap.set("n", "<leader>gg", ":tab Git<cr>")
vim.keymap.set("n", "<leader>gdd", ":Gdiffsplit<cr>")
vim.keymap.set("n", "<leader>gb", ":Git blame<cr>")
vim.keymap.set("n", "<leader>ga", ":Gwrite<cr>")
vim.keymap.set("n", "<leader>gp", ":Git push<cr>")
vim.keymap.set("n", "<leader>gh", "V:GBrowse<cr>")
vim.keymap.set("v", "<leader>gh", ":GBrowse<cr>")

-- reload init.lua file
local vimrcPath = vim.fn.expand("$MYVIMRC")
local sourceVimrcCmd = string.format(":source %s | PackerInstall<CR>", vimrcPath)
vim.keymap.set("n", "<leader>sl", sourceVimrcCmd)   -- <leader> Source Lua
vim.keymap.set("n", "<leader>ll", ":luafile %<CR>") -- <leader> Lua Lua

-- for the life of me, I can't help but hit <C-c> when cancelling
-- a vim.ui.input, which breaks things in a few plugins I have.
-- this is a fine workaround until https://github.com/neovim/neovim/issues/18144
-- https://vim.fandom.com/wiki/Avoid_the_escape_key
-- vim.keymap.set("c", "<C-c>", "<C-c>", { remap = true, silent = true })

-- [[ Highlight on yank ]]
-- See `:help vim.highlight.on_yank()`
local highlight_group = vim.api.nvim_create_augroup("YankHighlight", { clear = true })
vim.api.nvim_create_autocmd("TextYankPost", {
    callback = function()
        vim.highlight.on_yank({ higroup = "IncSearch" })
    end,
    group = highlight_group,
    pattern = "*",
})

vim.filetype.add({
    { pattern = "tsconfig.json", "jsonc" },
    { pattern = "Tiltfile",      "bzl" },
})
-- FileType autocmds
vim.api.nvim_create_autocmd("FileType", {
    callback = function(ev)
        local buf = vim.bo[ev.buf]
        if buf.filetype == "json" then
            vim.opt_local.formatprg = "python3 -m json.tool"
        elseif buf.filetype == "xml" then
            vim.opt_local.formatprg = "xmllint --format -"
        elseif buf.filetype == "crontab" then
            vim.opt_local.backup = false
            vim.opt_local.writebackup = false
        elseif buf.filetype == "go" then
            vim.opt_local.expandtab = false
        end
    end
})

-- reload external changes
vim.api.nvim_create_autocmd({ "FocusGained", "BufEnter" }, { command = "if mode() != 'c' | checktime | endif" })

-- status and window bars
vim.opt.laststatus = 3


-- generate ctags for bazel
vim.opt.tags = '.tags'
function MTags()
    vim.cmd [[!/opt/homebrew/bin/ctags --langmap=python:.BUILD,python:.bzl -f .tags --languages=python --exclude=.git -R bzl services]]
end

vim.keymap.set("n", "<leader>mt", MTags)

require("ibl").setup()
require("lualine").setup()
require("Comment").setup()

require("dapui").setup()
local function setupDapPython()
    local debugpy_venv_name = "debugpy_venv"
    local debugpy_venv_dir = vim.fn.stdpath("data") .. "/" .. debugpy_venv_name
    local venv_exists = vim.fn.isdirectory(debugpy_venv_dir) == 1
    if not venv_exists then
        cmd = string.format("cd %s; python3 -m venv %s; source %s/bin/activate; pip install debugpy",
            vim.fn.stdpath("data"), debugpy_venv_dir, debugpy_venv_name)
        vim.fn.system(cmd)
    end
    require('dap-python').setup(debugpy_venv_dir)
end
setupDapPython()
require('telescope').load_extension('dap')
-- require("neoscroll").setup()


require("gitsigns").setup({
    on_attach = function(bufnr)
        local gs = package.loaded.gitsigns

        local function map(mode, l, r, opts)
            opts = opts or {}
            opts.buffer = bufnr
            vim.keymap.set(mode, l, r, opts)
        end

        -- Navigation
        map("n", "]c", function()
            if vim.wo.diff then
                return "]c"
            end
            vim.schedule(function()
                gs.next_hunk()
            end)
            return "<Ignore>"
        end, { expr = true })

        map("n", "[c", function()
            if vim.wo.diff then
                return "[c"
            end
            vim.schedule(function()
                gs.prev_hunk()
            end)
            return "<Ignore>"
        end, { expr = true })

        -- Text object
        map({ "o", "x" }, "ih", ":<C-U>Gitsigns select_hunk<CR>")
    end,
})

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

-- [[ Configure Treesitter ]]
-- See `:help nvim-treesitter`
require("nvim-treesitter.configs").setup({
    -- Add languages to be installed here that you want installed for treesitter
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
        "vimdoc",
        "regex",
        "json",
        "json5",
        "rust",
        "terraform",
    },

    highlight = { enable = true },
    indent = { enable = true },
    incremental_selection = {
        enable = true,
        keymaps = {
            init_selection = "<CR>",
            node_incremental = "<CR>",
            -- TODO: I'm not sure for this one.
            scope_incremental = "<c-s>",
            node_decremental = "<S-CR>",
        },
    },
    textobjects = {
        select = {
            enable = true,
            lookahead = true, -- Automatically jump forward to textobj, similar to targets.vim
            keymaps = {
                -- You can use the capture groups defined in textobjects.scm
                ["af"] = "@function.outer",
                ["if"] = "@function.inner",
                ["ac"] = "@class.outer",
                ["ic"] = "@class.inner",
                ["aa"] = "@parameter.outer",
                ["ia"] = "@parameter.inner",
            },
        },
        move = {
            enable = true,
            set_jumps = true, -- whether to set jumps in the jumplist
            goto_next_start = {
                ["]a"] = "@parameter.inner",
                ["]f"] = "@function.outer",
                ["]]"] = "@class.outer",
            },
            goto_next_end = {
                ["]M"] = "@function.outer",
                ["]["] = "@class.outer",
            },
            goto_previous_start = {
                ["[a"] = "@parameter.inner",
                ["[f"] = "@function.outer",
                ["[["] = "@class.outer",
            },
            goto_previous_end = {
                ["[M"] = "@function.outer",
                ["[]"] = "@class.outer",
            },
        },
        swap = {
            enable = true,
            swap_next = {
                [">,"] = "@parameter.inner",
            },
            swap_previous = {
                ["<,"] = "@parameter.inner",
            },
        },
    },
})

require("nvim-autopairs").setup()
vim.cmd("set termguicolors")
require("onedark").setup({
    style = "darker",
    toggle_style_key = "<leader>to",
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

-- nvim-cmp {{{
local cmp = require("cmp")
---@cast cmp -?
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

-- Use buffer source for `/` and `?` (if you enabled `native_menu`, this won't work anymore).
cmp.setup.cmdline({ "/", "?" }, {
    mapping = cmp.mapping.preset.cmdline(),
    sources = {
        { name = "buffer" },
    },
})

-- -- Use cmdline & path source for ':'
local cmdline_mapping = cmp.mapping.preset.cmdline()
local fb = function(fallback)
    fallback()
end
cmdline_mapping["<C-P>"] = fb
cmdline_mapping["<C-N>"] = fb
cmp.setup.cmdline(":", {
    mapping = cmdline_mapping,
    sources = cmp.config.sources({
        { name = "path" },
    }, {
        { name = "cmdline" },
    }),
})

-- automatically insert parens for methods/functions
local cmp_autopairs = require("nvim-autopairs.completion.cmp")
cmp.event:on("confirm_done", cmp_autopairs.on_confirm_done())

-- }}}

-- START LSP {{{
require("mason").setup()
require("mason-lspconfig").setup()
local lsp = require("lspconfig")
lsp.gopls.setup {}
lsp.rust_analyzer.setup {}
lsp.tsserver.setup {}
lsp.terraformls.setup {}
lsp.ccls.setup {}

local libraries = vim.api.nvim_get_runtime_file("", true)
table.insert(libraries, string.format("%s/hammerspoon/Spoons/EmmyLua.spoon/annotations", vim.env.XDG_CONFIG_HOME))
lsp.lua_ls.setup({
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
                -- Make the server aware of Neovim runtime files
                library = libraries,
            },
            -- Do not send telemetry data containing a randomized but unique identifier
            telemetry = {
                enable = false,
            },
        },
    },
})
lsp.jsonls.setup {
    settings = {
        jsonls = {
            filetypes = { "json", "jsonc" },
            settings = {
                json = {
                    -- Schemas https://www.schemastore.org
                    schemas = {
                        {
                            fileMatch = { "package.json" },
                            url = "https://json.schemastore.org/package.json"
                        },
                        {
                            fileMatch = { "tsconfig*.json" },
                            url = "https://json.schemastore.org/tsconfig.json"
                        },
                    }
                }
            }
        },
    }
}

local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities.textDocument.publishDiagnostics.tagSupport.valueSet = { 2 }
lsp.pyright.setup { capabilities = capabilities }

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

-- Global mappings.
-- See `:help vim.diagnostic.*` for documentation on any of the below functions
vim.keymap.set('n', '<space>e', vim.diagnostic.open_float)
vim.keymap.set('n', '[d', vim.diagnostic.goto_prev)
vim.keymap.set('n', ']d', vim.diagnostic.goto_next)
vim.keymap.set('n', '<space>q', vim.diagnostic.setloclist)
vim.keymap.set('n', 'gf', function()
    vim.lsp.buf.format { async = true }
end)


vim.api.nvim_create_autocmd('LspAttach', {
    group = vim.api.nvim_create_augroup('UserLspConfig', {}),
    callback = function(ev)
        -- Enable completion triggered by <c-x><c-o>
        vim.bo[ev.buf].omnifunc = 'v:lua.vim.lsp.omnifunc'

        -- null-ls generally doesn't implement the below functions;
        -- escape early to not apply keybinds
        local client = vim.lsp.get_client_by_id(ev.data.client_id)
        if client.name == "null-ls" then
            return
        end

        -- Buffer local mappings.
        -- See `:help vim.lsp.*` for documentation on any of the below functions
        local opts = { buffer = ev.buf }
        vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, opts)
        vim.keymap.set('n', 'gd', vim.lsp.buf.definition, opts)
        vim.keymap.set('n', '<c-]>', vim.lsp.buf.definition, opts)
        vim.keymap.set('n', 'K', vim.lsp.buf.hover, opts)
        vim.keymap.set('n', '<space>wa', vim.lsp.buf.add_workspace_folder, opts)
        vim.keymap.set('n', '<space>wr', vim.lsp.buf.remove_workspace_folder, opts)
        vim.keymap.set('n', '<space>wl', function()
            print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
        end, opts)
        vim.keymap.set('n', '<space>D', vim.lsp.buf.type_definition, opts)
        vim.keymap.set('n', '<space>rn', vim.lsp.buf.rename, opts)
        vim.keymap.set({ 'n', 'v' }, '<space>ca', vim.lsp.buf.code_action, opts)
        vim.keymap.set('n', 'gr', vim.lsp.buf.references, opts)
    end,
})

require("null-ls").setup({
    sources = {
        -- require("null-ls").builtins.formatting.stylua.with({
        --     extra_args = { "--indent-type", "Spaces" },
        -- }),
        -- require("null-ls").builtins.diagnostics.luacheck.with({
        --     extra_args = { "--config", vim.fn.expand("$XDG_CONFIG_HOME/luacheck/.luacheckrc") },
        -- }),
        -- require("null-ls").builtins.diagnostics.mypy.with({
        --     extra_args = { "--ignore-missing-imports" },
        -- }),
        require("null-ls").builtins.diagnostics.shellcheck,
        require("null-ls").builtins.formatting.trim_whitespace,

        -- python
        require("null-ls").builtins.diagnostics.ruff,
        require("null-ls").builtins.formatting.ruff,
        require("null-ls").builtins.formatting.black,
        require("null-ls").builtins.formatting.isort,
        require("null-ls").builtins.diagnostics.buildifier,
        require("null-ls").builtins.formatting.buildifier,
    },
})
require("mason-null-ls").setup({
    -- ensure_installed = nil,
    automatic_installation = true,
})

-- DEBUGGING LSP
-- vim.lsp.set_log_level("debug")
-- :lua vim.cmd('e'..vim.lsp.get_log_path())

-- }}} END LSP

-- Setup neovim lua configuration
require("neodev").setup()

-- nvim-cmp supports additional completion capabilities, so broadcast that to servers
local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities = require("cmp_nvim_lsp").default_capabilities(capabilities)

-- Turn on lsp status information
-- require("fidget").setup()

-- telescope {{{
-- indiviual pickers are in telescope.lua
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
            scroll_strategy = "limit",
            mappings = {
                ["n"] = {
                    ["h"] = fb_actions.goto_parent_dir,
                    ["l"] = actions.select_default,
                    ["q"] = actions.close,
                    ["<C-D>"] = actions.results_scrolling_down,
                    ["<C-U>"] = actions.results_scrolling_up,
                },
            },
        },
        frecency = {
            default_workspace = "CWD",
            show_unindexed = true,
            auto_validate = false,
        }
    },
})
require("telescope").load_extension("fzf")
require("telescope").load_extension("file_browser")
-- require("telescope").extensions.frecency.frecency {
--   sorter = require("telescope.sorters").fuzzy_with_index_bias()
-- }
vim.keymap.set("n", "-", ":Telescope file_browser path=%:p:h select_buffer=true<CR>")
-- vim.keymap.set("n", "<C-p>", "<Cmd>lua require('telescope_custom').project_files()<CR>")
vim.keymap.set("n", "<C-p>", "<Cmd>Telescope frecency<CR>")
vim.keymap.set("n", "<leader>p", "<Cmd>lua require('telescope_custom').src_dir()<CR>")
vim.keymap.set("n", "q:", require("telescope.builtin").command_history)
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

-- common typos
vim.api.nvim_create_user_command("Qa", "qa", { bang = true })
vim.api.nvim_create_user_command("QA", "qa", { bang = true })
vim.api.nvim_create_user_command("Wq", "wq", { bang = true })
vim.api.nvim_create_user_command("WQ", "wq", { bang = true })
vim.api.nvim_create_user_command("Wqa", "wqa", { bang = true })
vim.api.nvim_create_user_command("WQa", "wqa", { bang = true })
-- }}}

vim.cmd("runtime vimscript/init.vim")

if vim.env.WSL_DISTRO_NAME then
    vim.g.netrw_browsex_viewer = 'cmd.exe /c start ""'
end

require("matchparen").setup({})
-- require("which-key").setup()

require("mini.ai").setup({
    mappings = {
        around_next = "",
        inside_next = "",
        around_last = "",
        inside_last = "",
    },
})
require("mini.surround").setup({})
vim.keymap.set("n", "<C-q>", ":Bdelete<CR>")

return M
