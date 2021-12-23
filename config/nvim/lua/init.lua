local M = {}
local nvim_lsp = require('lspconfig')
local map = vim.api.nvim_set_keymap

require('gitsigns').setup()
-- Use an on_attach function to only map the following keys
-- after the language server attaches to the current buffer
local on_attach = function(client, bufnr) -- luacheck: ignore
    local function buf_set_keymap(...)
        vim.api.nvim_buf_set_keymap(bufnr, ...)
    end
    local function buf_set_option(...)
        vim.api.nvim_buf_set_option(bufnr, ...)
    end

    -- Enable completion triggered by <c-x><c-o>
    buf_set_option('omnifunc', 'v:lua.vim.lsp.omnifunc')

    -- Mappings.
    local opts = {noremap = true, silent = true}

    -- See `:help vim.lsp.*` for documentation on any of the below functions
    -- buf_set_keymap('n', 'gD', '<Cmd>lua vim.lsp.buf.declaration()<CR>', opts)
    buf_set_keymap('n', '<C-]>', '<Cmd>lua vim.lsp.buf.definition()<CR>', opts)
    buf_set_keymap('n', 'K', '<Cmd>lua vim.lsp.buf.hover()<CR>', opts)
    -- buf_set_keymap('n', 'gi', '<cmd>lua vim.lsp.buf.implementation()<CR>', opts)
    -- buf_set_keymap('n', '<C-k>', '<cmd>lua vim.lsp.buf.signature_help()<CR>', opts)
    -- buf_set_keymap('n', '<leader>wa', '<cmd>lua vim.lsp.buf.add_workspace_folder()<CR>', opts)
    -- buf_set_keymap('n', '<leader>wr', '<cmd>lua vim.lsp.buf.remove_workspace_folder()<CR>', opts)
    -- buf_set_keymap('n', '<leader>wl', '<cmd>lua print(vim.inspect(vim.lsp.buf.list_workspace_folders()))<CR>', opts)
    -- buf_set_keymap('n', '<leader>rn', '<cmd>lua vim.lsp.buf.rename()<CR>', opts)
    -- buf_set_keymap('n', '<leader>ca', '<cmd>lua vim.lsp.buf.code_action()<CR>', opts)
    buf_set_keymap('n', 'gr', '<cmd>lua vim.lsp.buf.references()<CR>', opts)
    buf_set_keymap('n', '<leader>e',
                   '<cmd>lua vim.lsp.diagnostic.show_line_diagnostics()<CR>',
                   opts)
    buf_set_keymap('n', '[d', '<cmd>lua vim.lsp.diagnostic.goto_prev()<CR>',
                   opts)
    buf_set_keymap('n', ']d', '<cmd>lua vim.lsp.diagnostic.goto_next()<CR>',
                   opts)
    -- buf_set_keymap('n', '<leader>q', '<cmd>lua vim.lsp.diagnostic.set_loclist()<CR>', opts)
    -- buf_set_keymap("n", "<leader>f", "<cmd>lua vim.lsp.buf.formatting()<CR>", opts)

    buf_set_keymap('n', 'gf', '<cmd>lua vim.lsp.buf.formatting_seq_sync()<CR>',
                   opts)
    -- vim.api
    --     .nvim_command [[autocmd BufWritePre <buffer> lua vim.lsp.buf.formatting()]]

end
-- to debug do this:
vim.lsp.set_log_level("debug")
-- :lua vim.cmd('e'..vim.lsp.get_log_path())

-- Use a loop to conveniently call 'setup' on multiple servers and
-- map buffer local keybindings when the language server attaches

local servers = {"pylsp", "tsserver", "gopls", "rust_analyzer"}
for _, lsp in ipairs(servers) do
    nvim_lsp[lsp].setup {
        on_attach = on_attach,
        flags = {debounce_text_changes = 150},
        settings = {pylsp = {configurationSources = {"flake8"}}}
    }
end

-- TODO get clangd working w/ envoy
-- nvim_lsp.clangd.setup {
--     cmd = {"clangd", "--background-index"},
--     on_attach = on_attach
-- }

