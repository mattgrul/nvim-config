return {
    -- Debug Adapter Protocol (DAP) core plugin
    {
        "mfussenegger/nvim-dap",
        dependencies = {
            -- UI for debugging with panels for variables, watches, call stack
            {
                "rcarriga/nvim-dap-ui",
                dependencies = {
                    "nvim-neotest/nvim-nio", -- Required dependency for dap-ui
                },
                opts = {
                    -- Use default configuration with all panels
                    layouts = {
                        {
                            elements = {
                                { id = "scopes",      size = 0.25 },
                                { id = "breakpoints", size = 0.25 },
                                { id = "stacks",      size = 0.25 },
                                { id = "watches",     size = 0.25 },
                            },
                            size = 40,
                            position = "left",
                        },
                        {
                            elements = {
                                { id = "repl",    size = 0.5 },
                                { id = "console", size = 0.5 },
                            },
                            size = 10,
                            position = "bottom",
                        },
                    },
                },
                config = function(_, opts)
                    local dap, dapui = require("dap"), require("dapui")

                    dapui.setup(opts)

                    -- Auto-enable virtual text when debugging starts
                    dap.listeners.after.event_initialized["dapui_config"] = function()
                        -- Don't auto-open UI - user will toggle with <leader>du
                        -- But DO enable virtual text
                        local ok, virtual_text = pcall(require, "nvim-dap-virtual-text")
                        if ok then
                            virtual_text.refresh()
                        end
                    end
                    dap.listeners.before.event_terminated["dapui_config"] = function()
                        -- dapui.close()
                    end
                    dap.listeners.before.event_exited["dapui_config"] = function()
                        -- dapui.close()
                    end
                end,
            },

            -- Virtual text showing variable values inline
            {
                "theHamsta/nvim-dap-virtual-text",
                opts = {
                    enabled = true,
                    enabled_commands = true,
                    highlight_changed_variables = true,
                    highlight_new_as_changed = true,
                    show_stop_reason = true,
                    commented = false,
                    only_first_definition = true,
                    all_references = false,
                    ---@diagnostic disable-next-line: unused-local
                    display_callback = function(variable, _buf, _stackframe, _node)
                        return " " .. variable.name .. " = " .. variable.value
                    end,
                },
            },

            -- Mason integration for installing debug adapters
            {
                "jay-babu/mason-nvim-dap.nvim",
                dependencies = { "mason.nvim" },
                cmd = { "DapInstall", "DapUninstall" },
                opts = {
                    -- Automatically install these debug adapters
                    ensure_installed = {
                        "php", -- php-debug-adapter for xdebug
                    },
                    -- Auto-setup handlers
                    automatic_installation = true,
                    handlers = {
                        function(config)
                            -- Default handler - applies to all adapters
                            require("mason-nvim-dap").default_setup(config)
                        end,
                    },
                },
            },
        },

        keys = {
            -- Breakpoint management
            {
                "<leader>db",
                function()
                    require("dap").toggle_breakpoint()
                end,
                desc = "Toggle Breakpoint",
            },
            {
                "<leader>dB",
                function()
                    require("dap").set_breakpoint(vim.fn.input("Breakpoint condition: "))
                end,
                desc = "Conditional Breakpoint",
            },

            -- Debug session controls
            {
                "<leader>dc",
                function()
                    require("dap").continue()
                end,
                desc = "Continue/Start Debug",
            },
            {
                "<leader>di",
                function()
                    require("dap").step_into()
                end,
                desc = "Step Into",
            },
            {
                "<F9>",
                function()
                    require("dap").step_into()
                end,
                desc = "Step Into",
            },
            {
                "<leader>do",
                function()
                    require("dap").step_over()
                end,
                desc = "Step Over",
            },
            {
                "<F8>",
                function()
                    require("dap").step_over()
                end,
                desc = "Step Over",
            },
            {
                "<leader>dO",
                function()
                    require("dap").step_out()
                end,
                desc = "Step Out",
            },
            {
                "<F10>",
                function()
                    require("dap").step_out()
                end,
                desc = "Step Out",
            },
            {
                "<leader>dt",
                function()
                    require("dap").terminate()
                end,
                desc = "Terminate Debug",
            },
            {
                "<leader>dr",
                function()
                    require("dap").restart()
                end,
                desc = "Restart Debug",
            },

            -- UI toggles
            {
                "<leader>du",
                function()
                    require("dapui").toggle()
                end,
                desc = "Toggle Debug UI",
            },
            {
                "<leader>dv",
                function()
                    local ok, virtual_text = pcall(require, "nvim-dap-virtual-text")
                    if ok then
                        virtual_text.toggle()
                        print("Virtual text toggled")
                    else
                        print("nvim-dap-virtual-text not loaded")
                    end
                end,
                desc = "Toggle Virtual Text",
            },
            {
                "<leader>de",
                function()
                    require("dapui").eval()
                end,
                mode = { "n", "v" },
                desc = "Evaluate Expression",
            },
            {
                "<leader>dh",
                function()
                    require("dap.ui.widgets").hover()
                end,
                desc = "Debug Hover",
            },

            -- REPL
            {
                "<leader>dR",
                function()
                    require("dap").repl.toggle()
                end,
                desc = "Toggle REPL",
            },
        },

        config = function()
            local dap = require("dap")

            -- PHP/Xdebug Configuration
            dap.adapters.php = {
                type = "executable",
                command = "node",
                args = { vim.fn.stdpath("data") .. "/mason/packages/php-debug-adapter/extension/out/phpDebug.js" },
            }

            -- Helper function to detect project root
            local function find_project_root()
                local root_patterns = { "composer.json", "artisan", "bin/magento", ".git", ".env" }
                for _, pattern in ipairs(root_patterns) do
                    local root = vim.fn.findfile(pattern, ".;")
                    if root ~= "" then
                        return vim.fn.fnamemodify(root, ":p:h")
                    end
                end
                return vim.fn.getcwd()
            end

            -- Helper function to detect if we're in a Warden project
            local function is_warden_project()
                local warden_env = vim.fn.findfile(".env", ".;")
                if warden_env ~= "" then
                    local env_path = vim.fn.fnamemodify(warden_env, ":p")
                    local env_content = vim.fn.readfile(env_path)
                    for _, line in ipairs(env_content) do
                        if line:match("^WARDEN_ENV_NAME=") then
                            return true
                        end
                    end
                end
                return false
            end

            -- Helper function to get Warden web root
            local function get_warden_web_root()
                local project_root = find_project_root()
                local warden_env = vim.fn.findfile(".env", ".;")

                if warden_env ~= "" then
                    local env_path = vim.fn.fnamemodify(warden_env, ":p")
                    local env_content = vim.fn.readfile(env_path)

                    -- Check for WARDEN_WEB_ROOT setting
                    for _, line in ipairs(env_content) do
                        local web_root = line:match("^WARDEN_WEB_ROOT=(.+)")
                        if web_root then
                            -- Remove quotes if present
                            web_root = web_root:gsub("^[\"']", ""):gsub("[\"']$", "")
                            return project_root .. "/" .. web_root
                        end
                    end
                end

                -- Default: project root is the web root
                return project_root
            end

            dap.configurations.php = {
                {
                    type = "php",
                    request = "launch",
                    name = "Listen for Xdebug (Warden Docker)",
                    port = 9003, -- Xdebug 3.x default port
                    log = false,
                    pathMappings = function()
                        local local_root = get_warden_web_root()
                        return {
                            ["/var/www/html"] = local_root,
                        }
                    end,
                },
                {
                    type = "php",
                    request = "launch",
                    name = "Listen for Xdebug (Local PHP)",
                    port = 9003,
                    log = false,
                    -- No path mappings for local PHP - paths are already correct
                },
                {
                    type = "php",
                    request = "launch",
                    name = "Listen for Xdebug (Custom Docker Path)",
                    port = 9003,
                    log = false,
                    pathMappings = function()
                        local default_local = get_warden_web_root()
                        local remote_path = vim.fn.input("Container path: ", "/var/www/html")
                        local local_path = vim.fn.input("Local path: ", default_local)
                        return { [remote_path] = local_path }
                    end,
                },
            }

            -- Breakpoint icons
            vim.fn.sign_define("DapBreakpoint", { text = "●", texthl = "DiagnosticError", linehl = "", numhl = "" })
            vim.fn.sign_define(
                "DapBreakpointCondition",
                { text = "◆", texthl = "DiagnosticWarn", linehl = "", numhl = "" }
            )
            vim.fn.sign_define(
                "DapBreakpointRejected",
                { text = "○", texthl = "DiagnosticError", linehl = "", numhl = "" }
            )
            vim.fn.sign_define(
                "DapStopped",
                { text = "→", texthl = "DiagnosticInfo", linehl = "DapStoppedLine", numhl = "" }
            )
            vim.fn.sign_define("DapLogPoint", { text = "◉", texthl = "DiagnosticInfo", linehl = "", numhl = "" })

            -- Set highlight for stopped line
            vim.api.nvim_set_hl(0, "DapStoppedLine", { bg = "#2d3640" })
        end,
    },
}
