local wezterm = require("wezterm")
local act = wezterm.action

return {
    -- font = wezterm.font("Fira Code"),
    color_scheme = "OneDark (base16)",
    window_decorations = "RESIZE",
    enable_csi_u_key_encoding = true,
    -- debug_key_events = true,
    window_padding = {
        left = 0,
        right = 0,
        top = 0,
        bottom = 0,
    },
    -- debug_key_events=true,
    default_gui_startup_args = { 'connect', 'WSL:Ubuntu'},
    keys = {
        {key="/", mods="CTRL", action=wezterm.action{SendString="\x1f"}},
    }
}
