local map = vim.keymap.set
local opt = vim.opt_local

-- Enable spell checking only while editing TeX
opt.spell = true

-- opt.conceallevel = 2
-- opt.concealcursor = "nc"

local function compiler_for_mode()
  return vim.g.latex_viewer_mode == "texpresso"
      and "texpresso"
      or "latexmk"
end

local function view()
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

local function toggle_texpresso_follow()
  vim.cmd("call b:vimtex.compiler.texpresso_synctex_forward_toggle()")
end

local function toggle_texpresso_titlebar()
  vim.system({
    "pwsh.exe",
    "-NoProfile",
    "-File",
    vim.fn.expand("~/.config/texpresso/texpresso-toggle-titlebar.ps1"),
  })
end

-- Build the conventional PDF from disk without affecting TeXpresso
local function build_sioyek_pdf()
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


local texlive = "/home/alaka/texlive/2026"
local tlmgr = texlive .. "/bin/x86_64-linux/tlmgr"

-- Open a TeX picker with descriptions aligned to the right
local function tex_picker(items, prompt, action)
  local picker_width

  local hl = vim.api.nvim_get_hl(0, {
    name = "FzfLuaFzfInfo",
    link = false,
  })

  local info_color = ""

  if hl.fg then
    local r = math.floor(hl.fg / 0x10000) % 0x100
    local g = math.floor(hl.fg / 0x100) % 0x100
    local b = hl.fg % 0x100

    info_color = string.format("\27[38;2;%d;%d;%dm", r, g, b)
  end

  local reset = info_color ~= "" and "\27[0m" or ""

  local names = vim.tbl_keys(items)

  table.sort(names, function(a, b)
    return a:lower() < b:lower()
  end)

  local function truncate(text, width)
    if vim.fn.strdisplaywidth(text) <= width then
      return text
    end

    return vim.fn.strcharpart(text, 0, math.max(width - 1, 0)) .. "…"
  end

  local contents = function(fzf_cb)
    local width = picker_width - 4

    for _, name in ipairs(names) do
      local description = items[name]

      if description == "" then
        fzf_cb(name)
      else
        local name_width = vim.fn.strdisplaywidth(name)
        local max_description = width - name_width - 2

        if max_description <= 0 then
          fzf_cb(name)
        else
          local short = truncate(description, max_description)

          local padding =
            width
            - name_width
            - vim.fn.strdisplaywidth(short)

          fzf_cb(
            name
            .. string.rep(" ", math.max(padding, 2))
            .. info_color
            .. short
            .. reset
          )
        end
      end
    end

    fzf_cb()
  end

  require("fzf-lua").fzf_exec(contents, {
    prompt = prompt,

    winopts = {
      on_create = function(event)
        picker_width = vim.api.nvim_win_get_width(event.winid)
      end,
    },

    actions = {
      ["default"] = function(selected)
        local name = selected[1] and selected[1]:match("^%S+")

        if name then
          action(name)
        end
      end,
    },
  })
end

-- Browse installed TeX packages and insert the selected package
local function tex_packages()
  local function read_wsl_file(path)
    local lines = vim.fn.systemlist({
      "wsl.exe",
      "-d",
      "Ubuntu-24.04",
      "--",
      "cat",
      path,
    })

    if vim.v.shell_error ~= 0 then
      return nil
    end

    return lines
  end

  local package_lines =
    read_wsl_file(texlive .. "/tlpkg/texlive.tlpdb")

  local catalogue_lines =
    read_wsl_file(texlive .. "/tlpkg/texlive-catalogue-only.tlpdb")

  if not package_lines or not catalogue_lines then
    vim.notify("Failed to read TeX Live package data", vim.log.levels.ERROR)
    return
  end

  local descriptions = {}
  local tl_package

  for _, line in ipairs(catalogue_lines) do
    local name = line:match("^name (.+)$")

    if name then
      tl_package = name
    elseif tl_package then
      local short = line:match("^shortdesc (.+)$")

      if short then
        descriptions[tl_package] = short
      end
    end
  end

  local styles = {}
  tl_package = nil
  local in_runfiles = false

  for _, line in ipairs(package_lines) do
    local name = line:match("^name (.+)$")

    if name then
      tl_package = name
      in_runfiles = false
    elseif line:match("^runfiles ") then
      in_runfiles = true
    elseif line:match("^%S") then
      in_runfiles = false
    elseif in_runfiles and tl_package then
      local style = line:match("/([^/]+)%.sty$")

      if style and not styles[style] then
        styles[style] = descriptions[tl_package] or ""
      end
    end
  end

  tex_picker(styles, "TeX Packages> ", function(style)
    local row = vim.api.nvim_win_get_cursor(0)[1]
    local blank = vim.api.nvim_get_current_line():match("^%s*$")
    local index = blank and row - 1 or row

    vim.api.nvim_buf_set_lines(
      0,
      index,
      blank and row or index,
      false,
      { "\\usepackage{" .. style .. "}", "" }
    )

    vim.api.nvim_win_set_cursor(0, { index + 2, 0 })
  end)
end

