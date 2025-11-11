---@class magento.core.bootstrap
local M = {}

---Bootstrap the application and create global helper
---@param app magento.core.app
---@param opts table Configuration options
function M:bootstrap(app, opts)
    -- Create global Magento helper (Laravel.nvim pattern)
    -- Can be called as:
    --   Magento() -> returns app
    --   Magento("cache") -> returns app:make("cache")
    --   Magento.app -> access app directly
    _G.Magento = setmetatable({
        app = app,
    }, {
        __call = function(_, ...)
            if not ... then
                return app
            end
            return app:make(...)
        end,
    })

    -- Add convenience methods to global
    Magento.run = function(...)
        return app:make("runner"):run(...)
    end

    Magento.cache = function()
        return app:make("cache")
    end

    Magento.env = function()
        return app:make("env")
    end
end

return M
