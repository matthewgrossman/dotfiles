-- This file contains no longer used snippets. Rather than deleting them,
-- I'm just moving them elsewhere for easier future reference.

MuteAttribs = {
  [true] = {
    text = '🔇Muted',
    color = { red = 1 },
  },
  [false] = {
    text = '🎙️Mic On',
    color = { green = 1 },
  },
}

ToggleMuteState = function()
  -- toggle default devices' muted state

  -- this used to toggle all devices to be safe, but there's a bug in monterey that
  -- mutes output whenever input is also muted.
  -- https://github.com/Hammerspoon/hammerspoon/issues/2965
  local device = hs.audiodevice.defaultInputDevice()
  if device == nil then
    hs.alert.show('no default audio input device')
    return
  end
  local isMutedNewState = not device:muted()
  device:setMuted(isMutedNewState)
  return isMutedNewState
end

ToggleMute = function()
  -- toggle mute state and update UI elements
  local isMutedNewState = ToggleMuteState()
  local attribs = MuteAttribs[isMutedNewState]
  Menubar:setTitle(attribs.text)
  hs.alert.show(attribs.text, { strokeColor = { black = 1 }, fillColor = attribs.color }, 1)
end

OriginalMutedState = hs.audiodevice.defaultInputDevice():muted()
Menubar = hs.menubar.new():setTitle(MuteAttribs[OriginalMutedState].text):setClickCallback(ToggleMute)
hs.hotkey.bind(AppHyper, 'm', ToggleMute)

-- create a keybind for play/pause on spotify, so we can map our mouse to it
hs.hotkey.bind(AppHyper, '0', function()
  if hs.spotify.isPlaying() then
    hs.spotify.pause()
  else
    hs.spotify.play()
  end
end)

-- <snippet> Implements alt-tab for windows in macos
WindowChooser = hs.chooser.new(function(choice)
  if not choice then
    return
  end
  local win = IdToWindow[choice.windowId]
  win:focus()
end)
IdToWindow = {}
IdToName = {}
ChoicesLength = 0
WindowChooser:choices(function()
  local ret = {}
  local length = 0
  for _, window in pairs(WF:getWindows()) do
    IdToWindow[window:id()] = window
    local assigned_name = IdToName[window:id()]
    local row = {
      text = assigned_name or window:title(),
      windowId = window:id(),
      image = hs.image.imageFromAppBundle(window:application():bundleID()),
    }
    table.insert(ret, row)
    length = length + 1
  end
  ChoicesLength = length
  return ret
end)

hs.hotkey.bind('alt', 'tab', function()
  -- if the chooser is already open, advance to next row
  if WindowChooser:isVisible() then
    local nextRow = WindowChooser:selectedRow() + 1
    if nextRow > ChoicesLength then
      nextRow = 1
    end
    WindowChooser:selectedRow(nextRow)
  else
    WindowChooser:refreshChoicesCallback()
    WindowChooser:query(nil)
    WindowChooser:show()
    WindowChooser:selectedRow(2) -- select previous window
  end
end)

hs.hotkey.bind({ 'shift', 'alt' }, 'tab', function()
  -- if the chooser is already open, go up a row
  if WindowChooser:isVisible() then
    local prevRow = WindowChooser:selectedRow() - 1
    if prevRow == 0 then
      prevRow = ChoicesLength
    end
    WindowChooser:selectedRow(prevRow)
  end
end)

hs.hotkey.bind(LayoutHyper, 'w', function()
  local window = hs.window.focusedWindow()
  hs.focus()
  local _, name = hs.dialog.textPrompt('Name this window:', 'Enter the name for the focused window')
  IdToName[window:id()] = name
  window:focus()
end)

-- </snippet>

-- HRWindow shenanigans {{{
-- luacheck:ignore
HRWindowThings = function()
  HRWindow = nil
  URLTitleSubstring = 'PDHE'
  for _, window in pairs(WF:getWindows()) do
    if string.find(window:title(), URLTitleSubstring) then
      HRWindow = window
    end
  end
  HRApplication = HRWindow:application()

  -- use this keybind because I have a mousebutton bound to it
  hs.hotkey.bind({ 'cmd', 'ctrl' }, 'm', function()
    local oldWindow = hs.window.focusedWindow()
    HRWindow:focus()
    hs.eventtap.keyStroke({ 'ctrl', 'alt' }, '.', 200, HRApplication) -- next
    hs.eventtap.keyStroke({ 'ctrl', 'alt' }, 's', 200, HRApplication) -- submit
    oldWindow:focus()
  end)
end

-- HRWindowThings()
--- }}}
