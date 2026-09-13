-- a-h/templ (.templ). Parsed by the `templ` treesitter parser, served by the
-- `templ` LSP (which proxies gopls for the Go half) plus htmx/tailwind/emmet.
local set = vim.opt_local

-- templ fmt uses tabs for the Go parts and indents markup by one tab too
set.expandtab = false
set.tabstop = 2
set.softtabstop = 2
set.shiftwidth = 2

set.commentstring = "// %s"
set.iskeyword:append "-"

-- templ's own LSP does not implement formatting for every version; conform is
-- configured to shell out to `templ fmt` instead (see lua/configs/conform.lua).
set.formatexpr = ""
