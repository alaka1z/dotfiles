return {
    {
        "lervag/vimtex",
        lazy = false,
        init = function()
            vim.g.vimtex_callback_progpath = "nvim"
            vim.g.vimtex_view_method = "sioyek"
            vim.g.vimtex_compiler_latexmk_engines = {
                _ = "-lualatex",
            }
        end,
    },
}
