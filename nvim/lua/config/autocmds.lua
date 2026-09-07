-- Briefly highlight text after yanking
vim.api.nvim_create_autocmd("TextYankPost", {
  callback = function()
    vim.highlight.on_yank()
  end,
})

-- Restore the last cursor position when reopening a file
vim.api.nvim_create_autocmd("BufReadPost", {
  callback = function()
    local mark = vim.api.nvim_buf_get_mark(0, '"')
    local line_count = vim.api.nvim_buf_line_count(0)

    if mark[1] > 0 and mark[1] <= line_count then
      vim.api.nvim_win_set_cursor(0, mark)
    end
  end,
})

local function apply_theme_transparency()
  local normal = vim.api.nvim_get_hl(0, {
    name = "Normal",
    link = false,
  })

  if normal.bg then
    vim.api.nvim_set_hl(0, "ThemeNormal", {
      fg = normal.fg,
      bg = normal.bg,
    })
  end

  local transparent_groups = {
    "Normal",
    "NormalNC",
    "SignColumn",
    "EndOfBuffer",
  }

  for _, group in ipairs(transparent_groups) do
    vim.api.nvim_set_hl(0, group, {
      bg = "NONE",
      update = true,
    })
  end

  vim.api.nvim_exec_autocmds("User", {
    pattern = "ThemeReady",
  })
end

vim.api.nvim_create_autocmd("ColorScheme", {
  group = vim.api.nvim_create_augroup(
    "theme_transparency",
    { clear = true }
  ),
  callback = apply_theme_transparency,
})

vim.schedule(apply_theme_transparency)

vim.api.nvim_create_autocmd("User", {
  pattern = "ThemeReady",
  callback = function()
    for _, buf in ipairs(vim.api.nvim_list_bufs()) do
      if
        vim.api.nvim_buf_is_loaded(buf)
        and vim.bo[buf].filetype == "tex"
      then
        vim.api.nvim_buf_call(buf, function()
          vim.cmd([[
            if exists('b:vimtex.compiler')
                  \ && has_key(b:vimtex.compiler, 'texpresso_theme')
              call b:vimtex.compiler.texpresso_theme()
            endif
          ]])
        end)
      end
    end
  end,
})
