local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"

-- Install lazy.nvim automatically if it is not already available
if not vim.uv.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "--branch=stable",
    "https://github.com/folke/lazy.nvim.git",
    lazypath,
  })
end

-- Add lazy.nvim to Neovim's runtime path before loading plugin specs
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
  { import = "plugins" },
})
