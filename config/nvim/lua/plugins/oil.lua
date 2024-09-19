return {
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
  },
  -- Optional dependencies
  dependencies = { 'nvim-tree/nvim-web-devicons' },
}
