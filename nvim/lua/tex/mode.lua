local M = {}

local function compiler_for_mode()
  return vim.g.latex_viewer_mode == "texpresso"
      and "texpresso"
      or "latexmk"
end

function M.view()
  if vim.g.latex_viewer_mode == "sioyek" then
    vim.cmd("VimtexView")
    return
  end

  if vim.fn.eval("b:vimtex.compiler.is_running()") == 0 then
    vim.notify("TeXpresso is not running", vim.log.levels.WARN)
    return
  end

  vim.cmd([[
    call b:vimtex.compiler.texpresso_send(
      \ "synctex-forward",
      \ b:vimtex.compiler.texpresso_path(expand("%:p")),
      \ line(".")
      \ )
  ]])
end

function M.toggle_texpresso_follow()
  vim.cmd("call b:vimtex.compiler.texpresso_synctex_forward_toggle()")
end

function M.toggle_texpresso_titlebar()
  vim.system({
    "pwsh.exe",
    "-NoProfile",
    "-File",
    vim.fn.expand("~/.config/texpresso/texpresso-toggle-titlebar.ps1"),
  })
end

-- Build the conventional PDF from disk without affecting TeXpresso
function M.build_sioyek_pdf()
  local tex = vim.b.vimtex.tex
  local cwd = vim.fn.fnamemodify(tex, ":h")
  local filename = vim.fn.fnamemodify(tex, ":t")

  vim.system({
    "latexmk",
    "-xelatex",
    "-synctex=1",
    filename,
  }, {
    cwd = cwd,
  }, function(result)
    if result.code ~= 0 then
      vim.schedule(function()
        vim.notify("XeLaTeX build failed", vim.log.levels.ERROR)
      end)
    end
  end)
end

-- Keep VimTeX's per-buffer compiler aligned with the global LaTeX mode
function M.sync()
  if not vim.b.vimtex or not vim.b.vimtex.compiler then
    return
  end

  local expected_compiler = compiler_for_mode()

  if vim.b.vimtex.compiler.name ~= expected_compiler then
    local previous_compiler = vim.b.vimtex.compiler.name

    if vim.fn.eval("b:vimtex.compiler.is_running()") == 1 then
      vim.cmd("VimtexStop")
    end

    if previous_compiler == "texpresso" then
      vim.cmd("call b:vimtex.compiler.texpresso_cleanup()")
    end

    vim.g.vimtex_compiler_method = expected_compiler
    vim.cmd("VimtexReload")
  end
end

function M.switch()
  vim.g.latex_viewer_mode =
    vim.g.latex_viewer_mode == "sioyek"
      and "texpresso"
      or "sioyek"

  vim.g.vimtex_compiler_method = compiler_for_mode()

  M.sync()

  vim.notify("LaTeX mode: " .. vim.g.latex_viewer_mode)
end

return M
