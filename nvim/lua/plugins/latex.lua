return {
    {
        "lervag/vimtex",
        lazy = false,
        init = function()
            vim.g.vimtex_view_method = "general"
            vim.g.vimtex_view_general_viewer = 'start ""'
            vim.g.vimtex_view_general_options =
                [[sioyek --inverse-search "nvim --headless -c \"VimtexInverseSearch %2 '%1'\"" --forward-search-file @tex --forward-search-line @line @pdf]]

            vim.g.vimtex_compiler_latexmk_engines = {
                _ = "-pdf",
            }
        end,
    },
}
