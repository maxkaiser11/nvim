-- Go html/template (.tmpl, .gohtml).
--
-- The buffer is parsed by the `gotmpl` treesitter parser, with `html` injected
-- into the text between {{ }} actions (see queries/gotmpl/injections.scm).
-- LSP: go_template_lsp (action/variable correctness) + html, htmx, tailwindcss
-- and emmet for the markup (see lua/configs/lspconfig.lua).
local set = vim.opt_local

-- markup convention, not Go's tabs
set.expandtab = true
set.tabstop = 2
set.softtabstop = 2
set.shiftwidth = 2

-- `gc` comments the template way, not the HTML way — an HTML comment around a
-- {{ }} action still executes the action, which is almost never what you want.
set.commentstring = "{{/* %s */}}"

-- let % jump between {{ and }} as well as between tags
set.matchpairs:append "<:>"

-- there is no safe formatter for html/template (prettier rewrites {{ }} into
-- invalid syntax), so `=` should fall back to plain indent rather than formatexpr
set.formatexpr = ""
set.indentexpr = ""

-- `-` isn't a word boundary in class names / hx-attributes
set.iskeyword:append "-"

local map = function(mode, lhs, rhs, desc)
  vim.keymap.set(mode, lhs, rhs, { buffer = 0, desc = desc })
end

-- Insert the template constructs you type all day. These fire only in .tmpl
-- buffers, so they don't shadow anything globally.
map("i", "{{", "{{  }}<Left><Left><Left>", "Insert {{ }} action")
map("n", "<leader>Gi", [[o{{ if . }}<CR>{{ end }}<Esc>]], "Template: if block")
map("n", "<leader>Gn", [[o{{ range . }}<CR>{{ end }}<Esc>]], "Template: range block")
map("n", "<leader>Gd", [[o{{ define "" }}<CR>{{ end }}<Esc>]], "Template: define block")

-- Which struct is this template rendered with? go_template_lsp answers hover
-- on {{ .Field }}; K is already mapped to vim.lsp.buf.hover by LspAttach.
