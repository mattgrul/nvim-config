return {
    {
        "ThePrimeagen/harpoon",
        enabled = true,
        branch = "harpoon2",
        dependencies = { "nvim-lua/plenary.nvim" },
        opts = {},
        config = function()
            local harpoon = require("harpoon")

            -- Add current file to Harpoon list
            vim.keymap.set("n", "<C-a>", function()
                harpoon:list():add()
            end, { desc = "Harpoon: Add file" })

            -- Toggle the quick menu UI
            vim.keymap.set("n", "<C-e>", function()
                harpoon.ui:toggle_quick_menu(harpoon:list())
            end, { desc = "Harpoon: Toggle menu" })

            -- Navigate to specific files (positions 1-4)
            vim.keymap.set("n", "<leader>1", function()
                harpoon:list():select(1)
            end, { desc = "Harpoon: File 1" })
            vim.keymap.set("n", "<leader>2", function()
                harpoon:list():select(2)
            end, { desc = "Harpoon: File 2" })
            vim.keymap.set("n", "<leader>3", function()
                harpoon:list():select(3)
            end, { desc = "Harpoon: File 3" })
            vim.keymap.set("n", "<leader>4", function()
                harpoon:list():select(4)
            end, { desc = "Harpoon: File 4" })

            -- Cycle through list items
            vim.keymap.set("n", "<C-S-P>", function()
                harpoon:list():prev()
            end, { desc = "Harpoon: Previous" })
            vim.keymap.set("n", "<C-S-N>", function()
                harpoon:list():next()
            end, { desc = "Harpoon: Next" })
        end,
    },
}
