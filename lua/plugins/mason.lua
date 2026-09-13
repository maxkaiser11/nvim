-- Auto-install the LSP servers and tools max uses.
-- NvChad's own mason.nvim spec (the :Mason UI) is left untouched; these just add
-- the installer plugins on top of it.
return {
  {
    "williamboman/mason-lspconfig.nvim",
    event = "VeryLazy",
    dependencies = { "williamboman/mason.nvim" },
    config = function()
      require("mason-lspconfig").setup {
        -- servers are enabled explicitly in configs/lspconfig.lua
        automatic_enable = false,
        ensure_installed = {
          "lua_ls",
          "ts_ls",
          "clangd",
          "html",
          "cssls",
          "tailwindcss",
          -- NOTE: Mason's gopls is v0.23.0, which cannot analyse packages that
          -- import net/http under Go 1.27 (see configs/lspconfig.lua). It is
          -- kept here only as a fallback -- the config prefers $GOBIN/gopls.
          "gopls",
          "templ", -- a-h/templ: LSP + formatter, one binary
          "htmx", -- hx-* attribute completion
          "angularls",
          "astro",
          "emmet_ls",
          "emmet_language_server",
          "marksman",
          "svelte",
          "vue_ls",
        },
      }
    end,
  },
  {
    "WhoIsSethDaniel/mason-tool-installer.nvim",
    event = "VeryLazy",
    dependencies = { "williamboman/mason.nvim" },
    config = function()
      require("mason-tool-installer").setup {
        ensure_installed = {
          "prettier",
          "stylua",
          "isort",
          "pylint",
          "clangd",
          "biome",
          "mdformat",
          "markdown-toc",
          "markdownlint-cli2",

          -- Go toolchain
          "gofumpt", -- formatter (strict gofmt superset)
          "goimports", -- import management
          "golines", -- optional long-line wrapper
          "golangci-lint", -- aggregate linter, wired up in nvim-lint.lua
          "delve", -- debugger, wired up in go.lua
          "gomodifytags", -- struct tag add/remove (gopher.nvim)
          "impl", -- interface stub generation (gopher.nvim)
          "gotests", -- table-test generation (gopher.nvim)
        },
      }
    end,
  },
}
