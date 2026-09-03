local map = vim.keymap.set
local opt = vim.opt_local

-- Enable spell checking only while editing TeX
opt.spell = true

-- opt.conceallevel = 2
-- opt.concealcursor = "nc"

-- Frequently used VimTeX actions
map("n", "<leader>b", "<cmd>VimtexCompile<cr>", {
  buffer = true,
  desc = "Compile",
})

map("n", "<leader>v", "<cmd>VimtexView<cr>", {
  buffer = true,
  desc = "View",
})

-- Less frequent VimTeX actions
map("n", "<leader>te", "<cmd>VimtexErrors<cr>", {
  buffer = true,
  desc = "Errors",
})

map("n", "<leader>tx", "<cmd>VimtexClean<cr>", {
  buffer = true,
  desc = "Clean",
})

map("n", "<leader>tt", "<cmd>VimtexTocOpen<cr>", {
  buffer = true,
  desc = "Table of contents",
})

map("n", "<leader>tk", "<cmd>VimtexStop<cr>", {
  buffer = true,
  desc = "Stop compiler",
})

map("n", "<leader>tf", function()
  vim.cmd("call b:vimtex.compiler.texpresso_synctex_forward_toggle()")
end, {
  buffer = true,
  desc = "Toggle TeXpresso follow",
})

map("n", "<leader>tt", function()
  vim.system({
    "pwsh.exe",
    "-NoProfile",
    "-File",
    vim.fn.expand("~/.config/texpresso/texpresso-toggle-titlebar.ps1"),
  })
end, {
  buffer = true,
  desc = "Toggle TeXpresso titlebar",
})
