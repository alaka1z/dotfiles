return {
  {
    "ibhagwan/fzf-lua",
    opts = {
      "telescope",
    },

    keys = {
      {
        "<leader>ff",
        "<cmd>FzfLua files<cr>",
        desc = "Find files",
      },
      {
        "<leader>fg",
        "<cmd>FzfLua live_grep<cr>",
        desc = "Grep files",
      },
      {
        "<leader>fb",
        "<cmd>FzfLua buffers<cr>",
        desc = "Find buffers",
      },
      {
        "<leader>fr",
        "<cmd>FzfLua resume<cr>",
        desc = "Resume search",
      },
    },
  },
}
