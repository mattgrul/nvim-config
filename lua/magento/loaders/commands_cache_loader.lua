---@class magento.loaders.commands_cache_loader
---Wraps commands_loader with caching layer
---Based on laravel.nvim's cache loader pattern
local Class = require("magento.utils.class")

local CommandsCacheLoader = Class({
    cache = "cache",
    commands_loader = "magento.loaders.commands_loader",
}, {
    cache_key = "magento-commands",
    cache_ttl = 60, -- 60 seconds TTL like laravel.nvim
})

---Load commands with caching
---@return table[] commands Array of command objects
function CommandsCacheLoader:load()
    -- Use remember pattern: return cached value or compute and cache
    return self.cache:remember(self.cache_key, self.cache_ttl, function()
        return self.commands_loader:load()
    end)
end

---Clear the commands cache
function CommandsCacheLoader:clear_cache()
    self.cache:forget(self.cache_key)
end

return CommandsCacheLoader
