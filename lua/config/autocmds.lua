vim.api.nvim_create_autocmd("TextYankPost", {
    desc = "Highlight when yanking (copying) text",
    group = vim.api.nvim_create_augroup("kickstart-highlight-yank", { clear = true }),
    callback = function()
        vim.highlight.on_yank()
    end,
})

vim.api.nvim_create_autocmd("TermOpen", {
    desc = "Disable line numbers and signcolumn in terminal buffers",
    group = vim.api.nvim_create_augroup("custom-term-open", { clear = true }),
    callback = function()
        vim.opt.number = false
        vim.opt.relativenumber = false
    end,
})

vim.api.nvim_create_autocmd("BufWritePre", {
    desc = "Auto-create missing parent directories before writing files",
    group = vim.api.nvim_create_augroup("auto-create-dir", { clear = true }),
    callback = function(args)
        local dir = vim.fn.fnamemodify(args.file, ":p:h")
        if vim.fn.isdirectory(dir) == 0 then
            vim.fn.mkdir(dir, "p")
        end
    end,
})
