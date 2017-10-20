hs.window.animationDuration = 0

layout_hyper = {"cmd", "alt"}
layout_mapping = {
    h = hs.layout.left50,
    l = hs.layout.right50,
    k = hs.layout.maximized
}
for key, layout in pairs(layout_mapping) do
    hs.hotkey.bind(layout_hyper, key, function()
        hs.window.focusedWindow():moveToUnit(layout)
    end)
end

spaces_hyper = {"ctrl", "shift"}


arrow_hyper = {"fn"}
arrow_mapping = {
    h = "LEFT",
    l = "RIGHT",
    j = "DOWN",
    k = "UP"
}

-- for key, direction in pairs(arrow_mapping) do
--     hs.hotkey.bind(arrow_hyper, key, function()
--         hs.eventtap.keyStroke({}, direction)
--     end)
-- end
