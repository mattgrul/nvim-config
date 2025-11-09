vim.keymap.set("n", "<space><space>x", "<cmd>source %<CR>", { desc = "Source current file" })
vim.keymap.set("n", "<space>x", ":.lua<CR>", { desc = "Execute current line as Lua" })
vim.keymap.set("v", "<space>x", ":lua", { desc = "Execute selection as Lua" })

vim.keymap.set("n", "<M-j>", "<cmd>cnext<CR>", { desc = "Next quickfix item" })
vim.keymap.set("n", "<M-k>", "<cmd>cprev<CR>", { desc = "Previous quickfix item" })

vim.keymap.set("n", "<Esc>c", "<Cmd>nohlsearch<CR>", { silent = true, desc = "Clear search highlight" })

vim.keymap.set("n", "<space>st", function()
    vim.cmd.vnew()
    vim.cmd.term()
    vim.cmd.wincmd("J")
    vim.api.nvim_win_set_height(0, 15)
end, { desc = "Open terminal in bottom split" })

vim.keymap.set("x", "<leader>p", [["_dP]])
