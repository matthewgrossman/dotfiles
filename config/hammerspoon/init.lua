Helpers = require('helpers')

-- gotta go fast
hs.window.animationDuration = 0

LayoutHyper = { 'cmd', 'alt' }

LayoutLeft66 = { x = 0, y = 0, w = 0.6666, h = 1 }
LayoutLeft33 = { x = 0, y = 0, w = 0.3333, h = 1 }
LayoutRight33 = { x = 0.6666, y = 0, w = 0.3333, h = 1 }
LayoutRight66 = { x = 0.3333, y = 0, w = 0.6666, h = 1 }
LayoutHorizMiddle33 = { x = 0.3333, y = 0, w = 0.3333, h = 1 }
LayoutUpperLeft = { x = 0, y = 0, w = 0.5, h = 0.5 }
LayoutUpperRight = { x = 0.5, y = 0, w = 0.5, h = 0.5 }
LayoutLowerRight = { x = 0.5, y = 0.5, w = 0.5, h = 0.5 }
LayoutLowerLeft = { x = 0, y = 0.5, w = 0.5, h = 0.5 }
LayoutUpperRightSixth = { x = 0.6666, y = 0, w = 0.3333, h = 0.5 }
LayoutLowerRightSixth = { x = 0.6666, y = 0.5, w = 0.3333, h = 0.5 }
LayoutLowerLeftSixth = { x = 0, y = 0.5, w = 0.3333, h = 0.5 }
LayoutUpperLeftSixth = { x = 0, y = 0, w = 0.3333, h = 0.5 }

LayoutVertBottom33 = { x = 0, y = 0.6666, w = 1, h = 0.3333 }
LayoutBottomHalf = { x = 0, y = 0.5, w = 1, h = 0.5 }
LayoutVertBottom66 = { x = 0, y = 0.3333, w = 1, h = 0.6666 }

LayoutVertMiddle33 = { x = 0, y = 0.3333, w = 1, h = 0.3333 }

LayoutVertTop33 = { x = 0, y = 0, w = 1, h = 0.3333 }
LayoutTopHalf = { x = 0, y = 0, w = 1, h = 0.5 }
LayoutVertTop66 = { x = 0, y = 0, w = 1, h = 0.6666 }

LayoutMapping = {
  h = { LayoutLeft33, hs.layout.left50, LayoutLeft66 },
  l = { LayoutRight33, hs.layout.right50, LayoutRight66 },
  k = {
    tall = { LayoutVertTop33, LayoutTopHalf, LayoutVertTop66 },
    wide = { LayoutHorizMiddle33, hs.layout.maximized },
  },
  j = {
    tall = { LayoutVertBottom33, LayoutBottomHalf, LayoutVertBottom66 },
    wide = { LayoutTopHalf, LayoutBottomHalf },
  },
  m = { LayoutLowerRightSixth, LayoutLowerRight },
  n = { LayoutLowerLeftSixth, LayoutLowerLeft },
  o = { LayoutUpperRightSixth, LayoutUpperRight },
  u = { LayoutUpperLeftSixth, LayoutUpperLeft },
}
for key, layouts in pairs(LayoutMapping) do
  hs.hotkey.bind(LayoutHyper, key, function()
    local w = hs.window.focusedWindow()
    local screenFrame = w:screen():frame()

    local layout
    if layouts.x ~= nil then
      -- if single layout is passed (checked existence of 'x'), directly apply layout
      layout = layouts
    else
      local usedLayouts = layouts
      if layouts.tall ~= nil then
        -- use different configs depending on if its a tall or wide screen
        if screenFrame.h > screenFrame.w then
          usedLayouts = layouts.tall
        else
          usedLayouts = layouts.wide
        end
      end
      -- otherwise, cycle through the layout sizes
      local windowFrame = w:frame()
      local currentUnitRect = windowFrame:toUnitRect(screenFrame)

      local unitRectIndex = 2 -- arbitrarily choose the 50% layout as default
      for i, unitRect in ipairs(usedLayouts) do
        if Helpers.approxEqualRects(currentUnitRect, unitRect) then
          unitRectIndex = i + 1
          break
        end
      end
      if unitRectIndex > #usedLayouts then
        unitRectIndex = 1
      end -- wrap around
      layout = usedLayouts[unitRectIndex]
    end
    local win = hs.window.focusedWindow()

    Helpers.withAXFix(win, win.moveToUnit, layout)
  end)
end

hs.hotkey.bind(LayoutHyper, 'return', function()
  local win = hs.window.focusedWindow()
  Helpers.withAXFix(win, win.moveToScreen, win:screen():next())
end)

hs.hotkey.bind(LayoutHyper, 'v', function()
  hs.eventtap.keyStrokes(hs.pasteboard.getContents())
end)

hs.hotkey.bind('ctrl', '[', function()
  hs.eventtap.keyStroke({}, 'ESCAPE')
end)

-- hs.hotkey.bind("ctrl", "w", function()
--     hs.eventtap.keyStroke({"cmd"}, "delete")
-- end)

hs.hotkey.bind(LayoutHyper, 'r', function()
  hs.reload()
end)

-- spaces_hyper = {"ctrl", "shift"}
-- spaces_mapping = {
--     h = "LEFT",
--     l = "RIGHT"
-- }

