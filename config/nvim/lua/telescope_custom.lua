local M = {}

local actions = require("telescope.actions")
M.project_files = function()
    local ok = pcall(require("telescope.builtin").git_files, { show_untracked = false })
    if not ok then
        require("telescope.builtin").find_files()
    end
end

local pickers = require("telescope.pickers")
local finders = require("telescope.finders")
local conf = require("telescope.config").values
local utils = require("telescope.utils")

M.get_terminal_tabs = function()
    local cmd = [[wezterm cli list --format json | jq -r '.[] | "\(.cwd) \(.pane_id)"']]

    local output = utils.get_os_command_output({ "bash", "-c", cmd })
    local tabs = {}
    for _, line in pairs(output) do
        local linesplit = vim.split(line, " ")
        local dir = string.sub(linesplit[1], 8)
        tabs[dir] = {
            id = linesplit[2],
            is_focused = linesplit[2] == vim.env.WEZTERM_PANE,
        }
    end
    return tabs
end

M.src_dir = function(opts)
    local src_directories = utils.get_os_command_output({
        "find",
        vim.env.HOME .. "/src",
        "-mindepth",
        "1",
        "-maxdepth",
        "1",
        "-type",
        "d",
    })
    opts = opts or {}
    local terminal_tabs = M.get_terminal_tabs()
    local action_state = require("telescope.actions.state")
    pickers.new(opts, {
        prompt_title = "~/src",
        finder = finders.new_table({
            results = src_directories,
        }),
        sorter = conf.generic_sorter(opts),
        attach_mappings = function(prompt_bufnr, _)
            actions.select_default:replace(function()
                actions.close(prompt_bufnr)
                local selection = action_state.get_selected_entry()
                local terminal_tab = terminal_tabs[selection[1]]
                local path_tail = utils.path_tail(selection[1])

                if terminal_tab ~= nil then
                    -- if project is already open, switch to the tab
                    utils.get_os_command_output({ "wezterm", "cli", "activate-pane", "--pane-id", terminal_tab.id })
                else
                    -- otherwise, open a new window in that project
                    local pane_id = utils.get_os_command_output({
                        "wezterm",
                        "cli",
                        "spawn",
                        "--cwd",
                        selection[1],
                        "--",
                        vim.env.SHELL,
                    })
                    utils.get_os_command_output({
                        "wezterm",
                        "cli",
                        "set-tab-title",
                        "--pane-id",
                        pane_id[1],
                        path_tail

                    })
                end
            end)
            return true
        end,
    }):find()
end

return M
