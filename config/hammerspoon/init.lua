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
layoutBottomHalf = {x=0, y=.5, w=1, h=.5}
layoutTopHalf = {x=0, y=0, w=1, h=.5}

layout_mapping = {
    h = {layoutLeft33, hs.layout.left50, layoutLeft66},
    l = {layoutRight33, hs.layout.right50, layoutRight66},
    k = {layoutMiddle33, hs.layout.maximized},
    j = {layoutBottomHalf, layoutTopHalf},
    m = {layoutLowerRightSixth, layoutLowerRight},
    n = {layoutLowerLeftSixth, layoutLowerLeft},
    o = {layoutUpperRightSixth, layoutUpperRight},
    u = {layoutUpperLeftSixth, layoutUpperLeft},
}
for key, layouts in pairs(layout_mapping) do
    hs.hotkey.bind(layout_hyper, key, function()
        if layouts.x ~= nil then
            -- if single layout is passed (checked existence of 'x'), directly apply layout
            layout = layouts
        else
            -- otherwise, cycle through the layout sizes
            local w = hs.window.focusedWindow()
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

hs.hotkey.bind(layout_hyper, 'return', function()
    local win = hs.window.focusedWindow()
    win:moveToScreen(win:screen():next())
end)

hs.hotkey.bind("ctrl", "[", function()
    hs.eventtap.keyStroke({}, "ESCAPE")
end)

hs.hotkey.bind(layout_hyper, "r", function()
    hs.reload()
end)


spaces_hyper = {"ctrl", "shift"}
spaces_mapping = {
    h = "LEFT",
    l = "RIGHT"
}

-- currently has bug that requires "fn" as additional modifier
-- https://github.com/Hammerspoon/hammerspoon/issues/1946#issuecomment-449604954
-- getSpacesEvents = function(direction)
--     return {
--         hs.eventtap.event.newKeyEvent({"fn", "ctrl"}, direction, true),
--         hs.eventtap.event.newKeyEvent({"fn", "ctrl"}, direction, false)
--     }
-- end

for key, direction in pairs(spaces_mapping) do
    hs.hotkey.bind(spaces_hyper, key, function()
        hs.even.keyStroke({"fn", "ctrl"}, direction)
        -- helpers.postEvents(getSpacesEvents(direction))
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
    -- toggle default devices' muted state

    -- this used to toggle all devices to be safe, but there's a bug in monterey that 
    -- mutes output whenever input is also muted.
    -- https://github.com/Hammerspoon/hammerspoon/issues/2965
    local device = hs.audiodevice.defaultInputDevice()
    local isMutedNewState = not device:muted()
    device:setMuted(isMutedNewState)
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
    if app == nil or app:isHidden() then
        hs.application.open(appName)
    else
        app:hide()
    end
end

hideApp = function(appName)
    local app = hs.application.get(appName)
    if app == nil then return end
    if not app:isHidden() then app:hide() end
end

appHideMapping = {
    Spotify="s",
    KeeWeb="k",
    Todoist="t",
}

app_hyper = {"cmd", "ctrl"}
for app, key in pairs(appHideMapping) do
    toggleCB = helpers.bind(toggleAppHidden, app)
    hs.hotkey.bind(app_hyper, key, toggleCB)
end

spacesWatcher = hs.spaces.watcher.new(function(_)
    for appName in pairs(appHideMapping) do
        hideApp(appName)
    end
end)
spacesWatcher:start()

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
choicesLength = 0
window_chooser:choices(function()
    local ret = {}
    local length = 0
    for _, window in pairs(wf:getWindows()) do
        idToWindow[window:id()] = window
        local assigned_name = idToName[window:id()]
        local row = {
            text = assigned_name or window:title(),
            windowId = window:id(),
            image = hs.image.imageFromAppBundle(window:application():bundleID())
        }
        table.insert(ret, row)
        length = length + 1
    end
    choicesLength = length
    return ret
end)

hs.hotkey.bind('alt', 'tab', function()

    -- if the chooser is already open, advance to next row
    if window_chooser:isVisible() then
        nextRow = window_chooser:selectedRow()+1
        if nextRow > choicesLength then nextRow = 1 end
        window_chooser:selectedRow(nextRow)
    else
        window_chooser:refreshChoicesCallback()
        window_chooser:query(nil)
        window_chooser:show()
        window_chooser:selectedRow(2) -- select previous window
    end
end)

hs.hotkey.bind({'shift', 'alt'}, 'tab', function()

    -- if the chooser is already open, go up a row
    if window_chooser:isVisible() then
        prevRow = window_chooser:selectedRow()-1
        if prevRow == 0 then prevRow = choicesLength end
        window_chooser:selectedRow(prevRow)

    end
end)

hs.hotkey.bind(layout_hyper, "w", function()
    local window = hs.window.focusedWindow()
    hs.focus()
    local _, name = hs.dialog.textPrompt("Name this window:", "Enter the name for the focused window")
    idToName[window:id()] = name
    window:focus()
end)
