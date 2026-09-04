local texpresso_distro = "Ubuntu-24.04"

local windows_home = vim.fn.expand("~"):gsub("\\", "/")
local drive, rest = windows_home:match("^([A-Za-z]):/(.*)$")
local wsl_home = "/mnt/" .. drive:lower() .. "/" .. rest
local texpresso_wrapper = wsl_home .. "/.config/texpresso/texpresso-vcxsrv"

return {
  {
    "alaka1z/vimtex",
    branch = "texpresso-wsl-minimal",

    -- Keep VimTeX available from startup for TeX commands and callbacks
    lazy = false,

    init = function()
      -- Disable VimTeX's default mappings in favor of our TeX-local mappings
      vim.g.vimtex_mappings_enabled = 0

      -- Use TeXpresso as the compiler for this initial test
      vim.g.latex_viewer_mode = vim.g.latex_viewer_mode or "sioyek"

      vim.g.vimtex_compiler_method =
      vim.g.latex_viewer_mode == "texpresso"
      and "texpresso"
      or "latexmk"

      vim.g.vimtex_compiler_texpresso = {
        wsl = texpresso_distro,

        executable = {
          "wsl.exe",
          "-d",
          texpresso_distro,
          "--",
          "sh",
          texpresso_wrapper,
        },

        options = {
          "-texlive",
        },
      }

      -- Keep Sioyek available as the normal PDF viewer
      vim.g.vimtex_view_method = "general"
      vim.g.vimtex_view_general_viewer = 'start ""'

      -- Launch Sioyek with forward and inverse SyncTeX support
      vim.g.vimtex_view_general_options =
        [[sioyek --inverse-search "nvim --headless -c \"VimtexInverseSearch %2 '%1'\"" --forward-search-file @tex --forward-search-line @line @pdf]]

      -- Keep the normal latexmk setup ready for Sioyek mode later
      vim.g.vimtex_compiler_latexmk_engines = {
        _ = "-xelatex",
      }
    end,
  },
}
