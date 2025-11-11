---@class magento.providers.magento_provider
local magento_provider = {
    name = "magento.providers.magento_provider",
}

---Register services in the container
---@param app magento.core.app
function magento_provider:register(app)
    -- Core services as singletons (stateful, shared instances)
    app:singletonIf("magento.services.cache", function()
        local Cache = require("magento.services.cache")
        return Cache:new()
    end)

    app:singletonIf("magento.services.command_generator", function()
        local CommandGenerator = require("magento.services.command_generator")
        return CommandGenerator:new() -- Class helper resolves 'env' dependency
    end)

    app:singletonIf("magento.services.runner", function()
        local Runner = require("magento.services.runner")
        return Runner:new() -- Class helper resolves dependencies
    end)

    -- Loaders as bindings (stateless, created fresh each time)
    app:bindIf("magento.loaders.commands_loader", function()
        local CommandsLoader = require("magento.loaders.commands_loader")
        return CommandsLoader:new() -- Class helper resolves 'env' dependency
    end)

    app:bindIf("magento.loaders.commands_cache_loader", function()
        local CommandsCacheLoader = require("magento.loaders.commands_cache_loader")
        return CommandsCacheLoader:new() -- Class helper resolves dependencies
    end)
end

---Boot services and set up runtime behavior
---@param app magento.core.app
function magento_provider:boot(app)
    local cache = app:make("cache")

    -- Set up file watchers for cache invalidation (laravel.nvim pattern)
    vim.api.nvim_create_autocmd("BufWritePost", {
        pattern = { "*/etc/di.xml", "*/app/code/*/registration.php", "etc/config.php" },
        callback = function()
            cache:forget("magento-commands")
            vim.notify("Magento commands cache invalidated", vim.log.levels.DEBUG)
        end,
        group = vim.api.nvim_create_augroup("MagentoCache", { clear = true }),
    })

    -- Set up user commands
    vim.api.nvim_create_user_command("Magento", function(cmd)
        local args = cmd.fargs
        local subcommand = args[1] or "menu"

        if subcommand == "info" then
            require("magento.commands.info")()
        elseif subcommand == "commands" or subcommand == "menu" then
            -- Open the commands picker (new architecture)
            local CommandsPicker = require("magento.pickers.commands")
            local picker_loader = CommandsPicker:new()

            -- Get snacks provider implementation
            local snacks_provider = app:make("pickers.snacks")
            if snacks_provider.check() then
                local picker_impl = require(snacks_provider.pickers.commands)
                picker_loader:run(picker_impl, {})
            else
                vim.notify("Snacks picker not available", vim.log.levels.ERROR)
            end
        elseif subcommand == "stats" then
            -- Show command finder statistics
            local stats = require("magento.commands.stats")
            stats.run(app)
        elseif subcommand == "reload-commands" then
            -- Clear command cache and reload
            cache:forget("magento-commands")
            vim.notify("Command cache cleared. Commands will reload on next open.", vim.log.levels.INFO)
        else
            vim.notify(
                "Unknown subcommand. Use :Magento commands, :Magento stats, :Magento reload-commands, or :Magento info",
                vim.log.levels.WARN
            )
        end
    end, {
        nargs = "*",
        desc = "Magento.nvim commands",
        complete = function()
            return { "info", "menu", "commands", "stats", "reload-commands" }
        end,
    })
end

return magento_provider
