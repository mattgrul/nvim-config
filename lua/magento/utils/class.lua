---Simple Class implementation with dependency injection
---Based on laravel.nvim's class pattern
---@param deps table|nil Table of dependencies to inject from app container
---@param defaults table|nil Default values for instance
---@return table
local function Class(deps, defaults)
    deps = deps or {}
    defaults = defaults or {}

    local cls = {}

    function cls:new(...)
        local app = require("magento.core.app")
        local instance = {}

        -- Inject dependencies from container
        for key, service_name in pairs(deps) do
            instance[key] = app:make(service_name)
        end

        -- Apply default values
        for key, value in pairs(defaults) do
            instance[key] = value
        end

        setmetatable(instance, { __index = cls })

        -- Call constructor if exists
        if cls.init then
            cls.init(instance, ...)
        end

        return instance
    end

    return cls
end

return Class
