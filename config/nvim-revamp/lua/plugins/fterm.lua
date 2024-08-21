return {
  'numToStr/FTerm.nvim',
  config = function()
    require('FTerm').setup {
      border = 'double',
      dimensions = {
        height = 0.95,
        width = 0.95,
      },
    }
    vim.keymap.set({ 'n', 't' }, '<C-;>', '<CMD>lua require("FTerm").toggle()<CR>')
  end,
}
