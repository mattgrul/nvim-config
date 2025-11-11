---@class magento.dto.environment
---@field name string Environment name (e.g., "docker", "native")
---@field map table<string, string[]> Command name to executable array mapping
---@field _cache table Cache for resolved executables
local Environment = {}

---Create a new Environment instance
---@param name string
---@param map table<string, string[]>
---@return magento.dto.environment
function Environment:new(name, map)
    local instance = {
        name = name,
        map = map or {},
        _cache = {}, -- Cache resolved executables
    }
    setmetatable(instance, { __index = Environment })
    return instance
end

---Get the executable command array for a given command name
---@param name string Command name (e.g., "magento")
---@return string[]|nil, string|nil
function Environment:executable(name)
    -- Check cache first
    if self._cache[name] then
        return self._cache[name], nil
    end

    -- Get command from map, fallback to name if not mapped
    local cmd = self.map[name] or { name }

    -- Validate that the base executable exists
    local base_cmd = cmd[1]
    if vim.fn.executable(base_cmd) == 0 then
        return nil, string.format("Executable '%s' not found", base_cmd)
    end

    -- Cache the result
    self._cache[name] = cmd
    return cmd, nil
end

---Get a human-readable description of this environment
---@return string
function Environment:describe()
    return string.format("%s environment", self.name)
end

return Environment
