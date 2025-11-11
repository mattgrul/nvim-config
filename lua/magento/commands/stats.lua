---@class magento.commands.stats
local M = {}

---Format a number as a percentage
---@param value number
---@param total number
---@return string
local function percentage(value, total)
    if total == 0 then
        return "0.00%"
    end
    return string.format("%.2f%%", (value / total) * 100)
end

---Display command finder statistics
---@param app magento.core.app
function M.run(app)
    local command_finder = require("magento.services.command_finder")
    local stats = command_finder.stats

    -- Build display lines
    local lines = {}

    table.insert(lines, "")
    table.insert(lines, "╔════════════════════════════════════════════════════════════╗")
    table.insert(lines, "║          Magento Command Finder Statistics                ║")
    table.insert(lines, "╚════════════════════════════════════════════════════════════╝")
    table.insert(lines, "")

    -- Overall stats
    table.insert(lines, "Overall Performance:")
    table.insert(lines, string.rep("─", 60))
    table.insert(lines, string.format("  Total searches:      %d", stats.total_searches))
    table.insert(lines, string.format("  Found:               %d (%s)", stats.found, percentage(stats.found, stats.total_searches)))
    table.insert(lines, string.format("  Not found:           %d (%s)", stats.not_found, percentage(stats.not_found, stats.total_searches)))
    table.insert(lines, string.format("  Validation failures: %d", stats.validation_failures))
    table.insert(lines, "")

    -- Strategy breakdown
    table.insert(lines, "Success by Strategy:")
    table.insert(lines, string.rep("─", 60))

    local strategy_order = {
        { key = "attribute", label = "#[AsCommand] attribute" },
        { key = "setName", label = "->setName() search" },
        { key = "constant", label = "const COMMAND_NAME" },
    }

    for _, strategy in ipairs(strategy_order) do
        local count = stats.by_strategy[strategy.key]
        local pct = percentage(count, stats.found)
        table.insert(lines, string.format("  %-25s %d (%s)", strategy.label .. ":", count, pct))
    end

    table.insert(lines, "")

    -- Success rate
    local success_rate = percentage(stats.found, stats.total_searches)
    table.insert(lines, string.format("Overall Success Rate: %s", success_rate))
    table.insert(lines, "")

    -- Footer
    if stats.total_searches == 0 then
        table.insert(lines, "")
        table.insert(lines, "No searches performed yet. Open the command picker to")
        table.insert(lines, "generate statistics. Press <leader>mm to open picker.")
        table.insert(lines, "")
    end

    -- Display in a scratch buffer
    local buf = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
    vim.api.nvim_buf_set_option(buf, "modifiable", false)
    vim.api.nvim_buf_set_option(buf, "buftype", "nofile")
    vim.api.nvim_buf_set_option(buf, "bufhidden", "wipe")
    vim.api.nvim_buf_set_name(buf, "magento://stats")

    -- Open in a split
    local height = math.min(#lines + 2, math.floor(vim.o.lines * 0.5))
    vim.cmd("botright " .. height .. "split")
    local win = vim.api.nvim_get_current_win()
    vim.api.nvim_win_set_buf(win, buf)

    -- Add keymaps
    vim.keymap.set("n", "q", "<cmd>close<cr>", { buffer = buf, desc = "Close stats" })
    vim.keymap.set("n", "<Esc>", "<cmd>close<cr>", { buffer = buf, desc = "Close stats" })
    vim.keymap.set("n", "r", function()
        vim.cmd("close")
        M.run(app)
    end, { buffer = buf, desc = "Refresh stats" })

    -- Show help hint
    vim.api.nvim_buf_set_lines(buf, -1, -1, false, { "", "Press 'q' to close, 'r' to refresh" })
end

return M
