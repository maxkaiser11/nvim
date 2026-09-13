-- Non-HTML Go templates (config files, SQL, k8s manifests). Same template
-- rules as gohtmltmpl, minus the markup-specific bits.
local set = vim.opt_local

set.expandtab = true
set.tabstop = 2
set.softtabstop = 2
set.shiftwidth = 2
set.commentstring = "{{/* %s */}}"
set.formatexpr = ""
set.indentexpr = ""

vim.keymap.set("i", "{{", "{{  }}<Left><Left><Left>", { buffer = 0, desc = "Insert {{ }} action" })
