return {
  normal = {
    { "alp", "\\alpha" },
    { "fto", "f : $1 \\to $0" },
  },

  auto = {
  },

  inword_auto = {
    { "=", " = " },
    { "+", " + " },
    { ">", " > " },
    { "<", " < " },
    { "pm", " \\pm " },
    { "abs", "\\left|$1\\right|$0" },
    { "sin", "\\sin{$1}$0" },
    { "cos", "\\cos{$1}$0" },
    { "tan", "\\tan{$1}$0" },
    { "sih", "\\sinh{$1}$0" },
    { "coh", "\\cosh{$1}$0" },
    { "tah", "\\tanh{$1}$0" },
    { "exp", "\\exp{$1}$0" },
    { "ln", "\\ln{$1}$0" },
    { "arg", "\\arg{$1}$0" },
    { "Arg", "\\operatorname{Arg}($1)$0" },
    { "ooo", "\\infty" },
    { "Re", "\\operatorname{Re}($1)$0" },
    { "Im", "\\operatorname{Im}($1)$0" },
    { "sq", "\\sqrt{$1}$0" },
    { "pi", "\\pi" },
    { "th", "\\theta" },
    { "ff", "\\frac{$1}{$2}$0" },
  },

  regex_auto = {
    { "(%a)(%d)", "%s_%s" },
    { "(%a)_(%d)(%d)", "%s_{%s%s}" },
    { "(%a)_{(%d+)}(%d)", "%s_{%s%s}" },
  },

  inword_regex_auto = {
    { "([NQRCZ])%1", "\\mathbb{%s}" },
  },

  atom_auto = {
  { "-", " - " },

  { "sr", "^2" },
  { "cb", "^3" },
  { "tp", "^{$1}$0" },
  { "sb", "_{$1}$0" },

  { "ii", " \\in " },
  { "iN", " \\in \\mathbb{N}" },
  { "iQ", " \\in \\mathbb{Q}" },
  { "iR", " \\in \\mathbb{R}" },
  { "iC", " \\in \\mathbb{C}" },
  { "iZ", " \\in \\mathbb{Z}" },
  { "ni", " \\notin " },
  { "ss", " \\subseteq " },
  { "cap", " \\cap " },
  { "cup", " \\cup " },
  { "wo", " \\setminus " },

  { "ne", " \\neq " },
  { "le", " \\le " },
  { "ge", " \\ge " },
  },

  postfix_auto = {
    { "hat", "\\hat{%s}" },
    { "bar", "\\bar{%s}" },
    { "vec", "\\vec{%s}" },
  },
}
