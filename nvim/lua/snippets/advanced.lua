local ls = require("luasnip")
local atom = require("snippets.atom")
local term = require("snippets.term")
local events = require("luasnip.util.events")

local s, sn = ls.snippet, ls.snippet_node
local t, i, d, f = ls.text_node, ls.insert_node, ls.dynamic_node, ls.function_node

local function in_mathzone()
  return vim.fn["vimtex#syntax#in_mathzone"]() == 1
end

local function matrix(_, parent)
  local rows = tonumber(parent.snippet.captures[1])
  local cols = tonumber(parent.snippet.captures[2])

  local nodes = {}
  local index = 1

  for row = 1, rows do
    for col = 1, cols do
      nodes[#nodes + 1] = i(index)
      index = index + 1

      if col < cols then
        nodes[#nodes + 1] = t(" & ")
      end
    end

    if row < rows then
      nodes[#nodes + 1] = t({ " \\\\", "  " })
    end
  end

  return sn(nil, nodes)
end

local function mathbb_capture(_, snip)
  return "\\mathbb{" .. snip.captures[1]:upper() .. "}"
end

local function after_brace(line_to_cursor)
  return line_to_cursor:sub(-3, -3) == "{"
end

local function euler_coefficient(_, snip)
  local sign = snip.captures[1] == "m" and "-" or ""
  local coefficient = snip.captures[2]

  return sign .. (coefficient == "1" and "" or coefficient)
end

local function optional_slash(args)
  local denominator = args[1][1]

  if denominator == "" or denominator:sub(1, 1) == "/" then
    return ""
  end

  return "/"
end


local function term_trigger(trigger)
  return function(line_to_cursor)
    if line_to_cursor:sub(-#trigger) ~= trigger then
      return nil
    end

    local before = line_to_cursor:sub(1, -#trigger - 1)
    local match = term.previous(before)

    if not match then
      return nil
    end

    return match .. trigger, { match }
  end
end

local function fraction_numerator(_, snip)
  local numerator = snip.captures[1]

  if numerator:sub(1, 1) == "("
    and numerator:sub(-1) == ")"
    and atom.previous(numerator) == numerator then
    return numerator:sub(2, -2)
  end

  return numerator
end

local function power_open(args)
  return args[1][1] == "" and "" or "^{"
end

local function power_close(args)
  return args[1][1] == "" and "" or "}"
end

local function powered_function(trigger, command)
  return s({
    trig = trigger,
    wordTrig = false,
    snippetType = "autosnippet",
    condition = in_mathzone,
  }, {
    t("\\" .. command),
    f(power_open, { 1 }),

    i(1, "", {
      node_callbacks = {
        [events.enter] = function(node)
          local snippet = node.parent.snippet or node.parent

          if not snippet.power_skipped then
            snippet.power_skipped = true

            vim.schedule(function()
              if ls.locally_jumpable(1) then
                ls.jump(1)
              end
            end)
          end
        end,
      },
    }),

    f(power_close, { 1 }),
    t("{"),
    i(2),
    t("}"),
    i(0),
  })
end

local function visual_content(_, snip)
  local selected = snip.env.LS_SELECT_RAW or {}

  if #selected == 0 then
    selected = vim.b.snippet_selection or {}
    vim.b.snippet_selection = nil
  end

  if #selected == 0 then
    return sn(nil, { i(1) })
  end

  local text = table.concat(selected, "\n")

  if text:sub(1, 1) == "("
    and text:sub(-1) == ")"
    and atom.previous(text) == text then
    text = text:sub(2, -2)
  end

  return sn(nil, { i(1, text) })
end

return {
  s({
    trig = "mat(%d+)(%d+)",
    trigEngine = "pattern",
    condition = in_mathzone,
  }, {
    t({ "\\begin{bmatrix}", "  " }),
    d(1, matrix, {}),
    t({ "", "\\end{bmatrix}" }),
  }),

  s({
    trig = "f([nqrcz])([nqrcz])",
    trigEngine = "pattern",
    snippetType = "autosnippet",
    condition = in_mathzone,
  }, {
    ls.function_node(function(_, snip)
      return string.format(
        "f : \\mathbb{%s} \\to \\mathbb{%s}",
        snip.captures[1]:upper(),
        snip.captures[2]:upper()
      )
    end),
  }),

  s({
    trig = "fto([nqrcz])",
    trigEngine = "pattern",
    snippetType = "autosnippet",
    condition = in_mathzone,
  }, {
    t("f : "),
    i(1),
    t(" \\to "),
    f(mathbb_capture, {}),
    t(" "),
    i(0),
  }),

  s({
    trig = "f([nqrcz])to",
    trigEngine = "pattern",
    snippetType = "autosnippet",
    condition = in_mathzone,
  }, {
    t("f : "),
    f(mathbb_capture, {}),
    t(" \\to "),
    i(0),
  }),

  -- Normal: fof → f($1)$0
  s({
    trig = "of",
    wordTrig = false,
    snippetType = "autosnippet",
    condition = function(line_to_cursor)
      return in_mathzone() and not after_brace(line_to_cursor)
    end,
  }, {
    t("("),
    i(1),
    t(")"),
    i(0),
  }),

  -- Nested: sin{of → sin{($0)}
  s({
    trig = "of",
    wordTrig = false,
    snippetType = "autosnippet",
    condition = function(line_to_cursor)
      return in_mathzone() and after_brace(line_to_cursor)
    end,
  }, {
    t("("),
    i(0),
    t(")"),
  }),

  s({
    trig = "e(m?)([1-9])",
    trigEngine = "pattern",
    wordTrig = false,
    snippetType = "autosnippet",
    priority = 2000,
    condition = in_mathzone,
  }, {
    t("e^{"),
    f(euler_coefficient, {}),
    t("i\\pi"),
    f(optional_slash, { 1 }),
    i(1),
    t("}"),
    i(0),
  }),

  s({
    trig = "/",
    trigEngine = term_trigger,
    wordTrig = false,
    snippetType = "autosnippet",
    condition = in_mathzone,
  }, {
    t("\\frac{"),
    f(fraction_numerator, {}),
    t("}{"),
    i(1),
    t("}"),
    i(0),
  }),

  powered_function("sin", "sin"),
  powered_function("cos", "cos"),
  powered_function("tan", "tan"),

  powered_function("sih", "sinh"),
  powered_function("coh", "cosh"),
  powered_function("tah", "tanh"),

  s({
    trig = "lrp",
    wordTrig = false,
    snippetType = "autosnippet",
    condition = in_mathzone,
  }, {
    t("\\left("),
    d(1, visual_content, {}),
    t("\\right)"),
    i(0),
  }),
}
