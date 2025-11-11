---Common picker actions for Magento
---Based on laravel.nvim's actions pattern
local app = require("magento.core.app")

local M = {}

---Run magento command with interactive input
---@param command table Command object with name, description, arguments, options
function M.magento_run(command)
    vim.schedule(function()
        local runner = app:make("runner")

        -- Check if command has required arguments
        local required_args = {}
        if command.arguments then
            for arg_name, arg_data in pairs(command.arguments) do
                if arg_data.is_required then
                    table.insert(required_args, arg_name)
                end
            end
        end

        -- Build prompt
        local prompt
        if #required_args > 0 then
            prompt = string.format(
                "Arguments for %s (%s): ",
                command.name,
                table.concat(required_args, ", ")
            )
        else
            prompt = string.format("Run '%s' with arguments (leave empty for none): ", command.name)
        end

        -- Get user input and execute
        vim.ui.input({ prompt = prompt }, function(input)
            if input == nil then
                return
            end -- User cancelled

            local cmd_parts = vim.split(command.name, " ")
            if input and input ~= "" then
                vim.list_extend(cmd_parts, vim.split(input, " "))
            end

            runner:run("magento", cmd_parts)
        end)
    end)
end

---Run magento command directly without input
---@param command table Command object
function M.magento_run_direct(command)
    vim.schedule(function()
        local runner = app:make("runner")
        local cmd_parts = vim.split(command.name, " ")
        runner:run("magento", cmd_parts)
    end)
end

---Run cache:clean for specific cache type
---@param cache_type table Cache type object
function M.cache_clean(cache_type)
    vim.schedule(function()
        local runner = app:make("runner")
        runner:run("magento", { "cache:clean", cache_type.name })
    end)
end

---Run cache:flush for specific cache type
---@param cache_type table Cache type object
function M.cache_flush(cache_type)
    vim.schedule(function()
        local runner = app:make("runner")
        runner:run("magento", { "cache:flush", cache_type.name })
    end)
end

return M
