helpers = require("helpers")

-- gotta go fast
hs.window.animationDuration = 0

layout_hyper = {"cmd", "alt"}
layout_mapping = {
    h = {hs.layout.left30, hs.layout.left50, hs.layout.left70},
    l = {hs.layout.right30, hs.layout.right50, hs.layout.right70},
    k = hs.layout.maximized,
    m = {x=0.5, y=0.5, w=0.5, h=0.5},
    n = {x=0, y=0.5, w=0.5, h=0.5},
    o = {x=0.5, y=0, w=0.5, h=0.5},
    u = {x=0, y=0, w=0.5, h=0.5}
}
for key, layouts in pairs(layout_mapping) do
    hs.hotkey.bind(layout_hyper, key, function()
        if layouts.x ~= nil then
            -- if a singular rect is passed, directly apply layout
            layout = layouts
        else
            -- otherwise, cycle through the layout sizes
            w = hs.window.focusedWindow()
            screen_frame = w:screen():frame()
            window_frame = w:frame()
            current_window_unit = window_frame:toUnitRect(screen_frame)
            unitRectIndex = 2
            for i, unitRect in ipairs(layouts) do
                if helpers.approxEqualTables(current_window_unit, unitRect) then
                    unitRectIndex = i + 1
                end
            end
            if unitRectIndex > #layouts then unitRectIndex = 1 end
            layout = layouts[unitRectIndex]
        end
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
        hs.eventtap.keyStroke({"fn", "ctrl"}, direction)
    end)
end

-- enable if debugging
pl = require "pl.pretty"
pl.dump(myTable)
-- mouse settings for the zowie

zowie_events = hs.eventtap.new({
    hs.eventtap.event.types.leftMouseUp,
    hs.eventtap.event.types.rightMouseUp,
}, function(event)
    -- print(hs.eventtap.event.types[event:getType()])
    pressedMouseButtons = hs.eventtap.checkMouseButtons()
    if pressedMouseButtons[5] then
        local direction
        if event:getType() == hs.eventtap.event.types.leftMouseUp then
            direction = "LEFT"
        else 
            direction = "RIGHT"
        end
        hs.eventtap.keyStroke({"fn", "ctrl"}, direction, 0)
        return true
    elseif pressedMouseButtons[4] then
        local direction
        if event:getType() == hs.eventtap.event.types.leftMouseUp then
            direction = "UP"
        else 
            direction = "DOWN"
        end
        hs.eventtap.keyStroke({"fn", "ctrl"}, direction, 0)
        return true
    else
        return false
    end
end)
zowie_events:start()

wf = hs.window.filter.new()
wf:keepActive()

-- create a new chooser that'll focus on whichever the selected window
window_chooser = hs.chooser.new(function(choice)
    if not choice then return end
    win = idToWindow[choice.windowId]
    win:focus()
end)
idToWindow = {}
idToName = {}
window_chooser:choices(function()
    local ret = {}
    for _, window in pairs(wf:getWindows()) do
        idToWindow[window:id()] = window
        assigned_name = idToName[window:id()]
        application = window:application()
        row = {
            text = assigned_name or application:name(),
            windowId = window:id(),
            image = hs.image.imageFromAppBundle(application:bundleID())
        }
        table.insert(ret, row)
    end
    return ret
end)
hs.hotkey.bind('alt', 'tab', function() 
    window_chooser:refreshChoicesCallback()
    window_chooser:query(nil)
    window_chooser:show() 
end)

hs.hotkey.bind(layout_hyper, "w", function()
    window = hs.window.focusedWindow()
    hs.focus()
    _, name = hs.dialog.textPrompt("Name this window:", "Enter the name for the focused window")
    idToName[window:id()] = name
    window:focus()
end)
