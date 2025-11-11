---@class magento.services.runner
---@field command_generator magento.services.command_generator
---@field env magento.core.env
local Class = require("magento.utils.class")

local Runner = Class({
    command_generator = "magento.services.command_generator",
    env = "env",
})

---Run a command in a terminal buffer
---@param program string Program name (e.g., "magento")
---@param args string[] Command arguments
---@param opts? table Options for execution
function Runner:run(program, args, opts)
    opts = opts or {}

    -- Generate the full command
    local cmd, err = self.command_generator:generate(program, args)
    if not cmd then
        vim.notify("Failed to generate command: " .. (err or "unknown"), vim.log.levels.ERROR)
        return
    end

    -- Get the project root to run the command in the right directory
    local root = self.env.root()
    if not root then
        vim.notify("Magento root not found", vim.log.levels.ERROR)
        return
    end

    -- Create a new terminal buffer
    local buf = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_buf_set_option(buf, "bufhidden", "hide")
    vim.api.nvim_buf_set_option(buf, "buftype", "terminal")

    -- Open in a split
    local win_height = math.floor(vim.o.lines * 0.4)
    vim.cmd("botright " .. win_height .. "split")
    local win = vim.api.nvim_get_current_win()
    vim.api.nvim_win_set_buf(win, buf)

    -- Set buffer name
    local cmd_name = table.concat(args, " ")
    vim.api.nvim_buf_set_name(buf, "magento://" .. cmd_name)

    -- Add keymaps to close terminal
    vim.keymap.set("n", "q", "<cmd>close<cr>", { buffer = buf, desc = "Close terminal" })
    vim.keymap.set("n", "<Esc>", "<cmd>close<cr>", { buffer = buf, desc = "Close terminal" })

    -- Start the job in the terminal
    local job_id = vim.fn.termopen(table.concat(cmd, " "), {
        cwd = root,
        on_exit = function(_, exit_code, _)
            -- Set buffer to modifiable so we can add completion message
            vim.api.nvim_buf_set_option(buf, "modifiable", true)

            if exit_code == 0 then
                vim.notify(string.format("✓ Command completed: %s", cmd_name), vim.log.levels.INFO)
            else
                vim.notify(
                    string.format("✗ Command failed (exit %d): %s", exit_code, cmd_name),
                    vim.log.levels.ERROR
                )
            end

            -- Add completion message at bottom
            vim.api.nvim_buf_set_lines(buf, -1, -1, false, { "", "Press q or <Esc> to close" })
            vim.api.nvim_buf_set_option(buf, "modifiable", false)
        end,
    })

    if job_id <= 0 then
        vim.notify("Failed to start command", vim.log.levels.ERROR)
        return
    end

    -- Don't start in insert mode - let user read output
    -- They can press 'i' if they need to interact
end

---Run a command and return output (synchronous)
---@param program string Program name
---@param args string[] Command arguments
---@return string|nil, string|nil output, error
function Runner:run_sync(program, args)
    local cmd, err = self.command_generator:generate(program, args)
    if not cmd then
        return nil, err or "Failed to generate command"
    end

    local root = self.env.root()
    if not root then
        return nil, "Magento root not found"
    end

    -- Execute and capture output
    local cwd = vim.fn.getcwd()
    vim.fn.chdir(root)

    local output = vim.fn.system(cmd)
    local exit_code = vim.v.shell_error

    vim.fn.chdir(cwd)

    if exit_code ~= 0 then
        return nil, string.format("Command failed with exit code %d", exit_code)
    end

    return output, nil
end

return Runner
