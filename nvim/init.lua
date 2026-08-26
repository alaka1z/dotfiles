local options = {
  -- Appearance
  number = true,
  relativenumber = true,
  cursorline = true,
  cursorlineopt = "both",
  signcolumn = "yes", -- Keep the gutter visible

  -- Editing
  undofile = true, -- Persist undo history between sessions
  clipboard = "unnamedplus", -- Use the Windows system clipboard

  -- Search
  ignorecase = true,
  smartcase = true,

  -- Windows
  splitright = true,
  splitbelow = true,

  -- Display
  linebreak = true,
  breakindent = true,
  scrolloff = 5,

  -- Indentation
  tabstop = 2,
  shiftwidth = 2,
  softtabstop = 2,
  expandtab = true, -- Use spaces instead of literal tab characters
}

for key, value in pairs(options) do
  vim.opt[key] = value
end
