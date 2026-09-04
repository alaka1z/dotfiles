local map = vim.keymap.set
local opt = vim.opt_local

-- Enable spell checking only while editing TeX
opt.spell = true

-- opt.conceallevel = 2
-- opt.concealcursor = "nc"

local function compiler_for_mode()
  return vim.g.latex_viewer_mode == "texpresso"
      and "texpresso"
      or "latexmk"
end

local function view()
  if vim.g.latex_viewer_mode == "sioyek" then
    vim.cmd("VimtexView")
    return
  end

  if vim.fn.eval("b:vimtex.compiler.is_running()") == 0 then
    vim.notify("TeXpresso is not running", vim.log.levels.WARN)
    return
  end

  vim.cmd([[
    call b:vimtex.compiler.texpresso_send(
      \ "synctex-forward",
      \ b:vimtex.compiler.texpresso_path(expand("%:p")),
      \ line(".")
      \ )
  ]])
end

local function toggle_texpresso_follow()
  vim.cmd("call b:vimtex.compiler.texpresso_synctex_forward_toggle()")
end

local function toggle_texpresso_titlebar()
  vim.system({
    "pwsh.exe",
    "-NoProfile",
    "-File",
    vim.fn.expand("~/.config/texpresso/texpresso-toggle-titlebar.ps1"),
  })
end

-- Build the conventional PDF from disk without affecting TeXpresso
local function build_sioyek_pdf()
  local tex = vim.b.vimtex.tex
  local cwd = vim.fn.fnamemodify(tex, ":h")
  local filename = vim.fn.fnamemodify(tex, ":t")

  vim.system({
    "latexmk",
    "-xelatex",
    "-synctex=1",
    filename,
  }, {
    cwd = cwd,
  }, function(result)
    if result.code ~= 0 then
      vim.schedule(function()
        vim.notify("XeLaTeX build failed", vim.log.levels.ERROR)
      end)
    end
  end)
end

-- Add TeXpresso-only mappings so they reflect the active mode in Which-Key
local function set_mode_mappings()
  pcall(vim.keymap.del, "n", "<leader>tf", { buffer = true })
  pcall(vim.keymap.del, "n", "<leader>tt", { buffer = true })
  pcall(vim.keymap.del, "n", "<leader>tsb", { buffer = true })
  pcall(vim.keymap.del, "n", "<leader>tsv", { buffer = true })

  if vim.g.latex_viewer_mode ~= "texpresso" then
    return
  end

  map("n", "<leader>tf", toggle_texpresso_follow, {
    buffer = true,
    desc = "Toggle TeXpresso follow",
  })

  map("n", "<leader>tt", toggle_texpresso_titlebar, {
    buffer = true,
    desc = "Toggle TeXpresso titlebar",
  })

  map("n", "<leader>tsb", build_sioyek_pdf, {
    buffer = true,
    desc = "Build PDF with Sioyek",
  })

  map("n", "<leader>tsv", "<cmd>VimtexView<cr>", {
    buffer = true,
    desc = "View in Sioyek",
  })
end

-- Keep VimTeX's per-buffer compiler aligned with the global LaTeX mode
local function sync_mode()
  if not vim.b.vimtex or not vim.b.vimtex.compiler then
    return
  end

  local expected_compiler = compiler_for_mode()

  if vim.b.vimtex.compiler.name ~= expected_compiler then
    vim.cmd("VimtexStop")
    vim.g.vimtex_compiler_method = expected_compiler
    vim.cmd("VimtexReload")
  end

  set_mode_mappings()
end

local function switch_mode()
  vim.g.latex_viewer_mode =
    vim.g.latex_viewer_mode == "sioyek"
      and "texpresso"
      or "sioyek"

  vim.g.vimtex_compiler_method = compiler_for_mode()

  sync_mode()

  vim.notify("LaTeX mode: " .. vim.g.latex_viewer_mode)
end

-- Frequently used VimTeX actions
map("n", "<leader>b", "<cmd>VimtexCompile<cr>", {
  buffer = true,
  desc = "Compile",
})

map("n", "<leader>v", view, {
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

map("n", "<leader>tc", "<cmd>VimtexTocOpen<cr>", {
  buffer = true,
  desc = "Table of contents",
})

map("n", "<leader>tm", switch_mode, {
  buffer = true,
  desc = "Switch LaTeX mode",
})

-- Synchronize each TeX project lazily when returning to its buffer
vim.api.nvim_create_autocmd("BufEnter", {
  buffer = vim.api.nvim_get_current_buf(),
  callback = sync_mode,
})

set_mode_mappings()
