return {
  {
    "lervag/vimtex",
    lazy = false,
    init = function()
      -- Disable unnecessary mappings
      vim.g.vimtex_mappings_enabled = 0

      -- Use the general viewer backend to avoid an extra cmd window on Windows
      vim.g.vimtex_view_method = "general"
      vim.g.vimtex_view_general_viewer = 'start ""'

      -- Launch Sioyek with forward and inverse SyncTeX support
      vim.g.vimtex_view_general_options =
      [[sioyek --inverse-search "nvim --headless -c \"VimtexInverseSearch %2 '%1'\"" --forward-search-file @tex --forward-search-line @line @pdf]]

      -- Use pdfLaTeX by default for fast builds and reliable SyncTeX
      vim.g.vimtex_compiler_latexmk_engines = {
        _ = "-pdf",
      }
    end,
  },
}
