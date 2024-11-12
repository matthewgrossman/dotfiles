return {
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
      vim.keymap.set({ 'n', 't' }, '<C-;>', '<CMD>ToggleTerm direction=float<CR>')
    end,
  },
}
