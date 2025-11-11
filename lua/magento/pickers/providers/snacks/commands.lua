---Snacks.nvim commands picker implementation
local common_actions = require("magento.pickers.common.actions")
local format_entry = require("magento.pickers.providers.snacks.format_entry")
local preview = require("magento.pickers.providers.snacks.preview")

local commands_picker = {}

---Run the Snacks commands picker
---@param opts table|nil Picker options
---@param commands table[] Array of command objects
function commands_picker.run(opts, commands)
    local Snacks = require("snacks")

    Snacks.picker.pick(vim.tbl_extend("force", {
        title = "Magento Commands",
        items = vim.iter(commands):map(function(command)
            return {
                value = command,
                text = command.name,
            }
        end):totable(),
        format = format_entry.command,
        preview = preview.command,
        confirm = function(picker, item)
            picker:close()
            if item then
                common_actions.magento_run(item.value)
            end
        end,
    }, opts or {}))
end

return commands_picker
