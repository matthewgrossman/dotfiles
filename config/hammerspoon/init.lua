helpers = require("helpers")

-- gotta go fast
hs.window.animationDuration = 0

layout_hyper = {"cmd", "alt"}

layoutLeft66 = {x=0, y=0, w=.6666,h=1}
layoutLeft33 = {x=0, y=0, w=.3333,h=1}
layoutRight33 = {x=.6666, y=0, w=.3333,h=1}
layoutRight66 = {x=.3333, y=0, w=.6666,h=1}
layoutMiddle33 = {x=.3333, y=0, w=.3333, h=1}
layoutUpperLeft = {x=0, y=0, w=0.5, h=0.5}
layoutUpperRight = {x=0.5, y=0, w=0.5, h=0.5}
layoutLowerRight = {x=0.5, y=0.5, w=0.5, h=0.5}
layoutLowerLeft = {x=0, y=0.5, w=0.5, h=0.5}
layoutUpperRightSixth = {x=.6666, y=0, w=.3333, h=.5}
layoutLowerRightSixth = {x=.6666, y=.5, w=.3333, h=.5}
layoutLowerLeftSixth = {x=0, y=.5, w=.3333, h=.5}
layoutUpperLeftSixth = {x=0, y=0, w=.3333, h=.5}

layout_mapping = {
    h = {layoutLeft33, hs.layout.left50, layoutLeft66},
    l = {layoutRight33, hs.layout.right50, layoutRight66},
    k = {layoutMiddle33, hs.layout.maximized},
    m = {layoutLowerRightSixth, layoutLowerRight},
    n = {layoutLowerLeftSixth, layoutLowerLeft},
    o = {layoutUpperRightSixth, layoutUpperRight},
    u = {layoutUpperLeftSixth, layoutUpperLeft}
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
            currentUnitRect = windowFrame:toUnitRect(screenFrame)

            unitRectIndex = 2 -- arbitrarily choose the 50% layout as default
            for i, unitRect in ipairs(layouts) do
                if helpers.approxEqualRects(currentUnitRect, unitRect) then
                    unitRectIndex = i + 1
                    break
                end
            end
            if unitRectIndex > #layouts then unitRectIndex = 1 end -- wrap around
            layout = layouts[unitRectIndex]
        end
        hs.window.focusedWindow():moveToUnit(layout)
    end)
end

hs.hotkey.bind(layout_hyper, 'j', function()
    local win = hs.window.focusedWindow()
    win:moveToScreen(win:screen():next())
end)

hs.hotkey.bind("ctrl", "[", function()
    hs.eventtap.keyStroke({}, "ESCAPE")
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

muteAttribs = {
    [true]={
        text="🔇Muted",
        color={red=1}
    },
    [false]={
        text="🎙️Mic On",
        color={green=1}
    }
}

toggleMuteState = function()
    -- toggle all devices' muted state
    local isMutedNewState = not hs.audiodevice.defaultInputDevice():muted()
    for _, dev in ipairs(hs.audiodevice.allInputDevices()) do
        dev:setMuted(isMutedNewState)
    end
    return isMutedNewState
end

toggleMute = function()
    -- toggle mute state and update UI elements
    local isMutedNewState = toggleMuteState()
    local attribs = muteAttribs[isMutedNewState]
    menubar:setTitle(attribs.text)
    hs.alert.show(attribs.text, {strokeColor={black=1}, fillColor=attribs.color}, 1)
end

originalMutedState = hs.audiodevice.defaultInputDevice():muted()
menubar = hs.menubar.new()
    :setTitle(muteAttribs[originalMutedState].text)
    :setClickCallback(toggleMute)
hs.hotkey.bind(spaces_hyper, 'm', toggleMute)

toggleAppHidden = function(appName)
    local app = hs.application.get(appName)
    if app:isHidden() then app:activate() else app:hide() end
end

appHideMapping = {
    Spotify="s",
    KeePassXC="k",
}

app_hyper = {"cmd", "ctrl"}
for app, key in pairs(appHideMapping) do
    toggleCB = helpers.bind(toggleAppHidden, app)
    hs.hotkey.bind(app_hyper, key, toggleCB)
end

-- enable if debugging
-- pl = require "pl.pretty"
-- pl.dump(myTable)
-- mouse settings for the zowie

-- zowie_events = hs.eventtap.new({
--     hs.eventtap.event.types.leftMouseUp,
--     hs.eventtap.event.types.rightMouseUp,
-- }, function(event)
--     -- print(hs.eventtap.event.types[event:getType()])
--     pressedMouseButtons = hs.eventtap.checkMouseButtons()
--     if pressedMouseButtons[5] then
--         local direction
--         if event:getType() == hs.eventtap.event.types.leftMouseUp then
--             direction = "LEFT"
--         else
--             direction = "RIGHT"
--         end
--         hs.eventtap.keyStroke({"fn", "ctrl"}, direction, 0)
--         return true
--     elseif pressedMouseButtons[4] then
--         local direction
--         if event:getType() == hs.eventtap.event.types.leftMouseUp then
--             direction = "UP"
--         else
--             direction = "DOWN"
--         end
--         hs.eventtap.keyStroke({"fn", "ctrl"}, direction, 0)
--         return true
--     else
--         return false
--     end
-- end)
-- zowie_events:start()

wf = hs.window.filter.new()
wf:keepActive()

-- create a new chooser that'll focus on whichever the selected window
window_chooser = hs.chooser.new(function(choice)
    if not choice then return end
    local win = idToWindow[choice.windowId]
    win:focus()
end)
idToWindow = {}
idToName = {}
window_chooser:choices(function()
    local ret = {}
    for _, window in pairs(wf:getWindows()) do
        idToWindow[window:id()] = window
        local assigned_name = idToName[window:id()]
        local application = window:application()
        local row = {
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
    window_chooser:selectedRow(2) -- select previous window
end)

hs.hotkey.bind(layout_hyper, "w", function()
    local window = hs.window.focusedWindow()
    hs.focus()
    local _, name = hs.dialog.textPrompt("Name this window:", "Enter the name for the focused window")
    idToName[window:id()] = name
    window:focus()
end)
