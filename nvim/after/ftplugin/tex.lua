local map = vim.keymap.set
local opt = vim.opt_local

-- Enable spell checking only while editing TeX
opt.spell = true

-- opt.conceallevel = 2
-- opt.concealcursor = "nc"

-- Frequently used VimTeX actions

-- map("n", "<leader>b", "<cmd>VimtexCompile!<cr>", {
--   buffer = true,
--   desc = "Compile",
-- })

map("n", "<leader>b", function()
  local script =
    vim.fn.expand("~/.config/texpresso/texpresso-return.ps1")

  local output = vim.fn.system(
    'pwsh.exe -NoProfile -File "' .. script .. '"'
  )

  if vim.v.shell_error ~= 0 then
    vim.notify(output, vim.log.levels.ERROR)
    return
  end

  vim.cmd("VimtexCompile!")
end, {
  buffer = true,
  desc = "Compile",
})

map("n", "<leader>v", function()
  local tex = vim.api.nvim_buf_get_name(0)
  local pdf = vim.fn.fnamemodify(tex, ":r") .. ".pdf"
  local cwd = vim.fn.fnamemodify(tex, ":h")
  local filename = vim.fn.fnamemodify(tex, ":t")
  local line = vim.api.nvim_win_get_cursor(0)[1]

  local geometry =
    vim.fn.expand("~/.config/texpresso/sioyek-geometry.ps1")

  local takeover =
    vim.fn.expand("~/.config/texpresso/sioyek-takeover.ps1")

  vim.cmd("write")

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
      return
    end

    vim.schedule(function()
      local geometry_result = vim.system({
        "pwsh.exe",
        "-NoProfile",
        "-File",
        geometry,
      }):wait()

      if geometry_result.code ~= 0 then
        vim.notify(
          geometry_result.stderr,
          vim.log.levels.ERROR
        )
        return
      end

      vim.system({
        "pwsh.exe",
        "-NoProfile",
        "-File",
        takeover,
      })

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
  end)
end, {
  buffer = true,
  desc = "View in Sioyek",
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
