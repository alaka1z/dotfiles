-- Leader
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- Options
local options = {
  -- Appearance
  number = true,
  relativenumber = true,
  cursorline = true,
  cursorlineopt = "both",
  signcolumn = "yes", -- Keep the gutter visible

  -- Editing
  undofile = true, -- Persist undo history between sessions
  clipboard = "unnamedplus", -- Use the Windows system clipboard
  fileformats = { "unix", "dos" }, -- Prefer LF for new files while still detecting CRLF

  -- Search
  ignorecase = true,
  smartcase = true,

  -- Windows
  splitright = true,
  splitbelow = true,

  -- Display
  linebreak = true,
  breakindent = true,
  scrolloff = 5,

  -- Indentation
  tabstop = 2,
  shiftwidth = 2,
  softtabstop = 2,
  expandtab = true, -- Use spaces instead of literal tab characters
}

for key, value in pairs(options) do
  vim.opt[key] = value
end

-- Keymaps
local map = vim.keymap.set

-- Reserve Space for leader mappings
map({ "n", "v" }, "<Space>", "<Nop>", { silent = true })

-- Reload configuration
map("n", "<leader>r", "<cmd>source $MYVIMRC<CR>", { desc = "Reload config" })

-- Keep text selected after indenting
map("v", "<", "<gv", { desc = "Indent left" })
map("v", ">", ">gv", { desc = "Indent right" })

-- Plugins
require("config.lazy")
