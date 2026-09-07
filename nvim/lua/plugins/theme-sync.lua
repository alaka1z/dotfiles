return {
  {
    dir = vim.fn.expand("~/dev/theme-sync.nvim"),
    name = "theme-sync.nvim",
    lazy = false,

    config = function()
      require("theme-sync").setup()
    end,
  },
}
