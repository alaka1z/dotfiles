return {
  {
    "ibhagwan/fzf-lua",
    opts = {
      "telescope",

      spell_suggest = {
        winopts = {
          height = 0.33,
          width = 0.33,
          relative = "cursor",
        },
      },
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
      {
        "<leader>ss",
        "<cmd>FzfLua spell_suggest<cr>",
        desc = "Spell suggestions",
      },
    },
  },
}
