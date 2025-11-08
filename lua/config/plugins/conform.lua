return {
    "stevearc/conform.nvim",
    event = { "BufReadPre", "BufNewFile" },
    opts = {},
    config = function()
        require("conform").setup({
            formatters_by_ft = {
                lua = { "stylua" },
                php = { "phpcbf" },
                phtml = { "phpcbf" },
            },

            format_on_save = {
                timeout_ms = 5000,
                lsp_format = "fallback",
            },

            formatters = {
                phpcbf = {
                    -- Set CWD to project root so phpcbf can find phpcs.xml
                    cwd = require("conform.util").root_file({
                        "bin/magento", -- Magento 2
                        "artisan", -- Laravel
                        "composer.json", -- Generic PHP
                        ".git",
                    }),
                },
            },
        })

        vim.keymap.set({ "n", "v" }, "<leader>cf", function()
            require("conform").format({ bufnr = 0 })
        end, { desc = "Format buffer" })
    end,
}
