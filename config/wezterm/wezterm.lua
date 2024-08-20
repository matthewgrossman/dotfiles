local wezterm = require("wezterm")
local act = wezterm.action

local function is_vim(pane)
	return pane:get_foreground_process_name():find("n?vim") ~= nil
end
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
	{
		key = "t",
		mods = "CTRL|SHIFT",
		action = wezterm.action.DisableDefaultAssignment,
	},
	{
		key = "c",
		mods = "CTRL",
		action = wezterm.action_callback(function(window, pane)
			-- MAJOR HACK; blasting C-c to neovim sometimes causes it to freeze. In wezterm,
			-- we remapped C-c to a different keybind, which then neovim will process and re-send
			-- C-c to the underlying terminals/buffers.
			if is_vim(pane) then
				window:perform_action(wezterm.action.SendString("\x1b[1;7C"), pane)
			else
				window:perform_action(wezterm.action.SendKey({ key = "c", mods = "CTRL" }), pane)
			end
		end),
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

if wezterm.target_triple == "x86_64-pc-windows-msvc" then
	config.default_domain = "WSL:Ubuntu"
	config.font_size = 12.0
end

return config
