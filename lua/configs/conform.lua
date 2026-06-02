local options = {
  formatters = {
    ["markdown-toc"] = {
      condition = function(_, ctx)
        for _, line in ipairs(vim.api.nvim_buf_get_lines(ctx.buf, 0, -1, false)) do
          if line:find "<!%-%- toc %-%->" then
            return true
          end
        end
      end,
    },
    ["markdownlint-cli2"] = {
      condition = function(_, ctx)
        local diag = vim.tbl_filter(function(d)
          return d.source == "markdownlint"
        end, vim.diagnostic.get(ctx.buf))
        return #diag > 0
      end,
    },
    prettier = {
      args = {
        "--stdin-filepath",
        "$FILENAME",
        "--tab-width",
        "4",
        "--use-tabs",
        "false",
      },
    },
    shfmt = {
      prepend_args = { "-i", "4" },
    },
  },

  formatters_by_ft = {
    javascript = { "biome-check" },
    typescript = { "biome-check" },
    javascriptreact = { "biome-check" },
    typescriptreact = { "biome-check" },
    css = { "biome-check" },
    html = { "prettier" },
    svelte = { "prettier" },
    json = { "biome-check" },
    yaml = { "prettier" },
    graphql = { "prettier" },
    liquid = { "prettier" },
    lua = { "stylua" },
    go = { "gofumpt" },
    markdown = { "mdformat", "markdown-toc" },
  },

  format_on_save = {
    lsp_fallback = true,
    async = false,
    timeout_ms = 1000,
  },
}

return options
