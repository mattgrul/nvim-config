---@class magento.core.factory
---Factory for creating service instances with dependency injection
---Based on Laravel.nvim's factory pattern
local M = {}

---Create a factory function for a module
---@param app magento.core.app
---@param moduleName string Module path to require
---@return function Factory function that creates instances
function M:create(app, moduleName)
    return function(arguments)
        arguments = arguments or {}

        -- Require the module
        local ok, module = pcall(require, moduleName)
        if not ok then
            error(string.format("Could not load module '%s': %s", moduleName, module))
        end

        -- If module has no constructor, return it as-is
        if not module.new then
            return module
        end

        -- Check if module uses Class helper with _inject metadata
        local injects = module._inject
        if injects and not vim.tbl_isempty(injects) then
            -- Module uses Class helper - let it handle DI
            return module:new()
        end

        -- Plain module with :new() method - just call it
        return module:new()
    end
end

---Create a concrete factory from different types
---@param app magento.core.app
---@param concrete string|table|function
---@return function Factory function
function M:createConcrete(app, concrete)
    local concreteType = type(concrete)

    if concreteType == "string" then
        -- Module path - create factory that requires and instantiates
        return M:create(app, concrete)
    elseif concreteType == "table" then
        -- Direct value - wrap in function
        return function()
            return concrete
        end
    elseif concreteType == "function" then
        -- Already a factory function
        return concrete
    else
        error(string.format("Concrete must be string, table, or function, got %s", concreteType))
    end
end

return M
