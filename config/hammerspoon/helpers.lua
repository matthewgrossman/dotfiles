local M = {}

M.getTableKeys = function(tab)
  local keyset = {}
  for k, _ in pairs(tab) do
    keyset[#keyset + 1] = k
  end
  return keyset
end

threshold = 0.01
M.approxEqualRects = function(left, right)
  isApproxEqual = true
  for _, key in ipairs({ 'x', 'y', 'w', 'h' }) do
    if math.abs(left[key] - right[key]) > threshold then
      isApproxEqual = false
    end
  end
  return isApproxEqual
end

M.withAXFix = function(win, f, ...)
  -- decorator for function like:
  -- win:moveToUnit(layout)     =>
  -- Helpers.withAXFix(win, win.moveToUnit, layout)

  local func = M.bind(f, win, ...)
  local axApp = hs.axuielement.applicationElement(win:application())
  local oldAxEnhanced = axApp.AXEnhancedUserInterface
  axApp.AXEnhancedUserInterface = false
  func()
  axApp.AXEnhancedUserInterface = oldAxEnhanced
end

-- binds ALL args to f; making a proper bind() in lua seems to be a PITA
M.bind = function(f, ...)
  local bindargs = { ... }
  return function()
    return f(table.unpack(bindargs))
  end
end

-- iterate over list of hs.eventtap.event and :post() each one
M.postEvents = function(events)
  for _, event in ipairs(events) do
    event:post()
  end
end

return M
