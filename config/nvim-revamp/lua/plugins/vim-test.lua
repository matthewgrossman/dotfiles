return {
   "vim-test/vim-test",
   config = function()
      local function clipboard_strategy(cmd)
         vim.fn.setreg("+", cmd)
      end

      -- Set up the custom strategy
      vim.g["test#custom_strategies"] = {
         clipboard = clipboard_strategy,
      }

      -- Set the default strategy
      vim.g["test#strategy"] = "clipboard"
      -- set strategy here
      vim.keymap.set("n", "<leader>r", ":TestNearest<CR>", { silent = true })
      vim.keymap.set("n", "<leader>R", ":TestFile<CR>", { silent = true })
   end,
}
