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
          "html",
          "cssls",
          "tailwindcss",
          "gopls",
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
          "gofumpt",
          "mdformat",
          "markdown-toc",
          "markdownlint-cli2",
        },
      }
    end,
  },
}
