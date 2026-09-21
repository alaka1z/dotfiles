return {
  normal = {
    { "ff", "\\frac{$1}{$2}$0" },
    { "alp", "\\alpha" },
  },

  auto = {
    { "ooo", "\\infty" },
    { "Re", "\\operatorname{Re}($1)$0" },
    { "Im", "\\operatorname{Im}($1)$0" },
    { "sq", "\\sqrt{$1}$0" },
    { "pi", "\\pi" },
    { "th", "\\theta" },
  },

  inword_auto = {
    { "=", " = " },
    { "+", " + " },
    { "sr", "^2" },
    { "cb", "^3" },
    { "abs", "\\left|$1\\right|$0" },
  },

  regex_auto = {
    { "(%a)(%d)", "%s_%s" },
    { "(%a)_(%d)(%d)", "%s_{%s%s}" },
    { "(%a)_{(%d+)}(%d)", "%s_{%s%s}" },
  },

  inword_regex_auto = {
    { "([NQRCZ])%1", "\\mathbb{%s}" },
    { "i([NQRCZ])", " \\in \\mathbb{%s}" },
  },

  postfix_auto = {
    { "-", "%s - " },

    { "hat", "\\hat{%s}" },
    { "bar", "\\bar{%s}" },
    { "vec", "\\vec{%s}" },
  },
}
