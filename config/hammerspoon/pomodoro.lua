-- Minimal pomodoro timer, shown as a suffix on a menubar item's title.

local PHASES = {
  { name = 'Focus', icon = '🍅', minutes = 25 },
  { name = 'Short break', icon = '☕', minutes = 5 },
  { name = 'Long break', icon = '☕', minutes = 15 },
}

local function new(setSuffix)
  local self = {}
  local timer

  function self.stop()
    if timer then
      timer:stop()
      timer = nil
    end
    setSuffix('')
  end

  local function start(phase)
    self.stop()
    local minutesLeft = phase.minutes
    setSuffix(' ' .. phase.icon .. ' ' .. minutesLeft .. 'm')

    timer = hs.timer.doEvery(60, function()
      minutesLeft = minutesLeft - 1
      if minutesLeft > 0 then
        setSuffix(' ' .. phase.icon .. ' ' .. minutesLeft .. 'm')
      else
        timer:stop()
        timer = nil
        setSuffix(' ' .. phase.icon .. ' done')
        hs.notify.new({ title = phase.name .. ' done', soundName = 'Glass' }):send()
      end
    end)
  end

  function self.menu()
    local items = {}
    for _, phase in ipairs(PHASES) do
      table.insert(items, {
        title = string.format('%s %s (%dm)', phase.icon, phase.name, phase.minutes),
        fn = function()
          start(phase)
        end,
      })
    end
    table.insert(items, { title = '-' })
    table.insert(items, { title = 'Stop', fn = self.stop })
    return items
  end

  return self
end

return { new = new }
