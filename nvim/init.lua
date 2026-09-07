-- Leader
vim.g.mapleader = " "
vim.g.maplocalleader = " "

require("config.keymaps")
require("config.options")
require("config.lazy")

local theme_path = vim.fn.stdpath("state") .. "/theme-sync-test"
local theme = "catppuccin-mocha"

if vim.fn.filereadable(theme_path) == 1 then
  local saved = vim.fn.readfile(theme_path)[1]

  local themes = {
    ["catppuccin-mocha"] = true,
    ["tokyonight-moon"] = true,
    gruvbox = true,
    ["rose-pine"] = true,
  }

  if saved and themes[saved] then
    theme = saved
  end
end

vim.cmd.colorscheme(theme)

require("config.autocmds")
require("config.lsp")
