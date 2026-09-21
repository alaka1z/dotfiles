local map = vim.keymap.set
local opt = vim.opt_local

local mode = require("tex.mode")
local packages = require("tex.packages")

-- Enable spell checking only while editing TeX
opt.spell = true

-- opt.conceallevel = 2
-- opt.concealcursor = "nc"

-- Update mode-dependent mappings so they reflect the active mode in Which-Key
local function set_mode_mappings()
  local current_mode = vim.g.latex_viewer_mode

  if vim.b.latex_mapping_mode == current_mode then
    return
  end

  pcall(vim.keymap.del, "n", "<leader>tf", { buffer = true })
  pcall(vim.keymap.del, "n", "<leader>tt", { buffer = true })
  pcall(vim.keymap.del, "n", "<leader>tsb", { buffer = true })
  pcall(vim.keymap.del, "n", "<leader>tsv", { buffer = true })
  pcall(vim.keymap.del, "n", "<leader>te", { buffer = true })

  map("n", "<leader>te", "<cmd>VimtexErrors<cr>", {
    buffer = true,
    desc = "Errors",
  })

  if current_mode == "texpresso" then
    map("n", "<leader>te", mode.open_texpresso_log, {
      buffer = true,
      desc = "TeXpresso log",
    })

    map("n", "<leader>tf", mode.toggle_texpresso_follow, {
      buffer = true,
      desc = "Toggle TeXpresso follow",
    })

    map("n", "<leader>tt", mode.toggle_texpresso_titlebar, {
      buffer = true,
      desc = "Toggle TeXpresso titlebar",
    })

    map("n", "<leader>tsb", mode.build_sioyek_pdf, {
      buffer = true,
      desc = "Build PDF with Sioyek",
    })

    map("n", "<leader>tsv", "<cmd>VimtexView<cr>", {
      buffer = true,
      desc = "View in Sioyek",
    })
  end

  vim.b.latex_mapping_mode = current_mode
end

local function sync_mode()
  mode.sync()
  set_mode_mappings()
end

local function switch_mode()
  mode.switch()
  set_mode_mappings()
end

-- Frequently used VimTeX actions
map("n", "<leader>b", "<cmd>VimtexCompile<cr>", {
  buffer = true,
  desc = "Compile",
})

map("n", "<leader>v", mode.view, {
  buffer = true,
  desc = "View",
})

-- Less frequent VimTeX actions
map("n", "<leader>tx", "<cmd>VimtexClean<cr>", {
  buffer = true,
  desc = "Clean",
})

map("n", "<leader>tc", "<cmd>VimtexTocOpen<cr>", {
  buffer = true,
  desc = "Table of contents",
})

map("n", "<leader>tm", switch_mode, {
  buffer = true,
  desc = "Switch TeX mode",
})

map("n", "<leader>tp", packages.pick, {
  buffer = true,
  desc = "TeX packages",
})

map("n", "<leader>ti", packages.install, {
  buffer = true,
  desc = "Install TeX package",
})

-- Synchronize each TeX project lazily when returning to its buffer
vim.api.nvim_create_autocmd("BufEnter", {
  buffer = vim.api.nvim_get_current_buf(),
  callback = sync_mode,
})

set_mode_mappings()