-- print(vim.inspect(vim.tbl_keys(efmlinters)))
-- nvim_lsp.efm.setup {
--     init_options = {documentFormatting = true},
--     on_attach = on_attach,asdfasdf
--     filetypes = vim.tbl_keys(efmlinters),
--     settings = {rootMarkers = {".git/"}, languages = efmlinters}
-- }
require("null-ls").setup({
        debug = true,
    sources = {
        require("null-ls").builtins.formatting.stylua,
        require("null-ls").builtins.formatting.black,
        require("null-ls").builtins.diagnostics.luacheck.with({
                extra_args = {"--config", vim.fn.expand("$XDG_CONFIG_HOME/luacheck/.luacheckrc")
            }}),
        require("null-ls").builtins.diagnostics.mypy.with({
                extra_args = {"--ignore-missing-imports"}
            }),
        require("null-ls").builtins.formatting.reorder_python_imports,
        require("null-ls").builtins.diagnostics.shellcheck,
        require("null-ls").builtins.formatting.trim_whitespace
    },
    on_attach=on_attach
})


-- vim.lsp.handlers["textDocument/publishDiagnostics"] = function() end
vim.lsp.handlers["textDocument/publishDiagnostics"] = vim.lsp.with(
    vim.lsp.diagnostic.on_publish_diagnostics, {
        -- Enable underline, use default values
        underline = true,
        -- Enable virtual text, override spacing to 4
        virtual_text = {
            spacing = 4,
        },
        -- Disable a feature
        update_in_insert = false,
    }
    )


-- compe
vim.o.completeopt = "menuone,noselect"
require'compe'.setup {
    enabled = true,
    autocomplete = true,
    debug = false,
    min_length = 1,
    preselect = 'enable',
    throttle_time = 80,
    source_timeout = 200,
    resolve_timeout = 800,
    incomplete_delay = 400,
    max_abbr_width = 100,
    max_kind_width = 100,
    max_menu_width = 100,
    documentation = {
        border = {'', '', '', ' ', '', '', '', ' '}, -- the border option is the same as `|help nvim_open_win|`
        winhighlight = "NormalFloat:CompeDocumentation,FloatBorder:CompeDocumentationBorder",
        max_width = 120,
        min_width = 60,
        max_height = math.floor(vim.o.lines * 0.3),
        min_height = 1
    },

    source = {
        path = true,
        buffer = true,
        calc = true,
        nvim_lsp = true,
        nvim_lua = true
    }
}
local t = function(str)
    return vim.api.nvim_replace_termcodes(str, true, true, true)
end

local check_back_space = function()
    local col = vim.fn.col('.') - 1
    return col == 0 or vim.fn.getline('.'):sub(col, col):match('%s') ~= nil
end

-- Use (s-)tab to:
--- move to prev/next item in completion menuone
--- jump to prev/next snippet's placeholder
_G.tab_complete = function()
    if vim.fn.pumvisible() == 1 then
        return t "<C-n>"
    elseif check_back_space() then
        return t "<Tab>"
    else
        return vim.fn['compe#complete']()
    end
end
_G.s_tab_complete = function()
    if vim.fn.pumvisible() == 1 then
        return t "<C-p>"
    else
        -- If <S-Tab> is not working in your terminal, change it to <C-h>
        return t "<S-Tab>"
    end
end

require("telescope").setup({defaults = {preview = false}})
require('telescope').load_extension('fzf')
M.project_files = function()
    local ok = pcall(require"telescope.builtin".git_files, {show_untracked = false})
    if not ok then require"telescope.builtin".find_files() end
end
map('n', '<C-p>',
    "<Cmd>lua require('init').project_files()<CR>",
    {noremap = true})

map("i", "<Tab>", "v:lua.tab_complete()", {expr = true})
map("s", "<Tab>", "v:lua.tab_complete()", {expr = true})
map("i", "<S-Tab>", "v:lua.s_tab_complete()", {expr = true})

return M
