local map = vim.keymap.set

map("n", "<leader>b", "<cmd>VimtexCompile<cr>", {
    buffer = true,
    desc = "Compile",
})

map("n", "<leader>v", "<cmd>VimtexView<cr>", {
    buffer = true,
    desc = "View",
})

map("n", "<leader>le", "<cmd>VimtexErrors<cr>", {
    buffer = true,
    desc = "Errors",
})

map("n", "<leader>lx", "<cmd>VimtexClean<cr>", {
    buffer = true,
    desc = "Clean",
})

map("n", "<leader>lt", "<cmd>VimtexTocOpen<cr>", {
    buffer = true,
    desc = "Table of contents",
})

map("n", "<leader>lk", "<cmd>VimtexStop<cr>", {
    buffer = true,
    desc = "Stop compiler",
})
