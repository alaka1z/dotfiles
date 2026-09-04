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

local function set_mode_mappings()
  pcall(vim.keymap.del, "n", "<leader>tf", { buffer = true })
  pcall(vim.keymap.del, "n", "<leader>tt", { buffer = true })
  pcall(vim.keymap.del, "n", "<leader>tsb", { buffer = true })
  pcall(vim.keymap.del, "n", "<leader>tsv", { buffer = true })

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
      vim.fn.expand("~/.config/texpresso/texpresso-toggle-titlebar.ps1"),
    })
  end, {
    buffer = true,
    desc = "Toggle TeXpresso titlebar",
  })

  map("n", "<leader>tsb", function()
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
  end, {
    buffer = true,
    desc = "Build PDF with Sioyek",
  })

  map("n", "<leader>tsv", "<cmd>VimtexView<cr>", {
    buffer = true,
    desc = "View in Sioyek",
  })
end

local function sync_mode()
  if not vim.b.vimtex or not vim.b.vimtex.compiler then
    return
  end

  local expected =
    vim.g.latex_viewer_mode == "texpresso"
      and "texpresso"
      or "latexmk"

  if vim.b.vimtex.compiler.name ~= expected then
    if vim.b.vimtex.compiler.name == "texpresso" then
      vim.cmd("autocmd! vimtex_compiler_texpresso * <buffer>")
    end

    vim.cmd("VimtexStop")
    vim.g.vimtex_compiler_method = expected
    vim.cmd("VimtexReload")
  end

  set_mode_mappings()
end

map("n", "<leader>tm", function()
  if vim.g.latex_viewer_mode == "sioyek" then
    vim.g.latex_viewer_mode = "texpresso"
    vim.g.vimtex_compiler_method = "texpresso"
  else
    vim.g.latex_viewer_mode = "sioyek"
    vim.g.vimtex_compiler_method = "latexmk"
  end

  sync_mode()

  vim.notify(
    "LaTeX mode: " .. vim.g.latex_viewer_mode
  )
end, {
  buffer = true,
  desc = "Switch LaTeX mode",
})

vim.api.nvim_create_autocmd("BufEnter", {
  buffer = vim.api.nvim_get_current_buf(),
  callback = sync_mode,
})

set_mode_mappings()


