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

map("n", "<leader>v", "<cmd>VimtexView<cr>", {
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

map("n", "<leader>ts", function()
  local tex = vim.api.nvim_buf_get_name(0)
  local pdf = vim.fn.fnamemodify(tex, ":r") .. ".pdf"
  local cwd = vim.fn.fnamemodify(tex, ":h")
  local line = vim.api.nvim_win_get_cursor(0)[1]

  vim.cmd("write")

  vim.system({
    "latexmk",
    "-xelatex",
    "-synctex=1",
    vim.fn.fnamemodify(tex, ":t"),
  }, {
    cwd = cwd,
  }, function(result)
    if result.code ~= 0 then
      vim.schedule(function()
        vim.notify("XeLaTeX build failed", vim.log.levels.ERROR)
      end)
      return
    end

    vim.system({
      "sioyek",
      "--inverse-search",
      [[nvim --headless -c "VimtexInverseSearch %2 '%1'"]],
      "--forward-search-file",
      tex,
      "--forward-search-line",
      tostring(line),
      pdf,
    }, {
      detach = true,
    })
  end)
end, {
  buffer = true,
  desc = "Build and open Sioyek",
})

map("n", "<leader>tp", function()
  vim.system({
    "pwsh.exe",
    "-NoProfile",
    "-File",
    vim.fn.expand("~/.config/texpresso/texpresso-focus.ps1"),
  })
end, {
  buffer = true,
  desc = "Focus TeXpresso",
})
