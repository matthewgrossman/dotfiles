local wezterm = require("wezterm")
local act = wezterm.action

local config = {
    -- font = wezterm.font("Fira Code"),
    color_scheme = "OneDark (base16)",
    window_decorations = "RESIZE",
    enable_csi_u_key_encoding = true,
    -- debug_key_events = true,
    enable_kitty_keyboard = true,
    window_padding = {
        left = 0,
        right = 0,
        top = 0,
        bottom = 0,
    },
    debug_key_events=true,
    default_gui_startup_args = { 'connect', 'WSL:Ubuntu'},
    -- keys = {
    --     {key="/", mods="CTRL", action=wezterm.action{SendString="\x1f"}},
    -- }
}
config.keys = {}
for i = 1, 8 do
  -- CTRL+ALT + number to activate that tab
  table.insert(config.keys, {
    key = tostring(i),
    mods = 'WIN',
    action = act.ActivateTab(i - 1),
  })
end

return config
