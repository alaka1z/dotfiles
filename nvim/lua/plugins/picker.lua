return {
  {
    "ibhagwan/fzf-lua",
    opts = {
      "telescope",

      winopts = {
        title_flags = false,
      },

      grep = {
        no_header_i = true,
      },

      keymaps = {
        show_details = false,

        fzf_opts = {
          ["--header"] = false,
        },
      },

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
        "<leader>fo",
        "<cmd>FzfLua oldfiles<cr>",
        desc = "Recent files",
      },
      {
        "<leader>fl",
        "<cmd>FzfLua blines<cr>",
        desc = "Find line",
      },
      {
        "<leader>ff",
        "<cmd>FzfLua files<cr>",
        desc = "Find files",
      },
      {
        "<leader>fg",
        "<cmd>FzfLua grep_project<cr>",
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
        "<leader>fw",
        "<cmd>FzfLua grep_cword<cr>",
        desc = "Find word",
      },
      {
        "<leader>ss",
        "<cmd>FzfLua spell_suggest<cr>",
        desc = "Spell suggestions",
      },
      {
        "<leader>sh",
        "<cmd>FzfLua helptags<cr>",
        desc = "Help",
      },
      {
        "<leader>sk",
        "<cmd>FzfLua keymaps<cr>",
        desc = "Keymaps",
      },
      {
        "<leader>sc",
        "<cmd>FzfLua commands<cr>",
        desc = "Commands",
      },
      {
        "<leader>sb",
        "<cmd>FzfLua builtin<cr>",
        desc = "Builtins",
      },
    },
  },
}
