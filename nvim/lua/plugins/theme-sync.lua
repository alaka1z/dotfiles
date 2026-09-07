return {
  {
    dir = vim.fn.expand("~/dev/theme-sync.nvim"),
    name = "theme-sync.nvim",
    lazy = false,

    dependencies = {
      "ibhagwan/fzf-lua",
    },

    config = function()
      require("theme-sync").setup()
    end,
  },
}
