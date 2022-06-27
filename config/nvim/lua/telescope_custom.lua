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

local get_kitty_tabs = function()
    local cmd =
    [[kitty @ ls | jq -r '.[] | select(.is_focused == true) | .tabs | .[] | "\(.title) \(.id) \(.is_focused)"']]
    local output = utils.get_os_command_output({ "bash", "-c", cmd })
    local tabs = {}
    for _, line in pairs(output) do
        local linesplit = vim.split(line, " ")
        local dir = vim.env.HOME .. "/src/" .. linesplit[1]
        tabs[dir] = {
            title = linesplit[1],
            id = linesplit[2],
            is_focused = linesplit[3],
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
    local kitty_tabs = get_kitty_tabs()
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
                local path_tail = utils.path_tail(selection[1])
                local kitty_tab = kitty_tabs[ selection[1] ]

                if kitty_tab ~= nil then
                    -- if project is already open, switch to the tab
                    utils.get_os_command_output({ "kitty", "@", "focus-tab", "--match", "id:" .. kitty_tab.id })
                else
                    -- otherwise, open a new window in that project
                    utils.get_os_command_output({
                        "kitty",
                        "@",
                        "new-window",
                        "--new-tab",
                        "--cwd",
                        selection[1],
                        "--tab-title",
                        path_tail,
                    })
                end
            end)
            return true
        end,
    }):find()
end

return M
