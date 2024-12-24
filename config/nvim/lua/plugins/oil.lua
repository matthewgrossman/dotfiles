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
}
