---Default configuration for Magento plugin
---Based on laravel.nvim's configuration pattern
---@class magento.config.default
return {
    ---Debug level
    debug_level = vim.log.levels.DEBUG,

    ---Cache settings
    cache = {
        ---TTL for commands cache in seconds
        commands_ttl = 60,
        ---TTL for other resources in seconds
        resources_ttl = 60,
    },

    ---Picker settings
    picker = {
        ---Preferred picker provider: "snacks", "telescope", "fzf-lua"
        provider = "snacks",
    },

    ---Command-specific options
    commands_options = {
        ---Example: require confirmation for destructive commands
        ["setup:upgrade"] = {
            confirm = true,
        },
        ["cache:flush"] = {
            confirm = false,
        },
    },

    ---File watch patterns for cache invalidation
    watch_patterns = {
        ---Invalidate commands cache when these files change
        commands = {
            "*/etc/di.xml",
            "*/app/code/*/registration.php",
            "etc/config.php",
        },
    },
}
