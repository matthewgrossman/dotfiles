-- gotta go fast
hs.window.animationDuration = 0

layout_hyper = {"cmd", "alt"}
layout_mapping = {
    h = hs.layout.left50,
    l = hs.layout.right50,
    k = hs.layout.maximized,
    -- m = hs.layout.bottomRight,
    -- n = hs.layout.bottomLeft,
    -- o = hs.layout.topRight,
    -- u = hs.layout.topLeft,
}
for key, layout in pairs(layout_mapping) do
    hs.hotkey.bind(layout_hyper, key, function()
        hs.window.focusedWindow():moveToUnit(layout)
    end)
end

hs.hotkey.bind(layout_hyper, 'j', function()
    win = hs.window.focusedWindow()
    win:moveToScreen(win:screen():next())
end)

spaces_hyper = {"ctrl", "shift"}
spaces_mapping = {
    h = "LEFT",
    l = "RIGHT"
}

for key, direction in pairs(spaces_mapping) do
    hs.hotkey.bind(spaces_hyper, key, function()
        hs.eventtap.keyStroke({"ctrl"}, direction)
    end)
end
