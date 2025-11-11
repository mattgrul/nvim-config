---@class magento.providers.snacks_provider
local snacks_provider = {
    name = "magento.providers.snacks_provider",
}

---Register snacks picker integrations
---@param app magento.core.app
function snacks_provider:register(app)
    app:singletonIf("pickers.snacks", function()
        return {
            check = function()
                return pcall(require, "snacks")
            end,
            pickers = {
                commands = "magento.pickers.providers.snacks.commands",
                -- Add more pickers here as you create them:
                -- cache = "magento.pickers.providers.snacks.cache",
                -- modules = "magento.pickers.providers.snacks.modules",
            },
        }
    end)
end

---Boot snacks integrations
---@param app magento.core.app
function snacks_provider:boot(app)
    -- Boot logic here
end

return snacks_provider
