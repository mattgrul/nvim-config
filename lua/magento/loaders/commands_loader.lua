---@class magento.loaders.commands_loader
---@field env magento.core.env
local Class = require("magento.utils.class")

local CommandsLoader = Class({
    env = "env",
})

---Execute a command and capture output using async plenary.job
---@param cmd string[] Command array
---@param cwd string|nil Working directory
---@return string|nil
---@return string|nil
function CommandsLoader:_exec(cmd, cwd)
    local Job = require("plenary.job")

    local stdout_results = {}
    local stderr_results = {}
    local exit_code = nil

    local job = Job:new({
        command = cmd[1],
        args = vim.list_slice(cmd, 2),
        cwd = cwd,
        on_stdout = function(_, line)
            table.insert(stdout_results, line)
        end,
        on_stderr = function(_, line)
            table.insert(stderr_results, line)
        end,
        on_exit = function(_, code)
            exit_code = code
        end,
    })

    -- Run synchronously
    job:sync()

    if exit_code ~= 0 then
        local error_msg = table.concat(stderr_results, "\n")
        return nil, string.format("Command failed with exit code %d: %s", exit_code, error_msg)
    end

    return table.concat(stdout_results, "\n"), nil
end

---Load all available Magento commands
---@return table[] commands Array of command objects
function CommandsLoader:load()
    local environment, err = self.env.get()
    if not environment then
        vim.notify("Failed to detect environment: " .. (err or "unknown"), vim.log.levels.ERROR)
        return {}
    end

    local root = self.env.root()
    if not root then
        vim.notify("Magento root not found", vim.log.levels.ERROR)
        return {}
    end

    -- Get the magento command wrapper
    local magento_cmd, cmd_err = environment:executable("magento")
    if not magento_cmd then
        vim.notify("Magento executable not found: " .. (cmd_err or "unknown"), vim.log.levels.ERROR)
        return {}
    end

    -- Build the full command: [warden, env, exec, -T, php-fpm, bin/magento, list, --format=json]
    local cmd = vim.tbl_extend("force", {}, magento_cmd)
    table.insert(cmd, "list")
    table.insert(cmd, "--format=json")

    -- Execute in the project root (no need to change directories with plenary.job)
    local output, exec_err = self:_exec(cmd, root)

    if not output then
        vim.notify("Failed to load commands: " .. (exec_err or "unknown"), vim.log.levels.ERROR)
        return {}
    end

    -- Parse JSON
    local ok, data = pcall(vim.json.decode, output)
    if not ok then
        vim.notify("Failed to parse command list JSON: " .. tostring(data), vim.log.levels.ERROR)
        return {}
    end

    -- Extract commands array
    local commands = data.commands or {}

    -- Filter out hidden commands and format for picker
    local visible_commands = {}
    for _, cmd_data in ipairs(commands) do
        if not cmd_data.hidden then
            local definition = cmd_data.definition or {}

            table.insert(visible_commands, {
                name = cmd_data.name,
                description = cmd_data.description or "",
                text = string.format("%s %s", cmd_data.name, cmd_data.description or ""),
                help = cmd_data.help or "",
                arguments = definition.arguments or {},
                options = definition.options or {},
            })
        end
    end

    return visible_commands
end

return CommandsLoader
