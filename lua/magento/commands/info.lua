---Display information about the current Magento project
return function()
    local env_mod = require("magento.core.env")

    local root = env_mod.root()
    if not root then
        vim.notify("Not in a Magento project", vim.log.levels.ERROR)
        return
    end

    local environment, err = env_mod.get()
    if not environment then
        vim.notify("Error detecting environment: " .. (err or "unknown"), vim.log.levels.ERROR)
        return
    end

    -- Build info message
    local lines = {
        "=== Magento Project Info ===",
        "",
        "Project Root: " .. root,
        "Environment: " .. environment.name,
        "",
        "Command Mappings:",
    }

    for cmd_name, cmd_array in pairs(environment.map) do
        table.insert(lines, string.format("  %s: %s", cmd_name, table.concat(cmd_array, " ")))
    end

    table.insert(lines, "")
    table.insert(lines, "Use :checkhealth magento for detailed diagnostics")

    vim.notify(table.concat(lines, "\n"), vim.log.levels.INFO)
end
