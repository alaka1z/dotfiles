vim.lsp.enable("lua_ls")

vim.diagnostic.config({
  signs = {
    text = {
      [vim.diagnostic.severity.ERROR] = "",
      [vim.diagnostic.severity.WARN] = "",
      [vim.diagnostic.severity.INFO] = "",
      [vim.diagnostic.severity.HINT] = "󰌵",
    },
  },
  underline = true,
  virtual_text = false,
  severity_sort = true,
  float = {
    border = "rounded",
    source = true,
  },
})
