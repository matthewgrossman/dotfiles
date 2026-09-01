local M1DDC = '/opt/homebrew/bin/m1ddc'
local BRIGHTNESS_PRESETS = { 1, 50, 100 }

local function setBrightness(screen, percent)
  hs.task.new(M1DDC, function(exitCode, _, stdErr)
    if exitCode ~= 0 then
      hs.alert.show(string.format(
        'Could not set brightness for %s%s',
        screen:name(),
        stdErr ~= '' and ': ' .. stdErr or ''
      ))
    end
  end, {
    'display',
    'id=' .. screen:id(),
    'set',
    'luminance',
    tostring(percent),
  }):start()
end

local function addBrightnessSection(menu, title, screens)
  table.insert(menu, { title = title, disabled = true })

  for _, percent in ipairs(BRIGHTNESS_PRESETS) do
    local brightness = percent
    table.insert(menu, {
      title = brightness .. '%',
      indent = 1,
      fn = function()
        for _, screen in ipairs(screens) do
          setBrightness(screen, brightness)
        end
      end,
    })
  end
end

local function buildMenu()
  local screens = hs.screen.allScreens()
  table.sort(screens, function(a, b)
    return a:name() < b:name()
  end)

  local displays = {}
  if #screens == 0 then
    table.insert(displays, { title = 'No connected displays', disabled = true })
  else
    addBrightnessSection(displays, 'All Displays', screens)

    for _, screen in ipairs(screens) do
      table.insert(displays, { title = '-' })
      addBrightnessSection(displays, screen:name(), { screen })
    end
  end

  return {
    { title = 'Displays', menu = displays },
    { title = '-' },
    { title = 'Reload Hammerspoon', fn = hs.reload },
  }
end

local function new()
  local menu = hs.menubar.new(true, 'Hammerspoon Utilities')
  menu:setTitle('⚙︎')
  menu:setTooltip('Hammerspoon Utilities')
  menu:setMenu(buildMenu())
  return menu
end

return { new = new }
