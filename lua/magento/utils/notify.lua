---Notification utility wrapper
---Based on laravel.nvim's notify pattern
local M = {}

---Show info notification
---@param message string
function M.info(message)
    vim.notify(message, vim.log.levels.INFO, { title = "Magento" })
end

---Show warning notification
---@param message string
function M.warn(message)
    vim.notify(message, vim.log.levels.WARN, { title = "Magento" })
end

---Show error notification
---@param message string
function M.error(message)
    vim.notify(message, vim.log.levels.ERROR, { title = "Magento" })
end

---Show debug notification
---@param message string
function M.debug(message)
    vim.notify(message, vim.log.levels.DEBUG, { title = "Magento" })
end

return M
