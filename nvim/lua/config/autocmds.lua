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

local theme_ids = {
  ["catppuccin-mocha"] = "catppuccin",
  ["tokyonight-moon"] = "tokyonight",
  gruvbox = "gruvbox",
  ["rose-pine"] = "rose-pine",
}

vim.api.nvim_create_autocmd("ColorScheme", {
  callback = function()
    local theme = theme_ids[vim.g.colors_name]

    if not theme then
      return
    end

    vim.api.nvim_ui_send(
      ("\27]1337;SetUserVar=NVIM_THEME_TEST=%s\7"):format(
        vim.base64.encode(theme)
      )
    )
  end,
})
