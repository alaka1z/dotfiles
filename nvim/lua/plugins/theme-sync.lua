return {
  {
    "alaka1z/theme-sync.nvim",

    config = function()
      local themes = dofile(
        vim.fn.expand("~/.config/theme-sync/themes.lua")
      )

      require("theme-sync").setup({
        themes = themes,
      })
    end,
  },
}
