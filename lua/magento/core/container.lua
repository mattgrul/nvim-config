---@class magento.core.container
---@field registry table<string, any>
---@field tags table<string, string[]>
local Container = {}

---@return magento.core.container
function Container:new()
    local instance = {
        registry = {},
        tags = {},
    }
    setmetatable(instance, { __index = Container })
    return instance
end

---Store an item in the container
---@param name string
---@param item any
---@param tag? string Optional tag for grouping related items
function Container:set(name, item, tag)
    self.registry[name] = item

    if tag then
        if not self.tags[tag] then
            self.tags[tag] = {}
        end
        table.insert(self.tags[tag], name)
    end
end

---Retrieve an item from the container
---@param name string
---@return any|nil
function Container:get(name)
    return self.registry[name]
end

---Check if an item exists in the container
---@param name string
---@return boolean
function Container:has(name)
    return self.registry[name] ~= nil
end

---Get all items with a specific tag
---@param tag string
---@return table
function Container:byTag(tag)
    local items = {}
    local names = self.tags[tag] or {}

    for _, name in ipairs(names) do
        local item = self:get(name)
        if item then
            table.insert(items, item)
        end
    end

    return items
end

return Container