-- Browse and install available TeX packages
local function tex_install()
  local function parse_csv(line)
    local fields = {}
    local field = {}
    local quoted = false
    local i = 1

    while i <= #line do
      local char = line:sub(i, i)

      if quoted then
        if char == "\\" and line:sub(i + 1, i + 1) == '"' then
          field[#field + 1] = '"'
          i = i + 2
        elseif char == '"' then
          if line:sub(i + 1, i + 1) == '"' then
            field[#field + 1] = '"'
            i = i + 2
          else
            quoted = false
            i = i + 1
          end
        else
          field[#field + 1] = char
          i = i + 1
        end
      elseif char == '"' and #field == 0 then
        quoted = true
        i = i + 1
      elseif char == "," then
        fields[#fields + 1] = table.concat(field)
        field = {}
        i = i + 1
      else
        field[#field + 1] = char
        i = i + 1
      end
    end

    fields[#fields + 1] = table.concat(field)

    return fields
  end

  vim.notify("Loading TeX packages...")

  vim.system({
    "wsl.exe",
    "-d",
    "Ubuntu-24.04",
    "--",
    tlmgr,
    "info",
    "--data",
    "name,category,shortdesc,installed",
  }, { text = true }, function(result)
    vim.schedule(function()
      if result.code ~= 0 then
        vim.notify(
          "Failed to load TeX packages",
          vim.log.levels.ERROR
        )
        return
      end

      local packages = {}

      for line in (result.stdout or ""):gmatch("[^\r\n]+") do
        local fields = parse_csv(line)

        local name = fields[1]
        local category = fields[2]
        local description = fields[3]
        local installed = fields[4]

        if category == "Package" and installed == "0" then
          packages[name] = (description or ""):gsub("\t", " ")
        end
      end

      tex_picker(packages, "TeX Install> ", function(package)
        vim.api.nvim_create_autocmd("SafeState", {
          once = true,

          callback = function()
            vim.notify("Installing " .. package .. "...")

            vim.system({
              "wsl.exe",
              "-d",
              "Ubuntu-24.04",
              "--",
              tlmgr,
              "install",
              package,
            }, { text = true }, function(install_result)
              vim.schedule(function()
                if install_result.code == 0 then
                  vim.notify("Installed " .. package)
                  return
                end

                local output = vim.trim(
                  (install_result.stdout or "")
                  .. "\n"
                  .. (install_result.stderr or "")
                )

                vim.notify(
                  "Failed to install "
                  .. package
                  .. (output ~= "" and "\n" .. output or ""),
                  vim.log.levels.ERROR
                )
              end)
            end)
          end,
        })
      end)
    end)
  end)
end

-- Add TeXpresso-only mappings so they reflect the active mode in Which-Key
local function set_mode_mappings()
  pcall(vim.keymap.del, "n", "<leader>tf", { buffer = true })
  pcall(vim.keymap.del, "n", "<leader>tt", { buffer = true })
  pcall(vim.keymap.del, "n", "<leader>tsb", { buffer = true })
  pcall(vim.keymap.del, "n", "<leader>tsv", { buffer = true })

  if vim.g.latex_viewer_mode ~= "texpresso" then
    return
  end

  map("n", "<leader>tf", toggle_texpresso_follow, {
    buffer = true,
    desc = "Toggle TeXpresso follow",
  })

  map("n", "<leader>tt", toggle_texpresso_titlebar, {
    buffer = true,
    desc = "Toggle TeXpresso titlebar",
  })

  map("n", "<leader>tsb", build_sioyek_pdf, {
    buffer = true,
    desc = "Build PDF with Sioyek",
  })

  map("n", "<leader>tsv", "<cmd>VimtexView<cr>", {
    buffer = true,
    desc = "View in Sioyek",
  })
end

-- Keep VimTeX's per-buffer compiler aligned with the global LaTeX mode
local function sync_mode()
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

  set_mode_mappings()
end

local function switch_mode()
  vim.g.latex_viewer_mode =
    vim.g.latex_viewer_mode == "sioyek"
      and "texpresso"
      or "sioyek"

  vim.g.vimtex_compiler_method = compiler_for_mode()

  sync_mode()

  vim.notify("LaTeX mode: " .. vim.g.latex_viewer_mode)
end

-- Frequently used VimTeX actions
map("n", "<leader>b", "<cmd>VimtexCompile<cr>", {
  buffer = true,
  desc = "Compile",
})

map("n", "<leader>v", view, {
  buffer = true,
  desc = "View",
})

-- Less frequent VimTeX actions
map("n", "<leader>te", "<cmd>VimtexErrors<cr>", {
  buffer = true,
  desc = "Errors",
})

map("n", "<leader>tx", "<cmd>VimtexClean<cr>", {
  buffer = true,
  desc = "Clean",
})

map("n", "<leader>tc", "<cmd>VimtexTocOpen<cr>", {
  buffer = true,
  desc = "Table of contents",
})

map("n", "<leader>tm", switch_mode, {
  buffer = true,
  desc = "Switch TeX mode",
})

map("n", "<leader>tp", tex_packages, {
  buffer = true,
  desc = "TeX packages",
})

map("n", "<leader>ti", tex_install, {
  buffer = true,
  desc = "Install TeX package",
})

-- Synchronize each TeX project lazily when returning to its buffer
vim.api.nvim_create_autocmd("BufEnter", {
  buffer = vim.api.nvim_get_current_buf(),
  callback = sync_mode,
})

set_mode_mappings()
