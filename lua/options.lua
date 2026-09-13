require "nvchad.options"

-- add yours here! (ported from nvim-custom)

vim.opt.guicursor = "n-v-c:block,i:ver25"
vim.opt.relativenumber = true

vim.opt.tabstop = 4
vim.opt.softtabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true
vim.opt.autoindent = true
vim.opt.smartindent = true
vim.opt.wrap = false

vim.opt.swapfile = false
vim.opt.backup = false
vim.opt.undofile = true

vim.opt.incsearch = true
vim.opt.inccommand = "split"
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.hlsearch = true

vim.opt.scrolloff = 8
vim.opt.signcolumn = "yes"

vim.opt.backspace = { "start", "eol", "indent" }

vim.opt.splitright = true
vim.opt.splitbelow = true

vim.opt.isfname:append "@-@"
vim.opt.updatetime = 50

vim.opt.clipboard:append "unnamedplus"

vim.opt.mouse = "a"
vim.g.editorconfig = true
vim.g.netrw_banner = 0

-- Treat Go HTML template files as gohtmltmpl so the html-family LSP servers and
-- the gotmpl treesitter parser attach to them. (.templ is a-h/templ and is
-- detected by Neovim itself -- don't map it here.)
vim.filetype.add {
  extension = {
    tmpl = "gohtmltmpl",
    gohtml = "gohtmltmpl",
    gotmpl = "gotmpl",
  },
  filename = {
    [".golangci.yml"] = "yaml",
    [".golangci.yaml"] = "yaml",
  },
  pattern = {
    -- non-HTML Go templates (config files, SQL, k8s manifests, ...)
    [".*%.go%.tmpl"] = "gotmpl",
    [".*%.sql%.tmpl"] = "gotmpl",
    [".*%.ya?ml%.tmpl"] = "gotmpl",
  },
}
