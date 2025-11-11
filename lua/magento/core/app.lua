---@class magento.core.app
---@field container magento.core.container
---@field _active boolean Whether the app is active
local app = setmetatable({
    container = require("magento.core.container"):new(),
    _active = false,
}, {
    __call = function(cls, abstract, args)
        return cls:make(abstract, args)
    end,
})

---Start the application and bootstrap providers
---@param opts? table User configuration options
---@return magento.core.app
function app:start(opts)
    opts = opts or {}

    -- Check if in a Magento project
    local env = require("magento.core.env")
    if not env.is_magento_project() then
        vim.notify("Not in a Magento project", vim.log.levels.WARN)
        return self
    end

    -- Register core services
    self:singleton("env", function()
        return require("magento.core.env")
    end)

    self:singleton("config", function()
        return opts
    end)

    -- Load and register providers
    self:_bootstrap_providers()

    -- Mark as active
    self._active = true

    return self
end

---Bootstrap all service providers
function app:_bootstrap_providers()
    -- Core provider - register core services
    local magento_provider = require("magento.providers.magento_provider")
    if magento_provider.register then
        magento_provider:register(self)
    end

    -- Facades provider - register service aliases
    local facades_provider = require("magento.providers.facades_provider")
    if facades_provider.register then
        facades_provider:register(self)
    end

    -- Snacks provider (for pickers)
    local ok, snacks_provider = pcall(require, "magento.providers.snacks_provider")
    if ok and snacks_provider.register then
        snacks_provider:register(self)
    end

    -- Now boot all providers
    if magento_provider.boot then
        magento_provider:boot(self)
    end
    if facades_provider.boot then
        facades_provider:boot(self)
    end
    if ok and snacks_provider.boot then
        snacks_provider:boot(self)
    end
end

---Check if the app is active
---@return boolean
function app:isActive()
    return self._active
end

---Execute callback only if app is active
---@param callback function
function app:whenActive(callback)
    if self:isActive() then
        callback(self)
    end
end

---Bind a factory to the container
---@param abstract string Service identifier
---@param factory function|table Factory function or value
---@param tag? string Optional tag for grouping
---@return magento.core.app
function app:bind(abstract, factory, tag)
    self.container:set(abstract, factory, tag)
    return self
end

---Bind a factory only if not already registered
---@param abstract string
---@param factory function|table
---@param tag? string
---@return magento.core.app
function app:bindIf(abstract, factory, tag)
    if not self.container:has(abstract) then
        self:bind(abstract, factory, tag)
    end
    return self
end

---Bind a singleton (cached instance) to the container
---@param abstract string Service identifier
---@param factory function|table Factory function or value
---@param tag? string Optional tag
---@return magento.core.app
function app:singleton(abstract, factory, tag)
    local instance = nil

    self.container:set(abstract, function()
        if instance == nil then
            instance = type(factory) == "function" and factory() or factory
        end
        return instance
    end, tag)

    return self
end

---Bind a singleton only if not already registered
---@param abstract string
---@param factory function|table
---@param tag? string
---@return magento.core.app
function app:singletonIf(abstract, factory, tag)
    if not self.container:has(abstract) then
        self:singleton(abstract, factory, tag)
    end
    return self
end

---Create an alias (shortcut) for a service
---@param alias string Short name
---@param abstract string Full service name
---@return magento.core.app
function app:alias(alias, abstract)
    self.container:set(alias, function()
        return self:make(abstract)
    end)
    return self
end

---Resolve a service from the container
---@param abstract string Service identifier
---@param args? table Optional arguments to pass to factory
---@return any
function app:make(abstract, args)
    local item = self.container:get(abstract)

    if item == nil then
        error(string.format("Service '%s' not found in container", abstract))
    end

    if type(item) == "function" then
        return item(args)
    end

    return item
end

---Get all services with a specific tag
---@param tag string
---@return table
function app:makeByTag(tag)
    local items = self.container:byTag(tag)
    local resolved = {}

    for _, item in ipairs(items) do
        if type(item) == "function" then
            table.insert(resolved, item())
        else
            table.insert(resolved, item)
        end
    end

    return resolved
end

return app
