-- Rex configuration, migrated from config/herdr/ and config/herdr-app/keys.json.
-- Apply changes with `rex config reload`; check them with `rex config check`.
--
-- Only keys that differ from Rex's defaults are bound here. Already default:
-- cmd+t, ctrl+tab, shift+cmd+[ ], cmd+1..9, cmd+p, shift+cmd+p, cmd+d,
-- shift+cmd+d, shift+cmd+enter, alt+cmd+arrows, alt+shift+cmd+arrows,
-- cmd+= / cmd+- / cmd+0, and alt/cmd+left/right/backspace line editing.

local terminal = "com.superlogical.terminal"
local prefix = "ctrl+/"

local function leader(key)
  return prefix .. ">" .. key
end

-- Sessions (Herdr spaces)
rex.bind("cmd+j", "session.next")
rex.bind("cmd+k", "session.previous")
rex.bind("alt+cmd+]", "session.next")
rex.bind("alt+cmd+[", "session.previous")
rex.bind("cmd+n", "session.new")
rex.bind("shift+cmd+n", "client.window.new")
rex.bind("shift+f2", "session.rename")

rex.action{
  name = "session_goto",
  title = "Go to Session by Number",
  category = "Session",
  args = { index = "integer" },
  run = function(ctx, args)
    local list, err = rex.call("session.list")
    if list == nil then error(err, 0) end
    local session = (list.sessions or {})[args.index]
    if session == nil then return end
    rex.client.queue("session.select", { session_id = session.session_id })
  end,
}

for i = 1, 9 do
  rex.bind("ctrl+[Digit" .. i .. "]", "session_goto", { index = i })
end

-- Worktrees: a new session named PROJECT/NAME, placed after the project's other
-- sessions, whose first tab runs `wt switch --create NAME` in the focused pane's
-- repository. PROJECT is the current session's label up to its first "/". wt's
-- shell integration then cds the tab into the worktree, and its hooks run where
-- you can watch them.
local adjectives = { "amber", "brisk", "calm", "green", "quiet", "rapid", "silver", "swift" }
local nouns = { "field", "harbor", "meadow", "otter", "pine", "river", "summit", "willow" }

local function suggest_name()
  math.randomseed(os.time())
  return string.format("%s-%s-%d", adjectives[math.random(#adjectives)],
    nouns[math.random(#nouns)], math.random(1000, 9999))
end

local rex_cli = "Library/Application Support/com.superlogical.rex/RexServer/Versions/Current/Rex Server.app/Contents/MacOS/rex"

local function pane_cwd(block_id)
  local proc = block_id and rex.block.call(terminal, "process", { block_id = block_id })
  if not proc then return nil end
  if proc.foreground and proc.foreground.cwd then return proc.foreground.cwd end
  for _, p in ipairs(proc.ancestors or {}) do
    if p.cwd then return p.cwd end
  end
end

rex.action{
  name = "new_worktree",
  title = "New Worktree",
  category = "Git",
  description = "Creates a branch and worktree with wt and opens it in a new session.",
  keywords = "git branch worktrunk wt",
  args = { name = "string?" },
  run = function(ctx, args)
    local name = args.name
    if name == nil or name == "" then name = suggest_name() end
    if not name:match("^[%w][%w._/-]*$") then
      error("not a usable branch name: " .. name, 0)
    end

    local cwd = pane_cwd(ctx.block_id)
    if cwd == nil then error("can't tell which directory the focused pane is in", 0) end
    local git, err = rex.exec({ "git", "-C", cwd, "rev-parse", "--show-toplevel" }, { timeout = 5 })
    if git == nil then error(err, 0) end
    if not git.ok then error(cwd .. " isn't in a git repository", 0) end

    local list
    list, err = rex.call("session.list")
    if list == nil then error(err, 0) end
    local sessions = list.sessions or {}
    local project
    for _, s in ipairs(sessions) do
      if s.session_id == ctx.session_id then project = s.label:match("^[^/]+") end
    end
    if project == nil then error("can't tell which session this is", 0) end

    local created
    created, err = rex.call("session.create", {
      label = project .. "/" .. name,
      initial_windows = { {
        window_label = name,
        layout = rex.layout.block{
          flavor = "com.superlogical.terminal.shell",
          options = {
            cwd = (git.stdout:gsub("%s+$", "")),
            initial_input = "wt switch --create " .. name .. "\r",
          },
        },
      } },
    })
    if created == nil then error(err, 0) end

    -- New sessions go last, so move it just after the project's other sessions.
    local function in_project(s)
      return s.label == project or s.label:sub(1, #project + 1) == project .. "/"
    end
    local last
    for i, s in ipairs(sessions) do
      if in_project(s) then
        last = i
      elseif last then
        break
      end
    end
    local next_session = last and sessions[last + 1]
    if next_session then
      -- The session.move API only acts on a session the caller is attached
      -- to, which the CLI takes care of. The server's PATH lacks rex.
      local mv
      mv, err = rex.exec({ "sh", "-c", '"$HOME/' .. rex_cli .. '" session move "$1" --before "$2"',
        "sh", created.session_id, next_session.session_id }, { timeout = 5 })
      if mv == nil or not mv.ok then
        error("created " .. project .. "/" .. name .. " but couldn't move it: "
          .. tostring(err or mv.stderr), 0)
      end
    end

    -- Switch the app to it when run from the app. From the CLI, the app
    -- refuses client actions unless Remote Control is on.
    if ctx.origin == "key" or ctx.origin == "palette" then
      rex.client.queue("session.select", { session_id = created.session_id })
    end
    return { branch = name, session_id = created.session_id }
  end,
}

-- Tabs and panes
rex.bind("cmd+w", "client.tab.close")
rex.bind("shift+cmd+w", "pane.close")
rex.bind("f2", "client.tab.rename")
rex.bind("cmd+b", "client.sidebar.toggle")
rex.bind("ctrl+;", "pane.zoom")
rex.bind("alt+backspace", "pane.send_key", { key = "ctrl+w" })

-- Vim-aware ctrl+h/j/k/l. When Vim is in front the key reaches it, and its
-- own mapping (config/nvim/lua/vim_rex_navigation.lua) hands off to
-- `rex focus` at a split edge. Otherwise the key moves focus between panes.
local function is_vim(name)
  name = (name or ""):lower():gsub("^g", ""):gsub("diff$", "")
  return name == "view" or name:match("^l?n?vim?x?$") ~= nil
end

local nav_keys = { h = "left", j = "down", k = "up", l = "right" }

for key, direction in pairs(nav_keys) do
  rex.bind("ctrl+" .. key, function(ctx)
    local proc = ctx.block_id and rex.block.call(terminal, "process", { block_id = ctx.block_id })
    if proc and proc.foreground and is_vim(proc.foreground.name) then
      return false
    end
    rex.session.focus_direction{ direction = direction }
    return true
  end)
end

-- Prefix sequences (Herdr's ctrl+/ prefix)
rex.bind(leader("y"), "pane.copy_id")
rex.bind(leader("ctrl+/"), "pane.send_key", { key = "ctrl+/" })