-- currently has bug that requires "fn" as additional modifier
-- https://github.com/Hammerspoon/hammerspoon/issues/1946#issuecomment-449604954
-- getSpacesEvents = function(direction)
--     return {
--         hs.eventtap.event.newKeyEvent({"fn", "ctrl"}, direction, true),
--         hs.eventtap.event.newKeyEvent({"fn", "ctrl"}, direction, false)
--     }
-- end

-- for key, direction in pairs(spaces_mapping) do
--     hs.hotkey.bind(spaces_hyper, key, function()
--         hs.even.keyStroke({"fn", "ctrl"}, direction)
--         -- Helpers.postEvents(getSpacesEvents(direction))
--     end)
-- end

AppHyper = { 'cmd', 'ctrl' }
-- create a keybind for play/pause on spotify, so we can map our mouse to it
hs.hotkey.bind(AppHyper, '0', function()
  if hs.spotify.isPlaying() then
    hs.spotify.pause()
  else
    hs.spotify.play()
  end

  -- seems to have issues focusing, and requires multiple presses
  -- hs.spotify.playpause()

  -- system key events have the problem that all macos mediakey has;
  -- event gets forwarded to go to some often random app
  -- hs.eventtap.event.newSystemKeyEvent('PLAY', true):post()
  -- hs.eventtap.event.newSystemKeyEvent('PLAY', false):post()
end)

ApplicationIsOnMainScreen = function(app)
  return app:mainWindow():screen() == hs.screen:primaryScreen()
end

ToggleAppHidden = function(appName)
  local app = hs.application.get(appName)
  if app == nil or app:isHidden() then
    hs.application.open(appName)
  else
    app:hide()
  end
end

HideApp = function(appName)
  local app = hs.application.get(appName)
  if app == nil then
    return
  end
  if not app:isHidden() and ApplicationIsOnMainScreen(app) then
    app:hide()
  end
end

AppHideMapping = {
  Spotify = { key = 's', shouldMinimize = true },
  KeePassXC = { key = 'k', shouldMinimize = true },
  Todoist = { key = 't', shouldMinimize = true },
  ['Google Meet'] = { key = 'h', shouldMinimize = false },
  Slack = { key = 'r', shouldMinimize = false },
}

for app, attribs in pairs(AppHideMapping) do
  local toggleCB = Helpers.bind(ToggleAppHidden, app)
  hs.hotkey.bind(AppHyper, attribs.key, toggleCB)
end

-- for tabUrl, key in pairs(tabHideMapping) do
--     toggleCB = Helpers.bind(toggleWindowHidden, tabUrl)
--     hs.hotkey.bind(AppHyper, key, toggleCB)
-- end

SpacesWatcher = hs.spaces.watcher.new(function(_)
  for appName, attribs in pairs(AppHideMapping) do
    if attribs.shouldMinimize then
      HideApp(appName)
    end
  end
end)
SpacesWatcher:start()

WF = hs.window.filter.new()

-- note to self on hs.task.new()
-- you *can* pass the callbackFn as the 2nd arg, but we use nil there and then
-- call `setCallback` before starting the task.
-- I did this to keep the arguments on the same line as the program we're launching,
-- a purely aesthetic move

-- disable bluetooth and store the currently connected devices in `ConnectedDevices`
local disableBluetooth = function()
  hs.task
    .new('/opt/homebrew/bin/blueutil', nil, { '--connected', '--format', 'json' })
    :setCallback(function(_, stdOut, _)
      ConnectedDevices = hs.json.decode(stdOut)
      for _, device in ipairs(ConnectedDevices) do
        print('Remembering connected device: ' .. device['name'] .. ', ' .. device['address'])
      end

      hs.task
        .new('/opt/homebrew/bin/blueutil', nil, { '--power', '0' })
        :setCallback(function()
          print('Disabled bluetooth')
        end)
        :start()
    end)
    :start()
end

-- reenable bluetooth and connect to devices in `ConnectedDevices`
local enableBluetooth = function()
  hs.task
    .new('/opt/homebrew/bin/blueutil', nil, { '--power', '1' })
    :setCallback(function()
      for _, device in ipairs(ConnectedDevices) do
        print('Connecting to device: ' .. device['name'] .. ', ' .. device['address'] .. '...')
        hs.task
          .new('/opt/homebrew/bin/blueutil', nil, { '--connect', device['address'] })
          :setCallback(function(exitCode, _, _)
            if exitCode == 1 then
              print('Failed to connect to device: ' .. device['name'] .. ', ' .. device['address'] .. '!')
            else
              print('Connected to device: ' .. device['name'] .. ', ' .. device['address'] .. '!')
            end
          end)
          :start()
      end
    end)
    :start()
end

ConnectedDevices = {}
LockWatcher = hs.caffeinate.watcher.new(function(event)
  if event == hs.caffeinate.watcher.screensDidLock then
    disableBluetooth()
  end
  if event == hs.caffeinate.watcher.screensDidUnlock then
    enableBluetooth()
  end
end)
LockWatcher:start()

-- try to find out which device it came from
-- eventtap = hs.eventtap.new({ hs.eventtap.event.types.keyDown }, function(event)
--   for key, value in pairs(hs.eventtap.event.properties) do
--     print(key .. ': ' .. event:getProperty(value))
--   end
--   return false
-- end)
