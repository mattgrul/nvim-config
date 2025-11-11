---@class magento.services.cache
---Cache service with TTL support
---Based on laravel.nvim's cache implementation

---@class CacheEntry
---@field value any
---@field expires_at number|nil
---@field timer userdata|nil

-- Shared cache store at module level (like laravel.nvim)
local store = {}

local M = {}

---Create a new cache instance
---@return magento.services.cache
function M:new()
    local instance = {}
    setmetatable(instance, { __index = self })
    return instance
end

---Store a value in cache with optional TTL
---@param key string
---@param value any
---@param ttl number|nil Time to live in seconds
function M:put(key, value, ttl)
    -- Clean up existing timer if present
    if store[key] and store[key].timer then
        store[key].timer:stop()
        store[key].timer:close()
    end

    store[key] = {
        value = value,
        expires_at = ttl and (os.time() + ttl) or nil,
        timer = nil,
    }

    -- Set up auto-expiration timer if TTL provided
    if ttl then
        local timer = vim.uv.new_timer()
        store[key].timer = timer

        timer:start(ttl * 1000, 0, function()
            vim.schedule(function()
                self:forget(key)
            end)
        end)
    end
end

---Retrieve a value from cache
---@param key string
---@param default any|nil Default value if not found
---@return any
function M:get(key, default)
    if not self:has(key) then
        return default
    end

    return store[key].value
end

---Check if key exists and is not expired
---@param key string
---@return boolean
function M:has(key)
    local entry = store[key]

    if not entry then
        return false
    end

    -- Check expiration
    if entry.expires_at and os.time() > entry.expires_at then
        self:forget(key)
        return false
    end

    return true
end

---Get value from cache or compute and store it
---@param key string
---@param ttl number|nil Time to live in seconds
---@param callback function Function to compute value if not cached
---@return any
function M:remember(key, ttl, callback)
    if self:has(key) then
        return self:get(key)
    end

    local value = callback()
    self:put(key, value, ttl)
    return value
end

---Remove a single key from cache
---@param key string
function M:forget(key)
    local entry = store[key]

    if entry and entry.timer then
        entry.timer:stop()
        entry.timer:close()
    end

    store[key] = nil
end

---Remove all keys matching a prefix
---@param prefix string
function M:forgetByPrefix(prefix)
    local keys_to_forget = {}

    for key, _ in pairs(store) do
        if key:sub(1, #prefix) == prefix then
            table.insert(keys_to_forget, key)
        end
    end

    for _, key in ipairs(keys_to_forget) do
        self:forget(key)
    end
end

---Clear all cache entries
function M:flush()
    -- Clean up all timers
    for key, entry in pairs(store) do
        if entry.timer then
            entry.timer:stop()
            entry.timer:close()
        end
    end

    -- Reset store
    for k in pairs(store) do
        store[k] = nil
    end

    -- Dispatch event
    vim.api.nvim_exec_autocmds("User", {
        pattern = "MagentoCacheFlush",
    })
end

---Get all keys in cache
---@return string[]
function M:keys()
    local keys = {}
    for key, _ in pairs(store) do
        table.insert(keys, key)
    end
    return keys
end

return M
