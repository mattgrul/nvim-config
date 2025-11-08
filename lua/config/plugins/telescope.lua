return {
    {
        "nvim-telescope/telescope.nvim",
        enabled = false,
        tag = "0.1.8",
        dependencies = {
            "nvim-lua/plenary.nvim",
            { "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
        },
        opts = {
            extensions = {
                fzf = {},
            },
        },
        config = function()
            require("telescope").load_extension("fzf")

            local builtin = require("telescope.builtin")

            vim.keymap.set("n", "<leader>ff", builtin.find_files, { desc = "Find files" })
            vim.keymap.set("n", "<space>fi", function()
                builtin.find_files({
                    prompt_title = "Find Files (including ignored)",
                    hidden = true,
                    no_ignore = true,
                })
            end, { desc = "Find files (including ignored)" })
            vim.keymap.set("n", "<leader>fb", builtin.buffers, { desc = "Find in buffers" })
            vim.keymap.set("n", "<leader>fh", builtin.help_tags, { desc = "Find in help tags" })
            vim.keymap.set("n", "<space>fn", function()
                builtin.find_files({
                    cwd = vim.fn.stdpath("config"),
                })
            end, { desc = "Find in nvim config files" })
            vim.keymap.set("n", "<space>fl", function()
                builtin.find_files({
                    cwd = vim.fs.joinpath(vim.fn.stdpath("data"), "lazy"),
                })
            end, { desc = "Find in nvim lazy files" })
            vim.keymap.set("n", "<leader>fg", builtin.live_grep, { desc = "Live grep" })
        end,
    },
}
