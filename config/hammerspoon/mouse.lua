local M = {}

local function bind(key, pressed, released)
  hs.hotkey.bind({}, key, pressed, released)
end

local function keyAction(modifiers, key)
  return function()
    hs.eventtap.keyStroke(modifiers, key, 0)
  end
end

local function postSystemKey(key)
  hs.eventtap.event.newSystemKeyEvent(key, true):post()
  hs.eventtap.event.newSystemKeyEvent(key, false):post()
end

local function systemKeyAction(key)
  return function()
    postSystemKey(key)
  end
end

-- Razer Basilisk V3 Pro onboard profile, configured in Synapse on Windows.
-- These F-keys stop reaching Hammerspoon while macOS Secure Input is stuck on.
-- Find the owner with `ioreg -l -w 0 | grep SecureInput`, then look up the
-- `kCGSSessionSecureInputPID` using `ps` or Activity Monitor. KeePassXC has
-- triggered this before; quitting and reopening it cleared the condition.
-- https://github.com/keepassxreboot/keepassxc/issues/11906
local SCROLL_BUMP_LEFT = 'f13'
local SCROLL_BUMP_RIGHT = 'f14'
local THUMB_PADDLE = 'f15'
local TOP_THUMB_BUTTON = 'f16'
local BOTTOM_THUMB_BUTTON = 'f17'
local TOP_MIDDLE_BUTTON = 'f18'
local BOTTOM_MIDDLE_BUTTON = 'f19'

local function newChordLayer(key, tapAction)
  local layer = {
    down = false,
    used = false,
  }

  bind(key, function()
    if not layer.down then
      layer.used = false
    end
    layer.down = true
  end, function()
    layer.down = false
    if not layer.used then
      tapAction()
    end
  end)

  return layer
end

local function runFirstChord(chords, ...)
  for _, chord in ipairs(chords or {}) do
    if chord.layer.down then
      chord.layer.used = true
      chord.action(...)
      return true
    end
  end
  return false
end

local keyboardButtonChords = {}

local function bindKeyboardButton(key, standaloneAction)
  local chords = {}
  keyboardButtonChords[key] = chords

  bind(key, function()
    if not runFirstChord(chords) then
      standaloneAction()
    end
  end)
end

local function bindKeyboardButtonChord(layer, key, action)
  table.insert(keyboardButtonChords[key], { layer = layer, action = action })
end

local eventTypes = hs.eventtap.event.types
local eventProperties = hs.eventtap.event.properties
local LEFT_MOUSE_BUTTON = 0
local RIGHT_MOUSE_BUTTON = 1
local MIDDLE_MOUSE_BUTTON = 2
local mouseDownTypes = {
  [eventTypes.leftMouseDown] = true,
  [eventTypes.rightMouseDown] = true,
  [eventTypes.otherMouseDown] = true,
}
local mouseButtonChords = {}
local scrollChords = {}

local function bindMouseButtonChord(layer, button, action)
  mouseButtonChords[button] = mouseButtonChords[button] or {}
  table.insert(mouseButtonChords[button], { layer = layer, action = action })
end

local function bindScrollChord(layer, action)
  table.insert(scrollChords, { layer = layer, action = action })
end

-- Chord layers and their standalone actions.
local paddleLayer = newChordLayer(THUMB_PADDLE, systemKeyAction('PLAY'))
local topThumbLayer = newChordLayer(TOP_THUMB_BUTTON, hs.spaces.toggleMissionControl)
local bottomThumbLayer = newChordLayer(BOTTOM_THUMB_BUTTON, keyAction({ 'cmd' }, '['))

-- Standalone button actions.
bindKeyboardButton(SCROLL_BUMP_LEFT, keyAction({ 'cmd' }, 'up'))
bindKeyboardButton(SCROLL_BUMP_RIGHT, keyAction({ 'cmd' }, 'down'))
bindKeyboardButton(TOP_MIDDLE_BUTTON, keyAction({ 'ctrl', 'cmd' }, 's'))
bindKeyboardButton(BOTTOM_MIDDLE_BUTTON, keyAction({ 'ctrl', 'cmd' }, 't'))

-- Chord actions.
bindKeyboardButtonChord(topThumbLayer, SCROLL_BUMP_LEFT, keyAction({ 'cmd', 'alt' }, 'h'))
bindKeyboardButtonChord(topThumbLayer, SCROLL_BUMP_RIGHT, keyAction({ 'cmd', 'alt' }, 'l'))

bindMouseButtonChord(paddleLayer, LEFT_MOUSE_BUTTON, systemKeyAction('PREVIOUS'))
bindMouseButtonChord(paddleLayer, RIGHT_MOUSE_BUTTON, systemKeyAction('NEXT'))
bindMouseButtonChord(paddleLayer, MIDDLE_MOUSE_BUTTON, keyAction({ 'ctrl', 'cmd' }, 's'))

bindMouseButtonChord(topThumbLayer, LEFT_MOUSE_BUTTON, keyAction({ 'fn', 'ctrl' }, 'left'))
bindMouseButtonChord(topThumbLayer, RIGHT_MOUSE_BUTTON, keyAction({ 'fn', 'ctrl' }, 'right'))
bindMouseButtonChord(topThumbLayer, MIDDLE_MOUSE_BUTTON, keyAction({ 'cmd', 'alt' }, 'k'))

bindMouseButtonChord(bottomThumbLayer, LEFT_MOUSE_BUTTON, keyAction({ 'cmd' }, '['))
bindMouseButtonChord(bottomThumbLayer, RIGHT_MOUSE_BUTTON, keyAction({ 'cmd' }, ']'))

bindScrollChord(paddleLayer, function(delta)
  postSystemKey(delta > 0 and 'SOUND_DOWN' or 'SOUND_UP')
end)

local suppressedMouseButtons = {}

M.mouseChordTap = hs.eventtap.new({
  eventTypes.leftMouseDown,
  eventTypes.leftMouseUp,
  eventTypes.rightMouseDown,
  eventTypes.rightMouseUp,
  eventTypes.otherMouseDown,
  eventTypes.otherMouseUp,
  eventTypes.scrollWheel,
}, function(event)
  local eventType = event:getType()

  if eventType == eventTypes.scrollWheel then
    local delta = event:getProperty(eventProperties.scrollWheelEventDeltaAxis1)
    if delta == 0 then
      return false
    end

    return runFirstChord(scrollChords, delta)
  end

  local button = event:getProperty(eventProperties.mouseEventButtonNumber)

  if mouseDownTypes[eventType] then
    if runFirstChord(mouseButtonChords[button]) then
      suppressedMouseButtons[button] = true
      return true
    end
    return false
  end

  if suppressedMouseButtons[button] then
    suppressedMouseButtons[button] = nil
    return true
  end
  return false
end)
M.mouseChordTap:start()

return M
