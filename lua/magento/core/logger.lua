---@class magento.core.logger
local M = {}

---@type boolean
M.enabled = false

---@type string
M.log_file = vim.fn.stdpath("state") .. "/magento-debug.log"

---Initialize logger
---@param config table Configuration with dev_mode flag
function M.init(config)
    M.enabled = config.dev_mode or false

    if M.enabled then
        -- Create log file if it doesn't exist
        local log_dir = vim.fn.fnamemodify(M.log_file, ":h")
        if vim.fn.isdirectory(log_dir) == 0 then
            vim.fn.mkdir(log_dir, "p")
        end

        -- Write startup message
        M.info("Logger initialized - dev_mode enabled")
    end
end

---Get timestamp string
---@return string
local function timestamp()
    return os.date("%Y-%m-%d %H:%M:%S")
end

---Write log entry
---@param level string Log level
---@param message string Log message
---@param data? table Optional data to include
local function write_log(level, message, data)
    if not M.enabled then
        return
    end

    local log_entry = string.format("[%s] [%s] %s", timestamp(), level, message)

    if data then
        log_entry = log_entry .. "\n  Data: " .. vim.inspect(data)
    end

    -- Append to log file
    local file = io.open(M.log_file, "a")
    if file then
        file:write(log_entry .. "\n")
        file:close()
    end
end

---Log debug message
---@param message string
---@param data? table
function M.debug(message, data)
    write_log("DEBUG", message, data)
end

---Log info message
---@param message string
---@param data? table
function M.info(message, data)
    write_log("INFO", message, data)
end

---Log warning message
---@param message string
---@param data? table
function M.warn(message, data)
    write_log("WARN", message, data)
end

---Log error message
---@param message string
---@param data? table
function M.error(message, data)
    write_log("ERROR", message, data)
end

---Clear log file
function M.clear()
    local file = io.open(M.log_file, "w")
    if file then
        file:write("")
        file:close()
    end
    M.info("Log file cleared")
end

---Open log file in Neovim
function M.open()
    if vim.fn.filereadable(M.log_file) == 1 then
        vim.cmd("edit " .. M.log_file)
    else
        vim.notify("Log file does not exist: " .. M.log_file, vim.log.levels.WARN)
    end
end

return M
