local M = {}

local distro = "Ubuntu-24.04"
local texlive = "/home/alaka/texlive/2026"
local tlmgr = texlive .. "/bin/x86_64-linux/tlmgr"

local function wsl_command(...)
  return vim.list_extend(
    { "wsl.exe", "-d", distro, "--" },
    { ... }
  )
end

local function read_wsl_file(path)
  local lines = vim.fn.systemlist(wsl_command("cat", path))

  if vim.v.shell_error ~= 0 then
    return nil
  end

  return lines
end

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

local function truncate(text, width)
  if vim.fn.strdisplaywidth(text) <= width then
    return text
  end

  return vim.fn.strcharpart(text, 0, math.max(width - 1, 0)) .. "…"
end

-- Open a TeX picker with descriptions aligned to the right
local function tex_picker(items, prompt, action)
  local picker_width
  local info_color = ""
  local reset = ""
  local names = vim.tbl_keys(items)

  table.sort(names, function(a, b)
    return a:lower() < b:lower()
  end)

  local function contents(fzf_cb)
    local width = picker_width - 4

    for _, name in ipairs(names) do
      local description = items[name]
      local name_width = vim.fn.strdisplaywidth(name)
      local max_description = width - name_width - 2

      if description == "" or max_description <= 0 then
        fzf_cb(name)
      else
        local short = truncate(description, max_description)
        local padding = width - name_width - vim.fn.strdisplaywidth(short)

        fzf_cb(
          name
          .. string.rep(" ", math.max(padding, 2))
          .. info_color
          .. short
          .. reset
        )
      end
    end

    fzf_cb()
  end

  require("fzf-lua").fzf_exec(contents, {
    prompt = prompt,

    winopts = {
      on_create = function(event)
        picker_width = vim.api.nvim_win_get_width(event.winid)

        local hl = vim.api.nvim_get_hl(0, {
          name = "FzfLuaFzfInfo",
          link = false,
        })

        local fg = hl.fg

        if fg then
          info_color = string.format(
            "\27[38;2;%d;%d;%dm",
            math.floor(fg / 0x10000) % 0x100,
            math.floor(fg / 0x100) % 0x100,
            fg % 0x100
          )

          reset = "\27[0m"
        end
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

local function catalogue_descriptions(lines)
  local descriptions = {}
  local package_name

  for _, line in ipairs(lines) do
    local name = line:match("^name (.+)$")

    if name then
      package_name = name
    elseif package_name then
      local description = line:match("^shortdesc (.+)$")

      if description then
        descriptions[package_name] = description
      end
    end
  end

  return descriptions
end

local function installed_styles(lines, descriptions)
  local styles = {}
  local package_name
  local in_runfiles = false

  for _, line in ipairs(lines) do
    local name = line:match("^name (.+)$")

    if name then
      package_name = name
      in_runfiles = false
    elseif line:match("^runfiles ") then
      in_runfiles = true
    elseif line:match("^%S") then
      in_runfiles = false
    elseif in_runfiles and package_name then
      local style = line:match("/([^/]+)%.sty$")

      if style and not styles[style] then
        styles[style] = descriptions[package_name] or ""
      end
    end
  end

  return styles
end

local function load_installed_styles()
  local package_lines =
    read_wsl_file(texlive .. "/tlpkg/texlive.tlpdb")

  local catalogue_lines =
    read_wsl_file(texlive .. "/tlpkg/texlive-catalogue-only.tlpdb")

  if not package_lines or not catalogue_lines then
    return nil
  end

  local descriptions = catalogue_descriptions(catalogue_lines)

  return installed_styles(package_lines, descriptions)
end

local function insert_package(style)
  local row = vim.api.nvim_win_get_cursor(0)[1]
  local blank = vim.api.nvim_get_current_line():match("^%s*$")
  local index = blank and row - 1 or row

  vim.api.nvim_buf_set_lines(
    0,
    index,
    row,
    false,
    { "\\usepackage{" .. style .. "}", "" }
  )

  vim.api.nvim_win_set_cursor(0, { index + 2, 0 })
end

local function available_packages(output)
  local packages = {}

  for line in output:gmatch("[^\r\n]+") do
    local fields = parse_csv(line)

    local name = fields[1]
    local category = fields[2]
    local description = fields[3]
    local installed = fields[4]

    if category == "Package" and installed == "0" then
      packages[name] = (description or ""):gsub("\t", " ")
    end
  end

  return packages
end

local function install_package(package_name)
  vim.api.nvim_create_autocmd("SafeState", {
    once = true,

    callback = function()
      vim.notify("Installing " .. package_name .. "...")

      vim.system(
        wsl_command(tlmgr, "install", package_name),
        { text = true },
        vim.schedule_wrap(function(result)
          if result.code == 0 then
            vim.notify("Installed " .. package_name)
            return
          end

          local output = vim.trim(
            (result.stdout or "")
              .. "\n"
              .. (result.stderr or "")
          )

          vim.notify(
            "Failed to install "
              .. package_name
              .. (output ~= "" and "\n" .. output or ""),
            vim.log.levels.ERROR
          )
        end)
      )
    end,
  })
end

-- Browse installed TeX packages and insert the selected package
function M.pick()
  local styles = load_installed_styles()

  if not styles then
    vim.notify("Failed to read TeX Live package data", vim.log.levels.ERROR)
    return
  end

  tex_picker(styles, "TeX Packages> ", insert_package)
end

-- Browse and install available TeX packages
function M.install()
  vim.notify("Loading TeX packages...")

  vim.system(
    wsl_command(
      tlmgr,
      "info",
      "--data",
      "name,category,shortdesc,installed"
    ),
    { text = true },
    vim.schedule_wrap(function(result)
      if result.code ~= 0 then
        vim.notify("Failed to load TeX packages", vim.log.levels.ERROR)
        return
      end

      local packages = available_packages(result.stdout or "")

      tex_picker(packages, "TeX Install> ", install_package)
    end)
  )
end

return M
