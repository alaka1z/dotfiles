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

-- Save and Quit
vim.keymap.set("n", "<leader>w", "<cmd>wa!<cr>", { desc = "Save all" })
vim.keymap.set("n", "<leader>q", "<cmd>wa! | qa!<cr>", { desc = "Quit" })
