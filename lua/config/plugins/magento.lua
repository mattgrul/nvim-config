return {
    name = "magento.nvim",
    dir = vim.fn.stdpath("config") .. "/lua/magento",
    dependencies = {
        "nvim-lua/plenary.nvim",
        "nvim-neotest/nvim-nio",
    },
    cmd = { "Magento" },
    ft = { "php", "xml" },
    keys = {
        {
            "<leader>mm",
            function()
                vim.cmd("Magento commands")
            end,
            desc = "Magento Commands",
        },
        {
            "<leader>mr",
            function()
                -- Clear magento modules from cache (this also clears command cache)
                for k in pairs(package.loaded) do
                    if k:match("^magento") then
                        package.loaded[k] = nil
                    end
                end
                -- Reload plugin
                require("magento").setup({ dev_mode = true })
                vim.notify("Magento plugin reloaded (command cache cleared)", vim.log.levels.INFO)
            end,
            desc = "Reload Magento Plugin",
        },
    },
    opts = {},
    config = function(_, opts)
        require("magento").setup(opts)
    end,
}
