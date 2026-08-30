local ls = require("luasnip")

local parse = ls.parser.parse_snippet
local postfix = require("luasnip.extras.postfix").postfix

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
  }), body)
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

function M.postfix_auto(trigger, format, opts)
  return postfix(vim.tbl_extend("force", opts or {}, {
    trig = trigger,
    snippetType = "autosnippet",
  }), {
    ls.function_node(function(_, parent)
      return string.format(format, parent.snippet.env.POSTFIX_MATCH)
    end, {}),
  })
end

return M
