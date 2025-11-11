---@class Magento
---@field app magento.core.app|nil The application instance
local M = {
    app = nil,
}

---Setup the Magento plugin
---@param opts? table User configuration options
function M.setup(opts)
    opts = opts or {}

    -- Load default configuration (laravel.nvim pattern)
    local defaults = require("magento.config.default")

    -- Merge user opts with defaults
    local config = vim.tbl_deep_extend("force", defaults, opts)

    -- Initialize logger
    local logger = require("magento.core.logger")
    logger.init(config)

    -- Initialize the core app
    local app = require("magento.core.app")
    M.app = app:start(config)

    -- Bootstrap global helpers (Laravel.nvim pattern)
    local bootstrap = require("magento.core.bootstrap")
    bootstrap:bootstrap(M.app, config)

    return M.app
end

---Reload the entire plugin (useful for development)
function M.reload()
    -- Clear all magento modules from cache
    for k in pairs(package.loaded) do
        if k:match("^magento") then
            package.loaded[k] = nil
        end
    end

    -- Reload with empty config (will use defaults)
    return require("magento").setup({})
end

return M
