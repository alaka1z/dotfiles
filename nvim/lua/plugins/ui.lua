return {
  {
    "nvim-mini/mini.icons",
    version = false,
    opts = {},
  },

  -- Keep devicons available for plugins that expect it directly
  {
    "nvim-tree/nvim-web-devicons",
    opts = {},
  },

  -- Follow the active colorscheme automatically
  {
    "nvim-lualine/lualine.nvim",

    opts = {
      options = {
        theme = "auto",
      },

      -- Show the active LaTeX mode alongside the filetype in TeX buffers
      sections = {
        lualine_x = {
          {
            function()
              return vim.g.latex_viewer_mode == "texpresso"
              and vim.fn.nr2char(0x100001)
              or vim.fn.nr2char(0x100000)
            end,

            cond = function()
              return vim.bo.filetype == "tex"
            end,
          },

          "filetype",
        },
      },
    },
  },
}
