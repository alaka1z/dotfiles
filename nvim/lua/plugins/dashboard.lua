return {
  {
    "folke/snacks.nvim",

    -- Load early so the dashboard is available on startup
    priority = 1000,
    lazy = false,

    opts = {
      dashboard = {
        enabled = true,
      },
    },
  },
}
