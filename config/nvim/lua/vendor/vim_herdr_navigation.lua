-- Vendored from paulbkim-dev/vim-herdr-navigation at commit 79679dacc791.
--
-- Seamless <C-h/j/k/l> navigation between Neovim splits and Herdr panes: move
-- between Neovim splits, and at a split edge hand off to Herdr so focus crosses
-- into the neighbouring Herdr pane. When not inside Herdr it falls back to tmux
-- (if any) or plain wincmd, so a tmux setup keeps working.

local function nav(wincmd, dir)
  local prev = vim.api.nvim_get_current_win()
  vim.cmd('wincmd ' .. wincmd)
  if vim.api.nvim_get_current_win() ~= prev then
    return
  end

  -- herdr-app terminals can inherit a stale HERDR_PANE_ID, so check for it first.
  -- Its ctrl-h/j/k/l are handled by the `vimnav` mod in ~/.config/herdr-app.
  if vim.env.HC_TERMINAL_ID and vim.env.HC_TERMINAL_ID ~= '' then
    vim.system({ 'herdr-app', 'do', 'pane.go', '--direction', dir })
  elseif vim.env.HERDR_PANE_ID and vim.env.HERDR_PANE_ID ~= '' then
    local herdr = vim.env.HERDR_BIN_PATH
    if herdr == nil or herdr == '' then
      herdr = 'herdr'
    end
    vim.fn.system({ herdr, 'pane', 'focus', '--direction', dir, '--pane', vim.env.HERDR_PANE_ID })
  elseif vim.env.TMUX and vim.env.TMUX ~= '' then
    local tmux = { left = 'Left', down = 'Down', up = 'Up', right = 'Right' }
    pcall(vim.cmd, 'TmuxNavigate' .. tmux[dir])
  end
end

local function map(lhs, wincmd, dir, desc)
  vim.keymap.set('n', lhs, function()
    nav(wincmd, dir)
  end, { silent = true, noremap = true, desc = desc })
end

map('<C-h>', 'h', 'left', 'Navigate left (vim/herdr)')
map('<C-j>', 'j', 'down', 'Navigate down (vim/herdr)')
map('<C-k>', 'k', 'up', 'Navigate up (vim/herdr)')
map('<C-l>', 'l', 'right', 'Navigate right (vim/herdr)')
