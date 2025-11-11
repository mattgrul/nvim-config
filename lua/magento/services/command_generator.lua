---@class magento.services.command_generator
---@field env magento.core.env
local Class = require("magento.utils.class")

local CommandGenerator = Class({
    env = "env",
})

---Generate a full command array with environment wrapper
---@param name string Command name (e.g., "magento", "php")
---@param args? string[] Additional arguments
---@return string[]|nil, string|nil
function CommandGenerator:generate(name, args)
    args = args or {}

    local environment, err = self.env.get()
    if not environment then
        return nil, err or "Failed to detect environment"
    end

    local executable, exec_err = environment:executable(name)
    if not executable then
        return nil, exec_err or string.format("Executable '%s' not found", name)
    end

    -- Combine executable wrapper with arguments
    local cmd = vim.tbl_extend("force", {}, executable)

    for _, arg in ipairs(args) do
        table.insert(cmd, arg)
    end

    return cmd, nil
end

return CommandGenerator
