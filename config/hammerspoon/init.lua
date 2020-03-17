helpers = require("helpers")

-- gotta go fast
hs.window.animationDuration = 0

layout_hyper = {"cmd", "alt"}

layoutLeft65 = {x=0, y=0, w=.65,h=1}
layoutLeft35 = {x=0, y=0, w=.35,h=1}
layoutRight35 = {x=.65, y=0, w=.35,h=1}
layoutRight65 = {x=.35, y=0, w=.65,h=1}
layout_mapping = {
    h = {layoutLeft35, hs.layout.left50, layoutLeft65},
    l = {layoutRight35, hs.layout.right50, layoutRight65},
    k = hs.layout.maximized,
    m = {x=0.5, y=0.5, w=0.5, h=0.5},
    n = {x=0, y=0.5, w=0.5, h=0.5},
    o = {x=0.5, y=0, w=0.5, h=0.5},
    u = {x=0, y=0, w=0.5, h=0.5}
}
for key, layouts in pairs(layout_mapping) do
    hs.hotkey.bind(layout_hyper, key, function()
        if layouts.x ~= nil then
            -- if single layout is passed (checked existence of 'x'), directly apply layout
            layout = layouts
        else
            -- otherwise, cycle through the layout sizes
            w = hs.window.focusedWindow()
            screenFrame = w:screen():frame()
            windowFrame = w:frame()
            currentWindowUnit = windowFrame:toUnitRect(screenFrame)
            unitRectIndex = 2
            for i, unitRect in ipairs(layouts) do
                if helpers.approxEqualRects(currentWindowUnit, unitRect) then
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
