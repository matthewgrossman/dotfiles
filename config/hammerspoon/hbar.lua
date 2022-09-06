-- HBar, meant to create a nice wrapper around hs.menubar

HBar = {}
HBar.__index = HBar

function HBar.new(i)
    local c = {}
    i = i or {}

    c.cmd = i.cmd or "/bin/ls"
    c.args = i.args or {}
    c.delay = i.delay or 5

    c.menubar = hs.menubar.new(false)
    return setmetatable(c, HBar)
end

function HBar:refresh()
    local task = hs.task.new(self.cmd, nil, self.args)
    -- try using hs.execute instead? we're already async
    task:setCallback(function(_, stdOut, _)
        local result = stdOut:gsub("[\n\r]", "")
        self.menubar:setTitle(result)
        self.menubar:returnToMenuBar(stdOut)
    end):start()
end

function HBar:start()
    local function _bind_refresh()
        return HBar.refresh(self)
    end
    self.timer = hs.timer.doEvery(self.delay, _bind_refresh)
end

function HBar:stop()
    self.timer:stop()
end

return HBar
