---@class magento.providers.facades_provider
---Provides service aliases for convenient access
---Based on Laravel.nvim's facades pattern
local facades_provider = {
    name = "magento.providers.facades_provider",
}

---Register service aliases
---@param app magento.core.app
function facades_provider:register(app)
    -- Short aliases for core services
    app:alias("cache", "magento.services.cache")
    app:alias("command_generator", "magento.services.command_generator")
    app:alias("runner", "magento.services.runner")

    -- Alias for environment
    app:alias("env", "magento.core.env")

    -- Loader aliases
    app:alias("commands_loader", "magento.loaders.commands_loader")
    app:alias("commands_cache_loader", "magento.loaders.commands_cache_loader")
end

---Boot (no boot actions needed for facades)
---@param app magento.core.app
function facades_provider:boot(app)
    -- Nothing to boot for facades
end

return facades_provider
