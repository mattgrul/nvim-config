---@class magento.services.command_finder
local M = {}

---@type table Statistics for tracking search performance
M.stats = {
    total_searches = 0,
    found = 0,
    not_found = 0,
    by_strategy = {
        setName = 0,
        attribute = 0,
        constant = 0,
    },
    validation_failures = 0,
}

---Validate that a file extends Command class
---@param file_path string Path to PHP file
---@param command_name string The command name for logging
---@return boolean is_valid True if file extends Command
local function validate_extends_command(file_path, command_name)
    -- Check if file has: extends Command (short form) or extends \Symfony\...\Command (fully qualified)
    local has_extends =
        vim.fn.system(string.format("grep -E 'extends (\\\\)?Command' %s 2>/dev/null", vim.fn.shellescape(file_path)))

    if vim.v.shell_error ~= 0 or has_extends == "" then
        M.stats.validation_failures = M.stats.validation_failures + 1
        return false
    end

    -- Check if file has Symfony Console Command import OR is in Symfony\Component\Console\Command namespace
    local has_symfony_import = vim.fn.system(
        string.format(
            "grep -E 'use Symfony\\\\Component\\\\Console\\\\Command' %s 2>/dev/null",
            vim.fn.shellescape(file_path)
        )
    )
    local has_import = vim.v.shell_error == 0 and has_symfony_import ~= ""

    local in_symfony_namespace = vim.fn.system(
        string.format(
            "grep -E 'namespace Symfony\\\\Component\\\\Console\\\\Command' %s 2>/dev/null",
            vim.fn.shellescape(file_path)
        )
    )
    local in_namespace = vim.v.shell_error == 0 and in_symfony_namespace ~= ""

    -- Pass validation if file has EITHER import OR is in namespace
    if not has_import and not in_namespace then
        M.stats.validation_failures = M.stats.validation_failures + 1
        return false
    end

    return true
end

---Search for command using #[AsCommand] attribute or ->setName() method
---@param command_name string The command name to search for
---@param magento_root string The Magento root directory
---@return string|nil file_path The path to the command file, or nil if not found
local function search_for_command(command_name, magento_root)
    local logger = require("magento.core.logger")

    -- Search in vendor/ and app/code/ only
    local search_paths = {
        magento_root .. "/vendor",
        magento_root .. "/app/code",
    }

    -- Try three patterns: attribute, setName, and constant
    local patterns = {
        {
            name = "attribute",
            pattern = string.format("#\\[AsCommand\\(name:\\s*['\"]%s", command_name),
        },
        {
            name = "setName",
            pattern = string.format("->setName\\(['\"]%s['\"]\\)", command_name),
        },
        {
            name = "constant",
            pattern = string.format("(public\\s+)?const COMMAND_NAME\\s*=\\s*['\"]%s['\"]", command_name),
        },
    }

    for _, pattern_info in ipairs(patterns) do
        for _, search_path in ipairs(search_paths) do
            -- Use shellescape to properly escape pattern for shell execution
            local cmd = string.format(
                'rg --files-with-matches -- %s %s 2>/dev/null',
                vim.fn.shellescape(pattern_info.pattern),
                vim.fn.shellescape(search_path)
            )

            local result = vim.fn.system(cmd)
            if vim.v.shell_error == 0 and result and result ~= "" then
                -- Check each file found
                for line in result:gmatch("[^\n]+") do
                    local file = vim.trim(line)
                    if validate_extends_command(file, command_name) then
                        logger.info("Found via " .. pattern_info.name .. " strategy", { command = command_name, file = file })
                        M.stats.by_strategy[pattern_info.name] = M.stats.by_strategy[pattern_info.name] + 1
                        return file
                    end
                end
            end
        end
    end

    logger.debug("Command source not found", { command = command_name })
    return nil
end

---Find the PHP source file for a Magento command
---@param command_name string
---@param magento_root string
---@return string|nil file_path
function M.find_command_source(command_name, magento_root)
    M.stats.total_searches = M.stats.total_searches + 1

    local result = search_for_command(command_name, magento_root)

    if result then
        M.stats.found = M.stats.found + 1
        return result
    end

    M.stats.not_found = M.stats.not_found + 1
    return nil
end

---Read file content with line limit for performance
---@param file_path string
---@param max_lines? number Default 500
---@return string[] lines
function M.read_file_limited(file_path, max_lines)
    max_lines = max_lines or 500

    local ok, lines = pcall(vim.fn.readfile, file_path, "", max_lines)
    if not ok then
        return { "Error reading file: " .. file_path }
    end

    if #lines >= max_lines then
        table.insert(lines, "")
        table.insert(lines, string.format("... (file truncated, showing first %d lines)", max_lines))
    end

    return lines
end

return M
