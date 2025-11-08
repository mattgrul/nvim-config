function ColorMyPencils(color)
    color = color or "rose-pine-moon"
    vim.cmd.colorscheme(color)

    -- Make background transparent
    vim.api.nvim_set_hl(0, "Normal", { bg = "none" })
    vim.api.nvim_set_hl(0, "NormalFloat", { bg = "none" })
    vim.api.nvim_set_hl(0, "NormalNC", { bg = "none" })
    vim.api.nvim_set_hl(0, "SignColumn", { bg = "none" })
    vim.api.nvim_set_hl(0, "EndOfBuffer", { bg = "none" })
    vim.api.nvim_set_hl(0, "NormalSB", { bg = "none" })
end

return {
    -- Tokyo Night - alternative colorscheme (lazy-loaded)
    {
        "folke/tokyonight.nvim",
        opts = {
            style = "storm", -- storm, moon, night, or day
            transparent = true,
            terminal_colors = true,
            styles = {
                comments = { italic = false },
                keywords = { italic = false },
                sidebars = "dark",
                floats = "dark",
            },
        },
    },

    -- Rose Pine - default colorscheme (loads immediately on startup)
    {
        "rose-pine/neovim",
        name = "rose-pine",
        lazy = false,
        priority = 1000,
        opts = {
            styles = {
                italic = false,
                bold = false,
            },
        },
        config = function()
            ColorMyPencils()
        end,
    },
}
