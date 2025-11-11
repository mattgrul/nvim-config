---Commands picker data loader
---Based on laravel.nvim's picker pattern
local Class = require("magento.utils.class")
local notify = require("magento.utils.notify")

---@class magento.pickers.commands
---@field commands_loader magento.loaders.commands_cache_loader
---@field env magento.core.env
local commands_picker = Class({
    commands_loader = "magento.loaders.commands_cache_loader",
    env = "env",
})

---Run the commands picker
---@param picker table Provider implementation (e.g., snacks provider)
---@param opts table|nil Picker options
function commands_picker:run(picker, opts)
    -- Load commands from cache loader
    local commands = self.commands_loader:load()

    if #commands == 0 then
        notify.warn("No Magento commands found")
        return
    end

    -- Delegate to provider implementation
    vim.schedule(function()
        picker.run(opts, commands)
    end)
end

return commands_picker
