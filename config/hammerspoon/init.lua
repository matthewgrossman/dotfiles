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
-- tb = require "pl.tablex"

-- wf = hs.window.filter.new()
-- wf:keepActive()
-- switcher = hs.window.switcher.new(wf)
-- hs.hotkey.bind('alt','tab','Next window', function()
--     switcher:next()
-- end)
-- hs.hotkey.bind('alt-shift','tab','Prev window',function()switcher:previous()end)
-- window_chooser = hs.chooser.new(function(choice)
--     if not choice then return end
--     print (choice.windowId)
--     win = idToWindow[choice.windowId]
--     print(win)
--     win:focus()
-- end)
-- idToWindow = {}
-- window_chooser:choices(function()
--     local ret = {}
--     for k, v in pairs(wf:getWindows()) do
--         print(k:id())
--         idToWindow[k.id] = k
--         row = {
--             text = k.title,
--             subText = 'subtext',
--             windowId = k.id
--         }
--         table.insert(ret, row)
--     end
--     return ret
-- end)
-- hs.hotkey.bind('alt', 'tab', function() 
--     window_chooser:refreshChoicesCallback()
--     window_chooser:show() 
-- end)


-- wf=hs.window.filter
-- wf_force = wf.new{overrides={forceRefreshOnSpaceChange=true}}
