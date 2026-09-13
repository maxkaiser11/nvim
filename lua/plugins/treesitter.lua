-- Extend NvChad's nvim-treesitter with the parsers max uses.
return {
  "nvim-treesitter/nvim-treesitter",
  branch = "master",
  build = ":TSUpdate",
  opts = function(_, opts)
    opts.ensure_installed = opts.ensure_installed or {}
    opts.auto_install = true
    vim.list_extend(opts.ensure_installed, {
      "json",
      "javascript",
      "typescript",
      "tsx",
      "go",
      "yaml",
      "html",
      "css",
      "python",
      "prisma",
      "markdown",
      "markdown_inline",
      "svelte",
      "graphql",
      "bash",
      "lua",
      "vim",
      "dockerfile",
      "gitignore",
      "query",
      "vimdoc",
      "c",
      "java",
      "rust",
      "ron",
      -- Go
      "go",
      "gomod",
      "gosum",
      "gowork",
      "gotmpl",
      "templ",
    })

    -- The .tmpl/.gohtml filetypes use the `gotmpl` parser; queries/gotmpl/
    -- injections.scm then injects `html` into the text regions between actions.
    vim.treesitter.language.register("gotmpl", "gohtmltmpl")

    -- Indentation for Go templates: the gotmpl parser has no indent queries, so
    -- treesitter indent would flatten everything. Keep it off for those.
    opts.indent = vim.tbl_deep_extend("force", opts.indent or {}, {
      enable = true,
      disable = { "gohtmltmpl", "gotmpl" },
    })

    opts.incremental_selection = {
      enable = true,
      keymaps = {
        init_selection = "<C-space>",
        node_incremental = "<C-space>",
        node_decremental = "<C-backspace>",
      },
    }

    return opts
  end,
}
