helpers = require("helpers")

-- gotta go fast
hs.window.animationDuration = 0

layout_hyper = {"cmd", "alt"}
layout_mapping = {
    h = hs.layout.left50,
    l = hs.layout.right50,
    k = hs.layout.maximized,
    m = {x=0.5, y=0.5, w=0.5, h=0.5},
    n = {x=0, y=0.5, w=0.5, h=0.5},
    o = {x=0.5, y=0, w=0.5, h=0.5},
    u = {x=0, y=0, w=0.5, h=0.5}
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
        hs.eventtap.keyStroke({"fn", "ctrl"}, direction)
    end)
end

-- pl = require "pl.pretty"
-- pl.dump(myTable)

zowie_mapping = {
    [hs.eventtap.event.types.leftMouseDown] = "LEFT",
    [hs.eventtap.event.types.rightMouseDown] = "RIGHT"
}
-- mouse settings for the zowie
zowie_events = hs.eventtap.new(helpers.getTableKeys(zowie_mapping), function(event)
    if hs.eventtap.checkMouseButtons()[5] then
        hs.eventtap.keyStroke({"fn", "ctrl"}, zowie_mapping[event:getType()])
        return true
    end
    return false
end)
zowie_events:start()

-- enable if debugging

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
