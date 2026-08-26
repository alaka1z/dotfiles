-- Keymaps
local map = vim.keymap.set

-- Reserve Space for leader mappings
map({ "n", "v" }, "<Space>", "<Nop>", { silent = true })

-- Reload configuration
map("n", "<leader>r", "<cmd>restart<CR>", { desc = "Reload config" })

-- Keep text selected after indenting
map("v", "<", "<gv", { desc = "Indent left" })
map("v", ">", ">gv", { desc = "Indent right" })

