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

map("n", "<leader>v", function()
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

end, {
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

map("n", "<leader>tk", "<cmd>VimtexStop<cr>", {
  buffer = true,
  desc = "Stop compiler",
})

local function set_mode_mappings()
  local buffer = vim.api.nvim_get_current_buf()

  pcall(vim.keymap.del, "n", "<leader>tf", { buffer = buffer })
  pcall(vim.keymap.del, "n", "<leader>tt", { buffer = buffer })

  if vim.g.latex_viewer_mode ~= "texpresso" then
    return
  end

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
      vim.fn.expand(
        "~/.config/texpresso/texpresso-toggle-titlebar.ps1"
      ),
    })
  end, {
    buffer = true,
    desc = "Toggle TeXpresso titlebar",
  })
end

map("n", "<leader>tm", function()
  vim.cmd("VimtexStop")

  if vim.g.latex_viewer_mode == "sioyek" then
    vim.g.latex_viewer_mode = "texpresso"
    vim.g.vimtex_compiler_method = "texpresso"
  else
    vim.g.latex_viewer_mode = "sioyek"
    vim.g.vimtex_compiler_method = "latexmk"
  end

  vim.cmd("VimtexReload")
  set_mode_mappings()

  vim.notify(
    "LaTeX mode: " .. vim.g.latex_viewer_mode
  )
end, {
  buffer = true,
  desc = "Switch LaTeX mode",
})

set_mode_mappings()
