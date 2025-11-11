---Common preview generators for Magento pickers
---Based on laravel.nvim's preview pattern

---@class Preview
---@field lines table Array of strings
---@field highlights table Array of {hl_group, line, col_start, col_end}

local M = {}

local function tablelength(T)
    local count = 0
    for _ in pairs(T) do
        count = count + 1
    end
    return count
end

local function required(is_required)
    return is_required and "<required>" or ""
end

---Generates the preview and highlight for a command
---@param command table Magento command
---@return Preview
M.command = function(command)
    local lines = {}
    local highlights = {}

    -- Description
    table.insert(lines, "Description:")
    table.insert(highlights, { "WarningMsg", #lines - 1, 0, -1 })

    if command.description and command.description ~= "" then
        table.insert(lines, "\t" .. command.description)
    else
        table.insert(lines, "\t(No description)")
    end

    table.insert(lines, "")

    -- Usage
    table.insert(lines, "Usage:")
    table.insert(highlights, { "WarningMsg", #lines - 1, 0, -1 })
    table.insert(lines, "\t" .. command.name)

    -- Arguments
    if command.arguments and tablelength(command.arguments) > 0 then
        table.insert(lines, "")
        table.insert(lines, "Arguments:")
        table.insert(highlights, { "WarningMsg", #lines - 1, 0, -1 })

        local max_argument = 0
        local max_required = 0
        local arguments = {}

        for arg_name, arg_data in pairs(command.arguments) do
            table.insert(arguments, {
                arg_name,
                required(arg_data.is_required),
                arg_data.description or "",
            })

            if #arg_name > max_argument then
                max_argument = #arg_name
            end
            if arg_data.is_required then
                max_required = 10
            end
        end

        for _, argument in pairs(arguments) do
            local argument_line = string.format(
                "\t%-" .. max_argument .. "s %-" .. max_required .. "s \t\t%s",
                argument[1],
                argument[2],
                argument[3]
            )
            table.insert(lines, argument_line)

            table.insert(highlights, {
                "String",
                #lines - 1,
                0,
                max_argument + 1,
            })

            table.insert(highlights, {
                "ErrorMsg",
                #lines - 1,
                max_argument + 1,
                max_argument + 1 + max_required + 1,
            })
        end
    end

    -- Options (filter common ones)
    if command.options and tablelength(command.options) > 0 then
        local skip_options = {
            help = true,
            quiet = true,
            verbose = true,
            version = true,
            ansi = true,
            ["no-ansi"] = true,
            ["no-interaction"] = true,
        }

        local filtered_options = {}
        for opt_name, opt_data in pairs(command.options) do
            if not skip_options[opt_name] then
                table.insert(filtered_options, {
                    opt_name,
                    opt_data.shortcut or "",
                    opt_data.description or "",
                })
            end
        end

        if #filtered_options > 0 then
            table.insert(lines, "")
            table.insert(lines, "Options:")
            table.insert(highlights, { "WarningMsg", #lines - 1, 0, -1 })

            local max_name = 0
            for _, opt in ipairs(filtered_options) do
                if #opt[1] > max_name then
                    max_name = #opt[1]
                end
            end

            for _, opt in ipairs(filtered_options) do
                local shortcut = opt[2] ~= "" and " (-" .. opt[2] .. ")" or ""
                local option_line = string.format("\t--%-" .. max_name .. "s%s\t%s", opt[1], shortcut, opt[3])
                table.insert(lines, option_line)

                table.insert(highlights, {
                    "String",
                    #lines - 1,
                    0,
                    max_name + 4,
                })
            end
        end
    end

    -- Help text
    if command.help and command.help ~= "" then
        table.insert(lines, "")
        table.insert(lines, "Help:")
        table.insert(highlights, { "WarningMsg", #lines - 1, 0, -1 })

        local help_text = command.help:gsub("<[^>]+>", "")
        for line in help_text:gmatch("[^\n]+") do
            table.insert(lines, "\t" .. line)
        end
    end

    return { lines = lines, highlights = highlights }
end

---Preview for cache type (future use)
---@param cache_type table Cache type object
---@return Preview
M.cache_type = function(cache_type)
    local lines = {}
    local highlights = {}

    table.insert(lines, "Cache Type: " .. cache_type.name)
    table.insert(highlights, { "WarningMsg", #lines - 1, 0, 12 })
    table.insert(highlights, { "String", #lines - 1, 12, -1 })

    table.insert(lines, "")
    table.insert(lines, "Status: " .. (cache_type.status or "unknown"))
    table.insert(highlights, { "WarningMsg", #lines - 1, 0, 8 })

    return { lines = lines, highlights = highlights }
end

return M
