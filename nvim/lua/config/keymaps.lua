local map = vim.keymap.set

-- Reserve Space for leader mappings
map({ "n", "v" }, "<Space>", "<Nop>", { silent = true })

-- Reload configuration
map("n", "<leader>r", "<cmd>restart<CR>", { desc = "Reload config" })

-- Use single < and > presses to indent the current line
map("n", ">", ">>", { desc = "Indent right" })
map("n", "<", "<<", { desc = "Indent left" })

-- Keep the selection active when indenting multiple lines
map("v", "<", "<gv", { desc = "Indent left" })
map("v", ">", ">gv", { desc = "Indent right" })

-- Move by visual lines when text is wrapped
map("n", "j", "v:count == 0 ? 'gj' : 'j'", { expr = true })
map("n", "k", "v:count == 0 ? 'gk' : 'k'", { expr = true })

-- Ctrl+/ toggles Neovim's native language-aware commenting
map("n", "<C-_>", "gcc", { remap = true, desc = "Toggle comment" })
map("v", "<C-_>", "gc", { remap = true, desc = "Toggle comment" })

-- Save and quit
map("n", "<leader>w", "<cmd>wa!<cr>", { desc = "Save all" })
map("n", "<leader>q", "<cmd>wa! | qa!<cr>", { desc = "Quit" })

-- Show diagnostics at the cursor
map("n", "<leader>d", vim.diagnostic.open_float, {
  desc = "Diagnostics",
})

-- Reveal the current file in File Explorer
map("n", "<leader>o", function()
  local path = vim.fn.expand("%:p"):gsub("/", "\\")

  if path == "" then
    return
  end

  os.execute('explorer.exe /select,"' .. path .. '"')
end, { desc = "Reveal in Explorer" })

-- Clear search highlighting and stale messages
map("n", "<Esc>", function()
  vim.cmd("nohlsearch")
  vim.cmd('echo ""')
end, { desc = "Clear search and messages" })
