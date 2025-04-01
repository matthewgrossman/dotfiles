vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

-- Set to true if you have a Nerd Font installed and selected in the terminal
vim.g.have_nerd_font = true

-- Make line numbers default
vim.opt.number = true

-- Enable mouse mode, can be useful for resizing splits for example!
vim.opt.mouse = 'a'

-- Don't show the mode, since it's already in the status line
vim.opt.showmode = false

vim.schedule(function()
  vim.opt.clipboard = 'unnamedplus'
end)

-- Enable break indent
vim.opt.breakindent = true

-- Default tab settings, which might be overwritten via
-- `vim-sleuth` or other plugins
vim.opt.expandtab = true
vim.opt.shiftwidth = 2
vim.opt.tabstop = 4

-- Save undo history
vim.opt.undofile = true
vim.opt.backupdir = vim.fn.stdpath('state') .. '/backup'

-- Case-insensitive searching UNLESS \C or one or more capital letters in the search term
vim.opt.ignorecase = true
vim.opt.smartcase = true

-- don't show the keybind at the bottom right
vim.opt.showcmd = false

-- Keep signcolumn on by default
vim.opt.signcolumn = 'yes'

-- Decrease update time
vim.opt.updatetime = 250

-- Decrease mapped sequence wait time
-- Displays which-key popup sooner
vim.opt.timeoutlen = 300

-- Configure how new splits should be opened
vim.opt.splitright = true
vim.opt.splitbelow = true

vim.opt.list = true
vim.opt.listchars = { tab = '» ', trail = '·', nbsp = '␣' }

-- Preview substitutions live, as you type!
vim.opt.inccommand = 'nosplit'
vim.opt.autoread = true

-- Show which line your cursor is on
vim.opt.cursorline = true

-- Set floating window border
-- vim.opt.winborder = 'rounded'

-- Minimal number of screen lines to keep above and below the cursor.
vim.opt.scrolloff = 10

-- MG custom opts begin {{{
-- vim.opt.smarttab = true
-- vim.opt.expandtab = true
-- vim.opt.tabstop = 2
-- vim.opt.shiftwidth = 2
-- vim.opt.softtabstop = 2

vim.opt.fileformat = 'unix'
vim.opt.diffopt:append({ 'algorithm:patience', 'indent-heuristic', 'linematch:60' })
vim.opt.termguicolors = true

-- }}}

-- [[ Basic Keymaps ]]
--  See `:help vim.keymap.set()`

-- clear things, like highlight
vim.keymap.set('n', '<C-[>', function()
  vim.cmd('nohlsearch')
end)

-- Diagnostic keymaps
vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist, { desc = 'Open diagnostic [Q]uickfix list' })
vim.diagnostic.config({ virtual_text = true, jump = { float = true } })

vim.keymap.set('t', '<Esc><Esc>', '<C-\\><C-n>', { desc = 'Exit terminal mode' })

-- Keybinds to make split navigation easier.
--  Use CTRL+<hjkl> to switch between windows
--
--  See `:help wincmd` for a list of all window commands
vim.keymap.set('n', '<C-h>', '<C-w><C-h>', { desc = 'Move focus to the left window' })
vim.keymap.set('n', '<C-l>', '<C-w><C-l>', { desc = 'Move focus to the right window' })
vim.keymap.set('n', '<C-j>', '<C-w><C-j>', { desc = 'Move focus to the lower window' })
vim.keymap.set('n', '<C-k>', '<C-w><C-k>', { desc = 'Move focus to the upper window' })

