-- Keymaps
local map = vim.keymap.set

-- Reserve Space for leader mappings
map({ "n", "v" }, "<Space>", "<Nop>", { silent = true })

-- Reload configuration
map("n", "<leader>r", "<cmd>restart<CR>", { desc = "Reload config" })

-- Indentation
map("n", ">", ">>", { desc = "Indent right" })
map("n", "<", "<<", { desc = "Indent left" })

-- Keep text selected after indenting
map("v", "<", "<gv", { desc = "Indent left" })
map("v", ">", ">gv", { desc = "Indent right" })

-- Move by visual lines when text is wrapped
map("n", "j", "v:count == 0 ? 'gj' : 'j'", { expr = true })
map("n", "k", "v:count == 0 ? 'gk' : 'k'", { expr = true })

-- Comment remap
map("n", "<C-_>", "gcc", { remap = true, desc = "Toggle comment" })
map("v", "<C-_>", "gc", { remap = true, desc = "Toggle comment" })
