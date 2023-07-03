local wezterm = require("wezterm")
local act = wezterm.action

local config = {
  font = wezterm.font("Fira Code"),
  font_rules = {
    {
      italic = true,
      font = wezterm.font({
        family = "JetBrains Mono",
        italic = true,
      }),
    },
  },
  font_size = 15.0,
  color_scheme = "OneDark (base16)",
  window_decorations = "RESIZE",
  adjust_window_size_when_changing_font_size = false,
  window_frame = {
    font_size = 15.0,
  },
  window_padding = {
    left = 0,
    right = 0,
    top = 0,
    bottom = 0,
  },
  -- debug_key_events = true,
  -- default_gui_startup_args = { 'connect', 'WSL:Ubuntu'},
}
config.keys = {
  -- Rebind OPT-Left, OPT-Right as ALT-b, ALT-f respectively to match Terminal.app behavior
  {
    key = "LeftArrow",
    mods = "OPT",
    action = act.SendKey({
      key = "b",
      mods = "ALT",
    }),
  },
  {
    key = "RightArrow",
    mods = "OPT",
    action = act.SendKey({ key = "f", mods = "ALT" }),
  },
  {
    key = "t",
    mods = "SUPER",
    action = act.SpawnCommandInNewTab({ cwd = "~" }),
  },
  {
    key = "[",
    mods = "SUPER",
    action = act.MoveTabRelative(-1),
  },
  {
    key = "]",
    mods = "SUPER",
    action = act.MoveTabRelative(1),
  },
}

for i = 1, 8 do
  -- CTRL+ALT + number to activate that tab
  table.insert(config.keys, {
    key = tostring(i),
    mods = "WIN",
    action = act.ActivateTab(i - 1),
  })
end

if wezterm.target_triple == 'x86_64-pc-windows-msvc' then
  config.default_domain = "WSL:Ubuntu"
  config.font_size = 13.0
end

return config