-- MG custom commands begin {{{
-- make saving easier
vim.keymap.set('n', '<C-s>', ':w<CR>')
vim.keymap.set('v', '<C-s>', '<esc>:w<CR>gv')

-- improved repeatibility
vim.keymap.set('v', '.', ':normal .<CR>')
vim.keymap.set('v', 'Q', ':normal @q<CR>')
vim.keymap.set('n', 'Q', '@q')

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

-- Remap for dealing with word wrap
vim.keymap.set('n', 'k', "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true })
vim.keymap.set('n', 'j', "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true })

-- allow indent/dedent now that we've clobbered ctrl-d
vim.keymap.set('i', '<C-s-t>', '<c-d>')

-- hop to the beginning and ends of line easily
vim.keymap.set('n', 'H', '^')
vim.keymap.set('n', 'L', '$')

-- match word-deletion to macOS
vim.keymap.set('i', '<A-BS>', '<C-W>')

-- zoom in function to take a split to the full screen
vim.keymap.set('n', '<C-w>z', ':tab split<CR>')

-- highlight pasted text
vim.keymap.set('n', 'gp', '`[v`]')

vim.keymap.set('n', '<leader>c', ":let @+ = expand('%')<CR>", { silent = true })
vim.keymap.set('n', '<leader>C', ":let @+ = expand('%:p')<CR>", { silent = true })

-- vim.keymap.set('n', 'c/', ':%s//<C-r>=@/<CR>/g<left><left>', { silent = true })

vim.keymap.set('n', '<leader>/', function()
  local search_pattern = vim.fn.getreg('/')
  -- Remove word boundary markers
  search_pattern = search_pattern:gsub('\\<', ''):gsub('\\>', ''):gsub('\\V', '')
  local cmd = ':%s//' .. search_pattern .. '/g' .. '<left><left>'
  local escaped = vim.api.nvim_replace_termcodes(cmd, true, true, true)
  vim.api.nvim_feedkeys(escaped, 'n', false)
end, { silent = true })

-- neovim remote
vim.env.EDITOR = "nvr -cc split --remote-wait +'set bufhidden=wipe'"
vim.env.VISUAL = "nvr -cc split --remote-wait +'set bufhidden=wipe'"

vim.cmd.abbreviate('iii', 'breakpoint()')

-- MAJOR HACK; blasting C-c to neovim sometimes causes it to freeze. In wezterm,
-- we remapped C-c to a different keybind, which then neovim will process and re-send
-- C-c to the underlying terminals/buffers.
local allKeymaps = { 'n', 'i', 'v', 'x', 's', 'o', 'c', 't' }
vim.keymap.set(allKeymaps, '<F16>', '<C-c>', { remap = true, silent = true })

function _G.set_terminal_keymaps()
  local opts = { buffer = 0 }
  vim.keymap.set('t', '<esc>', [[<C-\><C-n>]], opts)
  vim.keymap.set('n', '<C-e>', ':startinsert<CR><C-e>', opts)
  vim.keymap.set('n', '<C-a>', ':startinsert<CR><C-a>', opts)
  vim.keymap.set('n', '<C-a>', ':startinsert<CR><C-a>', opts)
  vim.keymap.set('n', '<C-c>', ':startinsert<CR>', opts)
  vim.keymap.set('n', '<C-p>', ':startinsert<CR><C-p>', opts)
  vim.keymap.set('n', '<C-q>', ':terminal<CR>:bd!#<CR>:startinsert<CR>', opts)
  vim.keymap.set('t', '<M-[>', '<esc>')
  vim.keymap.set('t', '<S-CR>', '<C-v><C-j>')
  -- vim.keymap.set('v', 'Y', function()
  -- TODO fix softwrap copying
  --   local region = vim.region(0, "'<", "'>", vim.fn.visualmode(), true)
  -- -- vim.region(0, "v", ".", vim.fn.visualmode(), true)
  --   local text = ""
  --   local maxcol = vim.v.maxcol
  --   for line, cols in vim.spairs(region) do
  --     vim.print(line)
  --     vim.print(cols)
  --     local endcol = cols[2] == maxcol and -1 or cols[2]
  --     local chunk = vim.api.nvim_buf_get_text(0, line, cols[1], line, endcol, {})[1]
  --     local last_char = chunk:sub(-1)
  --     print("Chunk: '" .. chunk .. "'")
  --     print("Last character: '" .. last_char .. "' (ASCII: " .. string.byte(last_char) .. ")")
  --     text = ('%s%s\n'):format(text, chunk)
  --   end
  --   print(text)
  --   vim.fn.setreg('+', text)
  -- end)
  vim.wo.foldmethod = 'manual'
end

vim.cmd('autocmd! TermOpen term://* lua set_terminal_keymaps()')

function _G.file_contains(file_path, search_string)
  local f = io.open(file_path, 'r') -- Open the file in read mode
  if not f then
    return false, 'File not found or could not be opened'
  end

  local content = f:read('*all') -- Read the entire content of the file
  f:close()

  return content:find(search_string, 1, true) ~= nil
end

local function setupPythonVenv()
  local path = vim.fn.stdpath('data') .. '/venv'
  if not (vim.fn.isdirectory(path) == 1) then
    print('Creating new python venv')
    local packages = { 'pynvim', 'debugpy', 'typing_extensions' }
    local cmd = string.format(
      [[
      uv venv %s;
      UV_PYTHON=%s uv pip install %s
      ]],
      path,
      path,
      table.concat(packages, ' ')
    )
    print(string.format('Running cmd:\n%s', cmd))
    local result = vim.system({ 'bash', '-c', cmd }):wait()
    if result.code ~= 0 then
      print('Error setting up Python environment:', result.stderr)
    else
      print('Python environment setup complete!')
    end
  end
  vim.g.python3_host_prog = path .. '/bin/python'
end

setupPythonVenv()

_G.getPythonPath = function()
  local virtual_env = vim.fn.getenv('VIRTUAL_ENV')
  if virtual_env ~= vim.NIL then
    -- if we're explicitly in an active venv, use that python
    return virtual_env .. '/bin/python'
  elseif vim.uv.fs_stat('.venv/bin/python') then
    -- if there's a venv in the cwd, use that
    return '.venv/bin/python'
  else
    -- else use the nvim venv; never use the global python!
    return vim.g.python3_host_prog
  end
end

-- useful helper for snagging the visual selection
_G.get_visual_selection = function()
  return vim.fn.getregion(vim.fn.getpos('.'), vim.fn.getpos('v'), { mode = vim.fn.mode() })
end

vim.api.nvim_create_user_command('Z', 'w | qa', {})
vim.cmd([[
  cabbrev wqa Z
  cabbrev Wqa Z
  cabbrev wqa! Z
]])
-- }}}

-- [[ Basic Autocommands ]]
--  See `:help lua-guide-autocommands`

-- Highlight when yanking (copying) text
--  Try it with `yap` in normal mode
--  See `:help vim.highlight.on_yank()`
vim.api.nvim_create_autocmd('TextYankPost', {
  desc = 'Highlight when yanking (copying) text',
  group = vim.api.nvim_create_augroup('kickstart-highlight-yank', { clear = true }),
  callback = function()
    vim.highlight.on_yank()
  end,
})

-- [[ Install `lazy.nvim` plugin manager ]]
--    See `:help lazy.nvim.txt` or https://github.com/folke/lazy.nvim for more info
local lazypath = vim.fn.stdpath('data') .. '/lazy/lazy.nvim'
if not vim.uv.fs_stat(lazypath) then
  local lazyrepo = 'https://github.com/folke/lazy.nvim.git'
  local out = vim.fn.system({ 'git', 'clone', '--filter=blob:none', '--branch=stable', lazyrepo, lazypath })
  if vim.v.shell_error ~= 0 then
    error('Error cloning lazy.nvim:\n' .. out)
  end
end ---@diagnostic disable-next-line: undefined-field
vim.opt.rtp:prepend(lazypath)

-- [[ Configure and install plugins ]]
--
--  To check the current status of your plugins, run
--    :Lazy
--
--  You can press `?` in this menu for help. Use `:q` to close the window
--
--  To update plugins you can run
--    :Lazy update
--
-- NOTE: Here is where you install your plugins.
require('lazy').setup({
  -- NOTE: Plugins can be added with a link (or for a github repo: 'owner/repo' link).
  'tpope/vim-sleuth', -- Detect tabstop and shiftwidth automatically
  'tpope/vim-repeat',
  {
    'stevearc/quicker.nvim',
    event = 'FileType qf',
    config = function()
      require('quicker').setup()
      vim.keymap.set('n', '<leader>q', function()
        require('quicker').toggle()
      end, {
        desc = 'Toggle quickfix',
      })
    end,
  },
  {
    'akinsho/toggleterm.nvim',
    config = function()
      local percent = 0.95
      require('toggleterm').setup({
        auto_scroll = false,
        float_opts = {
          width = function()
            return math.floor(vim.o.columns * percent)
          end,
          height = function()
            return math.floor((vim.o.lines - vim.o.cmdheight) * percent)
          end,
        },
      })
      vim.keymap.set({ 't' }, '<C-;>', '<CMD>ToggleTerm<CR>')
      vim.keymap.set({ 'n' }, '<C-;>', '<CMD>ToggleTerm direction=float name=primary<CR>')
      vim.keymap.set({ 'n' }, '<leader>;s', '<CMD>ToggleTerm name=server direction=float<CR>')
    end,
  },
  {
    'tpope/vim-fugitive',
    dependencies = {
      { 'tpope/vim-rhubarb' },
    },
    config = function()
      vim.keymap.set('n', '<leader>gg', ':tab Git<cr>')
      vim.keymap.set('n', '<leader>gdd', ':Gvdiffsplit<cr>')
      vim.keymap.set('n', '<leader>gdm', ':Gvdiffsplit master<cr>')
      vim.keymap.set('n', '<leader>gb', ':Git blame<cr>')
      vim.keymap.set('n', '<leader>ga', ':Gwrite<cr>')
      vim.keymap.set('n', '<leader>gp', ':Git push<cr>')
      vim.keymap.set('n', '<leader>gh', 'V:GBrowse<cr>')
      vim.keymap.set('v', '<leader>gh', ':GBrowse<cr>')
      vim.keymap.set('v', '<leader>gr', ':Git pr<cr>')
    end,
  },
  {
    'vim-test/vim-test',
    config = function()
      local function clipboard_strategy(cmd)
        vim.fn.setreg('+', cmd)
      end

      -- Set up the custom strategy
      vim.g['test#custom_strategies'] = {
        clipboard = clipboard_strategy,
      }

      -- Set the default strategy
      vim.g['test#strategy'] = 'clipboard'
      -- set strategy here
      vim.keymap.set('n', '<leader>r', ':TestNearest<CR>', { silent = true })
      vim.keymap.set('n', '<leader>R', ':TestFile<CR>', { silent = true })
    end,
  },
  {
    'stevearc/oil.nvim',
    opts = {
      view_options = {
        show_hidden = true,
      },
      keymaps = {
        -- ["l"] = "actions.select",
        -- ["h"] = "actions.parent",
        ['<C-h>'] = false,
        ['<C-l>'] = false,
        ['<C-s>'] = false,
        ['<C-r>'] = 'actions.refresh',
        ['<C-\\>'] = { 'actions.select', opts = { vertical = true }, desc = 'Open the entry in a vertical split' },
        ['<C-_>'] = { 'actions.select', opts = { horizontal = true }, desc = 'Open the entry in a horizontal split' },
      },
      git = {
        -- Return true to automatically git add/mv/rm files
        add = function(_)
          return true
        end,
        mv = function(_, _)
          return true
        end,
        rm = function(_)
          return true
        end,
      },
    },
    -- Optional dependencies
    dependencies = { 'nvim-tree/nvim-web-devicons' },
  },
  {
    'lewis6991/gitsigns.nvim',
    opts = {
      signs = {
        add = { text = '+' },
        change = { text = '~' },
        delete = { text = '_' },
        topdelete = { text = '‾' },
        changedelete = { text = '~' },
      },
      on_attach = function(bufnr)
        local gitsigns = require('gitsigns')

        local function map(mode, l, r, opts)
          opts = opts or {}
          opts.buffer = bufnr
          vim.keymap.set(mode, l, r, opts)
        end

        -- Navigation
        map('n', ']c', function()
          if vim.wo.diff then
            vim.cmd.normal({ ']c', bang = true })
          else
            gitsigns.nav_hunk('next')
          end
        end)

        map('n', '[c', function()
          if vim.wo.diff then
            vim.cmd.normal({ '[c', bang = true })
          else
            gitsigns.nav_hunk('prev')
          end
        end)
      end,
    },
  },
  {
    'stevearc/aerial.nvim',
    config = function()
      require('aerial').setup({
        -- optionally use on_attach to set keymaps when aerial has attached to a buffer
        on_attach = function(bufnr)
          -- Jump forwards/backwards with '{' and '}'
          vim.keymap.set('n', '{', '<cmd>AerialPrev<CR>', { buffer = bufnr })
          vim.keymap.set('n', '}', '<cmd>AerialNext<CR>', { buffer = bufnr })
          vim.keymap.set('n', '<leader>t', '<cmd>AerialToggle<CR>', { buffer = bufnr })
        end,
      })
    end,
    -- Optional dependencies
    dependencies = {
      'nvim-treesitter/nvim-treesitter',
      'nvim-tree/nvim-web-devicons',
    },
  },
  { 'towolf/vim-helm', ft = 'helm' },
  {
    'windwp/nvim-autopairs',
    event = 'InsertEnter',
    config = function()
      require('nvim-autopairs').setup({})
      local Rule = require('nvim-autopairs.rule')
      local npairs = require('nvim-autopairs')
      npairs.add_rule(Rule('```', '```', 'codecompanion'))
    end,
  },
  {
    'ibhagwan/fzf-lua',
    -- optional for icon support
    dependencies = { 'nvim-tree/nvim-web-devicons' },
    config = function()
      local actions = require('fzf-lua.actions')
      require('fzf-lua').setup({
        keymap = {
          builtin = {
            'false',
            ['<C-j>'] = 'preview-down',
            ['<C-k>'] = 'preview-up',
            ['<C-h>'] = 'hide',
          },
          fzf = {
            'false',
          },
        },
        winopts = {
          preview = {
            layout = 'vertical',
          },
        },
      })
      vim.keymap.set('n', '<leader>sg', function()
        require('fzf-lua').grep_project({
          fzf_opts = { ['--nth'] = false },
          file_icons = false,
          rg_opts = '--column --line-number --no-heading --color=always --smart-case --max-columns=4096 --hidden --glob "!.git/*" -e',
        })
      end)
    end,
  },
  { 'bazelbuild/vim-bazel', dependencies = { 'google/vim-maktaba' } },
  -- {
  --   'alexander-born/bazel.nvim',
  --   dependencies = {
  --     { 'bazelbuild/vim-bazel', dependencies = { 'google/vim-maktaba' } },
  --     'nvim-treesitter/nvim-treesitter',
  --     'nvim-lua/plenary.nvim',
  --   },
  --   config = function ()
  --     vim.keymap.set('n', '<C-]>', vim.fn.GoToBazelDefinition, { desc = '[S]earch [H]elp' })
  --   end
  -- },
  {
    'benlubas/molten-nvim',
    version = '^1.0.0', -- use version <2.0.0 to avoid breaking changes
    build = ':UpdateRemotePlugins',
    init = function()
      -- this is an example, not a default. Please see the readme for more configuration options
      vim.g.molten_output_win_max_height = 12
    end,
  },

  {
    'nvim-telescope/telescope-frecency.nvim',
    -- we do NOT want to load frecency lazily, as it can cause issues
    -- where it's lazily loaded right when we're about to quit neovim,
    -- causing a stalled uv loop
    main = 'frecency',
    opts = {
      default_workspace = 'CWD',
      show_unindexed = true,
      auto_validate = false,
      show_filter_column = false,
    },
  },
  { -- Fuzzy Finder (files, lsp, etc)
    'nvim-telescope/telescope.nvim',
    event = 'VimEnter',
    branch = '0.1.x',
    dependencies = {
      'nvim-lua/plenary.nvim',
      { -- If encountering errors, see telescope-fzf-native README for installation instructions
        'nvim-telescope/telescope-fzf-native.nvim',

        -- `build` is used to run some command when the plugin is installed/updated.
        -- This is only run then, not every time Neovim starts up.
        build = 'make',

        -- `cond` is a condition used to determine whether this plugin should be
        -- installed and loaded.
        cond = function()
          return vim.fn.executable('make') == 1
        end,
      },
      { 'nvim-telescope/telescope-ui-select.nvim' },

      -- Useful for getting pretty icons, but requires a Nerd Font.
      { 'nvim-tree/nvim-web-devicons', enabled = vim.g.have_nerd_font },
    },
    config = function()
      local actions = require('telescope.actions')

      -- allow for more space for the fnames
      local picker_config = {}
      for b, _ in pairs(require('telescope.builtin')) do
        picker_config[b] = { fname_width = 80 }
      end

      require('telescope').setup({

        -- You can put your default mappings / updates / etc. in here
        --  All the info you're looking for is in `:help telescope.setup()`
        --
        defaults = {
          layout_strategy = 'vertical',
          mappings = {
            i = {
              ['<C-j>'] = actions.preview_scrolling_down,
              ['<C-k>'] = actions.preview_scrolling_up,
              ['<C-d>'] = false, -- Disables Telescope's <C-d> mapping to get normal behavior
            },
            n = {
              ['<C-j>'] = actions.preview_scrolling_down,
              ['<C-k>'] = actions.preview_scrolling_up,
            },
          },
          -- https://github.com/nvim-telescope/telescope.nvim/issues/3436
          -- border = false,
        },
        pickers = picker_config,
        extensions = {
          ['ui-select'] = {
            require('telescope.themes').get_dropdown(),
          },
          fzf = {
            fuzzy = true,
            override_generic_sorter = true,
            override_file_sorter = true,
            case_mode = 'smart_case',
          },
          -- loaded frecency independently in deps
        },
      })

      -- Enable Telescope extensions if they are installed
      pcall(require('telescope').load_extension, 'fzf')
      pcall(require('telescope').load_extension, 'ui-select')
      pcall(require('telescope').load_extension, 'frecency')

      -- See `:help telescope.builtin`
      local builtin = require('telescope.builtin')
      vim.keymap.set('n', '<leader>sh', builtin.help_tags, { desc = '[S]earch [H]elp' })
      vim.keymap.set('n', '<leader>sk', builtin.keymaps, { desc = '[S]earch [K]eymaps' })
      vim.keymap.set('n', '<leader>sf', builtin.find_files, { desc = '[S]earch [F]iles' })
      vim.keymap.set('n', '<leader>ss', builtin.builtin, { desc = '[S]earch [S]elect Telescope' })
      vim.keymap.set('n', '<leader>sw', builtin.grep_string, { desc = '[S]earch current [W]ord' })
      vim.keymap.set('n', '<leader>sr', builtin.resume, { desc = '[S]earch [R]esume' })
      vim.keymap.set('n', '<leader>s.', builtin.oldfiles, { desc = '[S]earch Recent Files ("." for repeat)' })
      vim.keymap.set('n', '<leader><leader>', builtin.buffers, { desc = '[ ] Find existing buffers' })
      vim.keymap.set('n', '<C-p>', '<Cmd>Telescope frecency workspace=CWD<CR>')

      -- TODO fix thi
      vim.keymap.set('n', '<leader>sd', function()
        local current_buffer_dir = vim.fn.expand('%:p:h')
        vim.ui.input({ prompt = 'Search directory: ', default = current_buffer_dir }, function(input)
          if input then -- check if input wasn't cancelled
            require('telescope.builtin').live_grep({
              search_dirs = { input },
              additional_args = function(args)
                return vim.list_extend(args, { '--fixed-strings' })
              end,
            })
          end
        end)
      end)

      vim.keymap.set('v', '<leader>sw', function()
        require('telescope.builtin').live_grep({
          default_text = table.concat(get_visual_selection()),
          additional_args = function(args)
            return vim.list_extend(args, { '--fixed-strings' })
          end,
        })
      end)

      vim.keymap.set('n', '<leader>sa', function()
        require('telescope.builtin').grep_string({ search = '', previewer = false })
      end, { desc = '[S]earch current [W]ord' })
    end,
  },

  -- LSP Plugins
  {
    -- `lazydev` configures Lua LSP for your Neovim config, runtime and plugins
    -- used for completion, annotations and signatures of Neovim apis
    'folke/lazydev.nvim',
    ft = 'lua',
    opts = {
      library = {
        -- Load luvit types when the `vim.uv` word is found
        { path = 'luvit-meta/library', words = { 'vim%.uv' } },
      },
    },
  },
  { 'Bilal2453/luvit-meta', lazy = true },
  {
    -- Main LSP Configuration
    'neovim/nvim-lspconfig',
    dependencies = {
      -- Automatically install LSPs and related tools to stdpath for Neovim
      { 'williamboman/mason.nvim', config = true }, -- NOTE: Must be loaded before dependants
      'williamboman/mason-lspconfig.nvim',
      'WhoIsSethDaniel/mason-tool-installer.nvim',

      -- Useful status updates for LSP.
      -- NOTE: `opts = {}` is the same as calling `require('fidget').setup({})`
      { 'j-hui/fidget.nvim', opts = {} },

      -- Allows extra capabilities provided by nvim-cmp
      'hrsh7th/cmp-nvim-lsp',
      'microsoft/python-type-stubs',
    },
    config = function()
      vim.api.nvim_create_autocmd('LspAttach', {
        group = vim.api.nvim_create_augroup('kickstart-lsp-attach', { clear = true }),
        callback = function(event)
          local map = function(keys, func, desc)
            vim.keymap.set('n', keys, func, { buffer = event.buf, desc = 'LSP: ' .. desc })
          end

          -- The following two autocommands are used to highlight references of the
          -- word under your cursor when your cursor rests there for a little while.
          --    See `:help CursorHold` for information about when this is executed
          --
          -- When you move your cursor, the highlights will be cleared (the second autocommand).
          local client = vim.lsp.get_client_by_id(event.data.client_id)

          -- these two lines disable syntax highlighting from the LSP server, if it exists
          client.server_capabilities.semanticTokensProvider = nil -- disable semantic highlights
          -- vim.highlight.priorities.semantic_tokens = 95 -- Or any number lower than 100, treesitter's priority level

          if client and client.supports_method(vim.lsp.protocol.Methods.textDocument_documentHighlight) then
            local highlight_augroup = vim.api.nvim_create_augroup('kickstart-lsp-highlight', { clear = false })
            vim.api.nvim_create_autocmd({ 'CursorHold', 'CursorHoldI' }, {
              buffer = event.buf,

              group = highlight_augroup,
              callback = vim.lsp.buf.document_highlight,
            })

            vim.api.nvim_create_autocmd({ 'CursorMoved', 'CursorMovedI' }, {
              buffer = event.buf,
              group = highlight_augroup,
              callback = vim.lsp.buf.clear_references,
            })

            vim.api.nvim_create_autocmd('LspDetach', {
              group = vim.api.nvim_create_augroup('kickstart-lsp-detach', { clear = true }),
              callback = function(event2)
                vim.lsp.buf.clear_references()
                vim.api.nvim_clear_autocmds({ group = 'kickstart-lsp-highlight', buffer = event2.buf })
              end,
            })
          end

          -- The following code creates a keymap to toggle inlay hints in your
          -- code, if the language server you are using supports them
          --
          -- This may be unwanted, since they displace some of your code
          if client and client.supports_method(vim.lsp.protocol.Methods.textDocument_inlayHint) then
            map('<leader>th', function()
              vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled({ bufnr = event.buf }))
            end, '[T]oggle Inlay [H]ints')
          end
        end,
      })

      -- LSP servers and clients are able to communicate to each other what features they support.
      --  By default, Neovim doesn't support everything that is in the LSP specification.
      --  When you add nvim-cmp, luasnip, etc. Neovim now has *more* capabilities.
      --  So, we create new capabilities with nvim cmp, and then broadcast that to the servers.
      local capabilities = vim.lsp.protocol.make_client_capabilities()
      -- capabilities = require('blink.cmp').get_lsp_capabilities(capabilities)
      capabilities = vim.tbl_deep_extend('force', capabilities, require('cmp_nvim_lsp').default_capabilities())
      capabilities.workspace.didChangeWatchedFiles.dynamicRegistration = false

      -- Enable the following language servers
      --  Feel free to add/remove any LSPs that you want here. They will automatically be installed.
      --
      --  Add any additional override configuration in the following tables. Available keys are:
      --  - cmd (table): Override the default command used to start the server
      --  - filetypes (table): Override the default list of associated filetypes for the server
      --  - capabilities (table): Override fields in capabilities. Can be used to disable certain LSP features.
      --  - settings (table): Override the default settings passed when initializing the server.
      --        For example, to see the options for `lua_ls`, you could go to: https://luals.github.io/wiki/settings/
      local servers = {
        clangd = {},
        gopls = {},
        ruff = {},
        yamlls = {
          settings = {
            yaml = {
              schemaStore = {
                enable = false,
              },
              schemas = {
                -- kubernetes = '*.yaml',
                ['http://json.schemastore.org/github-workflow'] = '.github/workflows/*',
                ['http://json.schemastore.org/github-action'] = '.github/action.{yml,yaml}',
                ['http://json.schemastore.org/chart'] = 'Chart.{yml,yaml}',
                ['https://raw.githubusercontent.com/compose-spec/compose-spec/master/schema/compose-spec.json'] = '*docker-compose*.{yml,yaml}',
                ['https://raw.githubusercontent.com/argoproj/argo-workflows/master/api/jsonschema/schema.json'] = '*flow*.{yml,yaml}',
              },
            },
          },
        },
        helm_ls = {
          settings = {
            ['helm-ls'] = {
              yamlls = {
                path = 'yaml-language-server',
              },
            },
          },
        },
        terraformls = {},
        rust_analyzer = {},
        -- ... etc. See `:help lspconfig-all` for a list of all the pre-configured LSPs
        --
        -- Some languages (like typescript) have entire language plugins that can be useful:
        --    https://github.com/pmizio/typescript-tools.nvim
        --
        -- But for many setups, the LSP (`tsserver`) will work just fine
        denols = {},

        -- pylsp = {
        --   settings = {
        --     pylsp = {
        --       plugins = {
        --         mypy = {
        --           enabled = true,
        --         },
        --         pycodestyle = {
        --           enabled = false,
        --         },
        --         pyflakes = {
        --           enabled = false,
        --         },
        --         mccabe = {
        --           enabled = false,
        --         },
        --         rope_autoimport = {
        --           enabled = true,
        --         },
        --         jedi_completion = {
        --           fuzzy = true,
        --         },
        --       },
        --     },
        --   },
        -- },
        --
        pyright = {
          settings = {
            pyright = {
              disableOrganizeImports = true,
            },
            python = {
              pythonPath = getPythonPath(),
              analysis = {
                stubPath = vim.fn.stdpath('data') .. '/lazy/python-type-stubs',
                exclude = { 'bazel-bin/**', '**/venv', '**/.venv' },
                diagnosticMode = 'openFilesOnly', -- workspace
                -- ignore = { '*' },
              },
            },
          },
        },

        -- pyright = {
        --   settings = {
        --     pyright = {
        --       disableOrganizeImports = true,
        --       disableTaggedHints = true,
        --     },
        --     python = {
        --       analysis = {
        --         typeCheckingMode = 'off',
        --         exclude = { 'bazel-bin/**', '**/venv', '**/.venv' },
        --         stubPath = vim.fn.stdpath('data') .. '/lazy/python-type-stubs',
        --         useLibraryCodeForTypes = false, -- Disable type checking of library code, done for speed
        --         diagnosticSeverityOverrides = {
        --           -- https://github.com/microsoft/pyright/blob/main/docs/configuration.md#type-check-diagnostics-settings
        --           reportUndefinedVariable = 'error',
        --         },
        --       },
        --     },
        --   },
        -- },

        lua_ls = {
          -- cmd = {...},
          -- filetypes = { ...},
          -- capabilities = {},
          settings = {
            Lua = {
              completion = {
                callSnippet = 'Replace',
              },
              -- You can toggle below to ignore Lua_LS's noisy `missing-fields` warnings
              -- diagnostics = { disable = { 'missing-fields' } },
            },
          },
        },
      }

      -- Ensure the servers and tools above are installed
      --  To check the current status of installed tools and/or manually install
      --  other tools, you can run
      --    :Mason
      --
      --  You can press `g?` for help in this menu.
      require('mason').setup()

      -- You can add other tools here that you want Mason to install
      -- for you, so that they are available from within Neovim.
      local ensure_installed = vim.tbl_keys(servers or {})
      vim.list_extend(ensure_installed, {
        'stylua', -- Used to format Lua code
        'buildifier', -- Used to format Bazel code
        'mypy',
        'black',
        'isort',
      })
      require('mason-tool-installer').setup({ ensure_installed = ensure_installed })

      require('mason-lspconfig').setup({
        handlers = {
          function(server_name)
            local server = servers[server_name]
            if server == nil then
              return
            end
            -- This handles overriding only values explicitly passed
            -- by the server configuration above. Useful when disabling
            -- certain features of an LSP (for example, turning off formatting for tsserver)
            server.capabilities = vim.tbl_deep_extend('force', {}, capabilities, server.capabilities or {})
            require('lspconfig')[server_name].setup(server)
          end,
        },
      })
    end,
  },
  { -- Linting
    'mfussenegger/nvim-lint',
    event = { 'BufReadPre', 'BufNewFile' },
    config = function()
      local lint = require('lint')
      lint.linters_by_ft = {
        bzl = { 'buildifier' },
      }
      table.insert(lint.linters.buildifier.args, '--warnings=-reorder-dict-items')
      local lint_augroup = vim.api.nvim_create_augroup('lint', { clear = true })
      vim.api.nvim_create_autocmd({ 'BufEnter', 'BufWritePost', 'InsertLeave' }, {
        group = lint_augroup,
        callback = function()
          lint.try_lint()
        end,
      })
    end,
  },

  { -- Autoformat
    'stevearc/conform.nvim',
    event = { 'BufWritePre' },
    cmd = { 'ConformInfo' },
    keys = {
      {
        'gf',
        function()
          require('conform').format({ async = true, lsp_fallback = true })
        end,
        mode = '',
        desc = '[F]ormat buffer',
      },
    },
    opts = {

      log_level = vim.log.levels.DEBUG,
      notify_on_error = false,
      -- format_on_save = function(bufnr)
      --  -- Disable "format_on_save lsp_fallback" for languages that don't
      --  -- have a well standardized coding style. You can add additional
      --  -- languages here or re-enable it for the disabled ones.
      --  local disable_filetypes = { c = true, cpp = true }
      --  return {
      --    timeout_ms = 500,
      --    lsp_fallback = not disable_filetypes[vim.bo[bufnr].filetype],
      --  }
      -- end,
      formatters_by_ft = {
        lua = { 'stylua' },
        python = function(_)
          local root_dir = vim.fs.root(vim.fn.getcwd(), { 'pyproject.toml' })
          -- we want to use ruff for newer projects and as a default
          if root_dir == nil or file_contains(root_dir .. '/pyproject.toml', '[tool.ruff]') then
            return { 'ruff_format', 'ruff', 'ruff_organize_imports' }
          else
            return { 'isort', 'black' }
          end
        end,
        bzl = { 'buildifier' },
        --
        -- You can use 'stop_after_first' to run the first available formatter from the list
        -- javascript = { "prettierd", "prettier", stop_after_first = true },
      },
    },
  },
  -- {
  --   'saghen/blink.cmp',
  --   -- optional: provides snippets for the snippet source
  --   dependencies = {
  --     'rafamadriz/friendly-snippets',
  --     'giuxtaposition/blink-cmp-copilot',
  --   },
  --
  --   -- use a release tag to download pre-built binaries
  --   version = '*',
  --   -- AND/OR build from source, requires nightly: https://rust-lang.github.io/rustup/concepts/channels.html#working-with-nightly-rust
  --   -- build = 'cargo build --release',
  --   -- If you use nix, you can build from source using latest nightly rust with:
  --   -- build = 'nix run .#build-plugin',
  --
  --   opts = {
  --     keymap = {
  --       preset = 'default',
  --       ['<C-CR>'] = { 'accept' },
  --       ['<C-K>'] = { 'scroll_documentation_up' },
  --       ['<C-J>'] = { 'scroll_documentation_down' },
  --       ['<C-L>'] = { 'snippet_forward' },
  --       ['<C-H>'] = { 'snippet_backward' },
  --     },
  --     completion = {
  --       list = {
  --         selection = 'auto_insert',
  --       },
  --       documentation = {
  --         auto_show = true,
  --         auto_show_delay_ms = 100,
  --       },
  --     },
  --
  --     appearance = {
  --       use_nvim_cmp_as_default = true,
  --       nerd_font_variant = 'mono',
  --     },
  --
  --     -- Default list of enabled providers defined so that you can extend it
  --     -- elsewhere in your config, without redefining it, due to `opts_extend`
  --     sources = {
  --       default = { 'lsp', 'path', 'snippets', 'buffer', 'copilot' },
  --       providers = {
  --         copilot = {
  --           name = 'copilot',
  --           module = 'blink-cmp-copilot',
  --           score_offset = 100,
  --           async = true,
  --         },
  --       },
  --     },
  --   },
  --   opts_extend = { 'sources.default' },
  -- },
  { -- Autocompletion
    'hrsh7th/nvim-cmp',
    event = 'InsertEnter',
    dependencies = {
      -- Snippet Engine & its associated nvim-cmp source
      {
        'L3MON4D3/LuaSnip',
        build = (function()
          -- Build Step is needed for regex support in snippets.
          -- This step is not supported in many windows environments.
          -- Remove the below condition to re-enable on windows.
          if vim.fn.has('win32') == 1 or vim.fn.executable('make') == 0 then
            return
          end
          return 'make install_jsregexp'
        end)(),
        dependencies = {
          -- `friendly-snippets` contains a variety of premade snippets.
          --    See the README about individual language/framework/plugin snippets:
          --    https://github.com/rafamadriz/friendly-snippets
          -- {
          --   'rafamadriz/friendly-snippets',
          --   config = function()
          --     require('luasnip.loaders.from_vscode').lazy_load()
          --   end,
          -- },
        },
      },
      'saadparwaiz1/cmp_luasnip',

      -- Adds other completion capabilities.
      --  nvim-cmp does not ship with all sources by default. They are split
      --  into multiple repos for maintenance purposes.
      'hrsh7th/cmp-nvim-lsp',
      'hrsh7th/cmp-path',
    },
    config = function()
      -- See `:help cmp`
      local cmp = require('cmp')
      local luasnip = require('luasnip')
      luasnip.config.setup({})

      cmp.setup({
        snippet = {
          expand = function(args)
            luasnip.lsp_expand(args.body)
          end,
        },
        completion = { completeopt = 'menu,menuone,noinsert' },

        -- For an understanding of why these mappings were
        -- chosen, you will need to read `:help ins-completion`
        --
        -- No, but seriously. Please read `:help ins-completion`, it is really good!
        mapping = cmp.mapping.preset.insert({
          -- Select the [n]ext item
          ['<C-n>'] = cmp.mapping.select_next_item(),
          -- Select the [p]revious item
          ['<C-p>'] = cmp.mapping.select_prev_item(),

          -- Scroll the documentation window
          ['<C-k>'] = cmp.mapping.scroll_docs(-4),
          ['<C-j>'] = cmp.mapping.scroll_docs(4),

          --  Accept the completion.
          --  This will auto-import if your LSP supports it.
          --  This will expand snippets if the LSP sent a snippet.
          --  previously was <C-y>, but this felt more ergonomic
          ['<C-CR>'] = cmp.mapping.confirm({ select = true }),

          -- If you prefer more traditional completion keymaps,
          -- you can uncomment the following lines
          --['<CR>'] = cmp.mapping.confirm { select = true },
          --['<Tab>'] = cmp.mapping.select_next_item(),
          --['<S-Tab>'] = cmp.mapping.select_prev_item(),

          -- Manually trigger a completion from nvim-cmp.
          --  Generally you don't need this, because nvim-cmp will display
          --  completions whenever it has completion options available.
          ['<C-Space>'] = cmp.mapping.complete({}),

          -- Think of <c-l> as moving to the right of your snippet expansion.
          --  So if you have a snippet that's like:
          --  function $name($args)
          --    $body
          --  end
          --
          -- <c-l> will move you to the right of each of the expansion locations.
          -- <c-h> is similar, except moving you backwards.
          ['<C-l>'] = cmp.mapping(function()
            if luasnip.expand_or_locally_jumpable() then
              luasnip.expand_or_jump()
            end
          end, { 'i', 's' }),
          ['<C-h>'] = cmp.mapping(function()
            if luasnip.locally_jumpable(-1) then
              luasnip.jump(-1)
            end
          end, { 'i', 's' }),

          -- For more advanced Luasnip keymaps (e.g. selecting choice nodes, expansion) see:
          --    https://github.com/L3MON4D3/LuaSnip?tab=readme-ov-file#keymaps
        }),
        sources = {
          {
            name = 'lazydev',
            -- set group index to 0 to skip loading LuaLS completions as lazydev recommends it
            group_index = 0,
          },
          { name = 'nvim_lsp' },
          { name = 'luasnip' },
          { name = 'path' },
        },
      })
    end,
  },

  { -- You can easily change to a different colorscheme.
    -- Change the name of the colorscheme plugin below, and then
    -- change the command in the config to whatever the name of that colorscheme is.
    --
    -- If you want to see what colorschemes are already installed, you can use `:Telescope colorscheme`.
    'EdenEast/nightfox.nvim',
    priority = 1000, -- Make sure to load this before all the other start plugins.
    init = function()
      -- Load the colorscheme here.
      -- Like many other themes, this one has different styles, and you could load
      -- any other, such as 'tokyonight-storm', 'tokyonight-moon', or 'tokyonight-day'.
      require('nightfox').setup({
        options = {
          dim_inactive = true,
          styles = {
            comments = 'italic',
            keywords = 'bold',
            types = 'italic,bold',
          },
        },
      })
      vim.opt.termguicolors = true
      vim.cmd.colorscheme('nightfox')

      -- You can configure highlights by doing something like:
      vim.cmd.hi('Comment gui=none')
    end,
  },

  -- Highlight todo, notes, etc in comments
  {
    'folke/todo-comments.nvim',
    event = 'VimEnter',
    dependencies = { 'nvim-lua/plenary.nvim' },
    opts = { signs = false },
  },
  { -- Collection of various small independent plugins/modules
    'echasnovski/mini.nvim',
    config = function()
      -- Better Around/Inside textobjects
      --
      -- Examples:
      --  - va)  - [V]isually select [A]round [)]paren
      --  - yinq - [Y]ank [I]nside [N]ext [Q]uote
      --  - ci'  - [C]hange [I]nside [']quote
      require('mini.ai').setup({
        n_lines = 500,
      })

      -- line text object, overwrites some keybinds from mini.ai
      vim.keymap.set('x', 'il', 'g_o^')
      vim.keymap.set('o', 'il', ':normal vil<CR>')

      -- Add/delete/replace surroundings (brackets, quotes, etc.)
      --
      -- - saiw) - [S]urround [A]dd [I]nner [W]ord [)]Paren
      -- - sd'   - [S]urround [D]elete [']quotes
      -- - sr)'  - [S]urround [R]eplace [)] [']
      require('mini.surround').setup()

      -- Simple and easy statusline.
      --  You could remove this setup call if you don't like it,
      --  and try some other statusline plugin
      local statusline = require('mini.statusline')
      -- set use_icons to true if you have a Nerd Font
      statusline.setup({ use_icons = vim.g.have_nerd_font })

      -- You can configure sections in the statusline by overriding their
      -- default behavior. For example, here we set the section for
      -- cursor location to LINE:COLUMN
      ---@diagnostic disable-next-line: duplicate-set-field
      statusline.section_location = function()
        return '%2l:%-2v'
      end

      -- ... and there is more!
      --  Check out: https://github.com/echasnovski/mini.nvim
      require('mini.tabline').setup()

      local miniFiles = require('mini.files')
      miniFiles.setup()
      vim.keymap.set('n', '-', function()
        local current_file = vim.api.nvim_buf_get_name(0)
        if vim.fn.filereadable(current_file) == 1 then
          miniFiles.open(current_file)
        else
          local current_dir = vim.fn.fnamemodify(current_file, ':h')
          miniFiles.open(current_dir)
        end
      end)

      local miniBufremove = require('mini.bufremove')
      miniBufremove.setup()
      vim.keymap.set('n', '<C-q>', miniBufremove.delete)
    end,
  },
  {
    'folke/snacks.nvim',
    priority = 1000,
    lazy = false,
    opts = {
      -- your configuration comes here
      -- or leave it empty to use the default settings
      -- refer to the configuration section below
      bigfile = { enabled = true },
      dashboard = { enabled = true },
      indent = { enabled = true, animate = { enabled = false } },
      input = { enabled = true },
      notifier = { enabled = true },
      quickfile = { enabled = true },
      -- scroll = { enabled = true },
      -- statuscolumn = { enabled = true },
      words = { enabled = true },
      picker = { enabled = true },
    },
  },
  {
    'MeanderingProgrammer/render-markdown.nvim',
    ft = { 'markdown', 'codecompanion' },
  },
  {
    'olimorris/codecompanion.nvim',
    dependencies = {
      'nvim-lua/plenary.nvim',
      'nvim-treesitter/nvim-treesitter',
    },
    config = function()
      local cc = require('codecompanion')
      cc.setup({
        display = {
          chat = {
            window = {
              layout = 'float',
              height = 0.8,
              width = 0.8,
            },
          },
        },
        adapters = {
          copilot = function()
            return require('codecompanion.adapters').extend('copilot', {
              schema = {
                model = {
                  default = 'claude-3.7-sonnet',
                },
              },
            })
          end,
        },
        strategies = {
          chat = {
            adapter = 'copilot',
          },
          inline = {
            adapter = 'copilot',
          },
        },
      })
      vim.keymap.set('n', '<leader>a', cc.toggle, { silent = true })
      vim.keymap.set('v', '<leader>a', ':CodeCompanionChat Add<CR>')
    end,
  },
  { -- Highlight, edit, and navigate code
    'nvim-treesitter/nvim-treesitter',
    build = ':TSUpdate',
    dependencies = { 'nvim-treesitter/nvim-treesitter-textobjects' },
    opts = {
      ensure_installed = {
        'bash',
        'c',
        'cpp',
        'diff',
        'go',
        'hcl',
        'html',
        'json',
        'json5',
        'lua',
        'luadoc',
        'markdown',
        'markdown_inline',
        'python',
        'query',
        'regex',
        'rust',
        'terraform',
        'tsx',
        'typescript',
        'vim',
        'vimdoc',
        'yaml',
      },
      -- Autoinstall languages that are not installed
      auto_install = true,
      highlight = { enable = true },
      indent = {
        enable = true,
        disable = { 'yaml' },
      },
      incremental_selection = {
        enable = true,
        keymaps = {
          init_selection = '<CR>',
          node_incremental = '<CR>',
          -- TODO: I'm not sure for this one.
          scope_incremental = '<c-s>',
          node_decremental = '<S-CR>',
        },
      },
      textobjects = {
        select = {
          enable = true,
          lookahead = true,
          keymaps = {
            ['af'] = '@function.outer',
            ['if'] = '@function.inner',
          },
          selection_modes = {
            ['@parameter.outer'] = 'v', -- charwise
            ['@function.outer'] = 'V', -- linewise
            ['@class.outer'] = '<c-v>', -- blockwise
          },
        },
      },
    },
    config = function(_, opts)
      require('nvim-treesitter.configs').setup(opts)
    end,
  },
}, {
  change_detection = {
    notify = false,
  },
})

-- The line beneath this is called `modeline`. See `:help modeline`
-- vim: ts=2 ss=2 sw=2 et
