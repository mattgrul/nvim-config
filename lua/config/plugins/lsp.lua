return {
    {
        "neovim/nvim-lspconfig",
        dependencies = {
            "hrsh7th/cmp-nvim-lsp",
            "williamboman/mason-lspconfig.nvim",
            {
                "folke/lazydev.nvim",
                opts = {
                    library = {
                        { path = "${3rd}/luv/library", words = { "vim%.uv" } },
                        { path = "snacks.nvim",        words = { "Snacks" } },
                    },
                },
            },
        },
        config = function()
            local lsp_group = vim.api.nvim_create_augroup("my.lsp", { clear = true })

            vim.api.nvim_create_autocmd("LspAttach", {
                group = lsp_group,
                callback = function(args)
                    local client = vim.lsp.get_client_by_id(args.data.client_id)
                    if not client then
                        return
                    end

                    -- LSP hover with rounded border
                    vim.keymap.set("n", "K", function()
                        vim.lsp.buf.hover({ border = "rounded" })
                    end, { buffer = args.buf, desc = "LSP Hover" })

                    -- Code actions (normal and visual mode)
                    vim.keymap.set(
                        { "n", "v" },
                        "<leader>ca",
                        vim.lsp.buf.code_action,
                        { buffer = args.buf, desc = "Code Action" }
                    )

                    -- LSP rename
                    vim.keymap.set("n", "<leader>cr", vim.lsp.buf.rename, { buffer = args.buf, desc = "Rename" })

                    -- Auto-format on save
                    vim.api.nvim_create_autocmd("BufWritePre", {
                        group = lsp_group,
                        buffer = args.buf,
                        callback = function()
                            vim.lsp.buf.format({ bufnr = args.buf, id = client.id, timeout_ms = 1000 })
                        end,
                    })
                end,
            })
        end,
    },
    {
        "mason-org/mason-lspconfig.nvim",
        dependencies = {
            "mason-org/mason.nvim",
            "neovim/nvim-lspconfig",
            "hrsh7th/nvim-cmp",
        },
        config = function()
            local lspconfig = require("lspconfig")
            local cmp_nvim_lsp = require("cmp_nvim_lsp")
            local capabilities = cmp_nvim_lsp.default_capabilities()

            require("mason-lspconfig").setup({
                handlers = {
                    -- Default handler - applies to all servers
                    function(server_name)
                        lspconfig[server_name].setup({
                            capabilities = capabilities,
                        })
                    end,

                    -- Intelephense-specific handler for proper Magento/Laravel root detection
                    intelephense = function()
                        local util = require("lspconfig.util")
                        lspconfig.intelephense.setup({
                            capabilities = capabilities,
                            -- Search for .git directory first, fall back to cwd
                            root_dir = function(fname)
                                return util.root_pattern('.git')(fname) or vim.uv.cwd()
                            end,
                        })
                    end,
                },
            })
        end,
    },
    {
        "ray-x/lsp_signature.nvim",
        event = "InsertEnter",
        dependencies = { "neovim/nvim-lspconfig" },
        config = function()
            require("lsp_signature").setup({
                bind = true,
                handler_opts = {
                    border = "rounded",
                },
                floating_window = true,
                floating_window_above_cur_line = true,

                doc_lines = 10,
                max_height = 12,
                max_width = 80,

                hi_parameter = "LspSignatureActiveParameter",

                close_timeout = 4000,
                fix_pos = false,
                timer_interval = 200,

                toggle_key = "<C-s>",
                select_signature_key = "<C-k>",

                zindex = 200,
                padding = " ",
                transparency = nil,
            })
        end,
    },

    vim.diagnostic.config({
        virtual_text = false,
        virtual_lines = true,
    }),
}
