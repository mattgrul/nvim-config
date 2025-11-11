---Snacks.nvim preview adapter
---Converts common preview format to Snacks API
local preview = require("magento.pickers.common.preview")

local M = {}

---Generic preview adapter
---@param ctx table Snacks preview context
---@param prev Preview Common preview object
local function _preview(ctx, prev)
    ctx.preview:reset()
    ctx.preview:set_lines(prev.lines)

    vim.bo[ctx.preview.win.buf].modifiable = true
    local hl = vim.api.nvim_create_namespace("magento")
    for _, value in pairs(prev.highlights) do
        vim.api.nvim_buf_add_highlight(ctx.preview.win.buf, hl, value[1], value[2], value[3], value[4])
    end

    vim.bo[ctx.preview.win.buf].modifiable = false
    ctx.preview:wo({ wrap = true, linebreak = true })
end

---Command preview adapter
---@param ctx table Snacks preview context
M.command = function(ctx)
    _preview(ctx, preview.command(ctx.item.value))
end

---Cache type preview adapter (future use)
---@param ctx table Snacks preview context
M.cache_type = function(ctx)
    _preview(ctx, preview.cache_type(ctx.item.value))
end

return M
