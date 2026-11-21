-- Seamless <C-h/j/k/l> navigation between Neovim splits and Rex panes: move
-- between Neovim splits, and at a split edge hand off to Rex so focus crosses
-- into the neighbouring Rex pane. Rex's side of this lives in config/rex/init.lua,
-- which sends these keys to Neovim instead of moving focus while it is in front.

local function nav(wincmd, dir)
  local prev = vim.api.nvim_get_current_win()
  vim.cmd('wincmd ' .. wincmd)
  if vim.api.nvim_get_current_win() ~= prev then
    return
  end
  vim.system({ 'rex', 'focus', dir, '-s', vim.env.REX_SESSION })
end

local function map(lhs, wincmd, dir, desc)
  vim.keymap.set('n', lhs, function()
    nav(wincmd, dir)
  end, { silent = true, noremap = true, desc = desc })
end

map('<C-h>', 'h', 'left', 'Navigate left (vim/rex)')
map('<C-j>', 'j', 'down', 'Navigate down (vim/rex)')
map('<C-k>', 'k', 'up', 'Navigate up (vim/rex)')
map('<C-l>', 'l', 'right', 'Navigate right (vim/rex)')
