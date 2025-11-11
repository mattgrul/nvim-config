local M = {}

---Run health checks for magento.nvim
function M.check()
    vim.health.start("Magento.nvim")

    -- Check dependencies
    vim.health.info("Checking dependencies...")

    local has_plenary = pcall(require, "plenary")
    if has_plenary then
        vim.health.ok("plenary.nvim is installed")
    else
        vim.health.error("plenary.nvim is not installed", {
            "Install via your plugin manager: 'nvim-lua/plenary.nvim'",
        })
    end

    local has_nio = pcall(require, "nio")
    if has_nio then
        vim.health.ok("nvim-nio is installed")
    else
        vim.health.error("nvim-nio is not installed", {
            "Install via your plugin manager: 'nvim-neotest/nvim-nio'",
        })
    end

    -- Check if in Magento project
    vim.health.info("Checking Magento project...")

    local env_mod = require("magento.core.env")
    local root = env_mod.find_root()

    if root then
        vim.health.ok(string.format("Magento project detected at: %s", root))

        -- Check environment
        local environment, err = env_mod.detect(root)
        if environment then
            vim.health.ok(string.format("Environment: %s", environment.name))

            -- Check if environment executables are available
            for cmd_name, cmd_array in pairs(environment.map) do
                local base_cmd = cmd_array[1]
                if vim.fn.executable(base_cmd) == 1 then
                    vim.health.ok(string.format("%s command available: %s", cmd_name, table.concat(cmd_array, " ")))
                else
                    vim.health.warn(
                        string.format("%s command not found: %s", cmd_name, base_cmd),
                        {
                            string.format("Ensure '%s' is installed and in your PATH", base_cmd),
                        }
                    )
                end
            end

            -- Check bin/magento is executable
            local magento_bin = root .. "/bin/magento"
            if vim.fn.filereadable(magento_bin) == 1 then
                vim.health.ok("bin/magento exists and is readable")
            else
                vim.health.error("bin/magento not found or not readable")
            end
        else
            vim.health.error(string.format("Failed to detect environment: %s", err or "unknown error"))
        end
    else
        vim.health.warn("Not in a Magento project", {
            "Navigate to a Magento 2 project directory",
            "Magento projects should have a 'bin/magento' file",
        })
    end

    -- Check optional integrations
    vim.health.info("Checking optional integrations...")

    local has_snacks = pcall(require, "snacks")
    if has_snacks then
        vim.health.ok("snacks.nvim available for pickers")
    else
        vim.health.info("snacks.nvim not found (optional)")
    end

    local has_cmp = pcall(require, "cmp")
    if has_cmp then
        vim.health.ok("nvim-cmp available for completions")
    else
        vim.health.info("nvim-cmp not found (optional)")
    end
end

return M
