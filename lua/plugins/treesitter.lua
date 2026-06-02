-- Extend NvChad's nvim-treesitter with the parsers max uses.
return {
  "nvim-treesitter/nvim-treesitter",
  opts = function(_, opts)
    opts.ensure_installed = opts.ensure_installed or {}
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
