-- Go uses hard tabs. The global options (expandtab, 4 spaces) would fight
-- gofmt/gofumpt on every save, so override them here.
local set = vim.opt_local

set.expandtab = false
set.tabstop = 4
set.softtabstop = 4
set.shiftwidth = 4

-- gofmt doesn't wrap, but a marker at the conventional limit helps
set.colorcolumn = "120"

-- `gf` on an import path, and `:find` on a package name
set.path:append(vim.fn.expand "$GOPATH/src")
set.include = [[^\s*\%("\|`\)]]

-- treat _test.go as part of the same "file" for gf-style jumps
set.suffixesadd:prepend ".go"

local map = function(lhs, rhs, desc)
  vim.keymap.set("n", lhs, rhs, { buffer = 0, silent = false, desc = desc })
end

-- Build / run / vet the current package. Output lands in the quickfix list,
-- so `:cnext` walks the errors.
map("<leader>Gb", "<cmd>compiler go | make build ./...<cr>", "Go: build ./...")
map("<leader>Gv", "<cmd>compiler go | make vet ./...<cr>", "Go: vet ./...")
map("<leader>Gr", "<cmd>!go run .<cr>", "Go: run current package")

-- Jump between a file and its _test.go twin.
map("<leader>Ga", function()
  local file = vim.fn.expand "%:p"
  local alt = file:match "_test%.go$" and file:gsub("_test%.go$", ".go") or file:gsub("%.go$", "_test.go")
  vim.cmd.edit(vim.fn.fnameescape(alt))
end, "Go: alternate file (impl <-> test)")

vim.opt_local.formatoptions:remove "t" -- never hard-wrap code
vim.opt_local.formatoptions:append "cro" -- but do continue // comments
