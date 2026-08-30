return {
  normal = {
    { "ff", "\\frac{$1}{$2}$0" },
    { "alp", "\\alpha" },
  },

  auto = {
    { "ooo", "\\infty" },
  },

  inword_auto = {
    { "sr", "^2" },
    { "cb", "^3" },
  },

  regex_auto = {
    { "(%a)(%d)", "%s_%s" },
    { "(%a)_(%d)(%d)", "%s_{%s%s}" },
    { "(%a)_{(%d+)}(%d)", "%s_{%s%s}" },
  },

  postfix_auto = {
    { "hat", "\\hat{%s}" },
    { "bar", "\\bar{%s}" },
    { "vec", "\\vec{%s}" },
  },
}
