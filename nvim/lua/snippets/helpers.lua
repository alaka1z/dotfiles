local ls = require("luasnip")
local atom = require("snippets.atom")

local parse = ls.parser.parse_snippet
-- local postfix = require("luasnip.extras.postfix").postfix

local function atom_trigger(trigger)
  return function(line_to_cursor)
    if line_to_cursor:sub(-#trigger) ~= trigger then
      return nil
    end

    local before =
      line_to_cursor:sub(1, #line_to_cursor - #trigger)

    local match = atom.previous(before)

    if not match then
      return nil
    end

    return match .. trigger, { match }
  end
end

local M = {}

function M.normal(trigger, body, opts)
  return parse(vim.tbl_extend("force", opts or {}, {
    trig = trigger,
  }), body)
end

function M.auto(trigger, body, opts)
  return parse(vim.tbl_extend("force", opts or {}, {
    trig = trigger,
    snippetType = "autosnippet",
  }), body)
end

function M.inword_auto(trigger, body, opts)
  return parse(vim.tbl_extend("force", opts or {}, {
    trig = trigger,
    wordTrig = false,
    snippetType = "autosnippet",
  }), body, {
    dedent = false,
  })
end

function M.regex_auto(trigger, format, opts)
  return ls.snippet(vim.tbl_extend("force", opts or {}, {
    trig = trigger,
    trigEngine = "pattern",
    snippetType = "autosnippet",
  }), {
    ls.function_node(function(_, snip)
      return string.format(format, unpack(snip.captures))
    end),
  })
end

function M.inword_regex_auto(trigger, format, opts)
  return ls.snippet(vim.tbl_extend("force", opts or {}, {
    trig = trigger,
    trigEngine = "pattern",
    wordTrig = false,
    snippetType = "autosnippet",
  }), {
    ls.function_node(function(_, snip)
      return string.format(format, unpack(snip.captures))
    end),
  })
end

-- Use our own definition of atom
function M.postfix_auto(trigger, format, opts)
  return ls.snippet(vim.tbl_extend("force", opts or {}, {
    trig = trigger,
    trigEngine = atom_trigger,
    wordTrig = false,
    snippetType = "autosnippet",
  }), {
    ls.function_node(function(_, snip)
      return string.format(format, snip.captures[1])
    end, {}),
  })
end



return M
