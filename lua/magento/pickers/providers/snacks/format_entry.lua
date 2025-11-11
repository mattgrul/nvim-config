---Snacks.nvim entry formatters
---Format items for display in Snacks picker
local M = {}

---Format command entry for display
---@param item table Picker item with value field
---@param _ any Unused context parameter
---@return table Array of {text, highlight} tuples
M.command = function(item, _)
    -- Simple format: just command name
    return { { item.value.name or "unknown", "@keyword" } }
end

---Format cache type entry for display (future use)
---@param item table Picker item with value field
---@param _ any Unused context parameter
---@return table Array of {text, highlight} tuples
M.cache_type = function(item, _)
    local status_hl = item.value.status == "enabled" and "@string" or "@comment"
    return {
        { item.value.name, "@keyword" },
        { " ", "@string" },
        { "[" .. (item.value.status or "unknown") .. "]", status_hl },
    }
end

return M
