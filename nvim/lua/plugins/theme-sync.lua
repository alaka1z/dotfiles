return {
  {
    dir = vim.fn.expand("~/dev/theme-sync.nvim"),
    name = "theme-sync.nvim",
    lazy = false,

    dependencies = {
      "ibhagwan/fzf-lua",
    },

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
