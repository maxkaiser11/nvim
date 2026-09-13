-- Leaving a filetype out of formatters_by_ft is not enough to leave it alone:
-- `lsp_format = "fallback"` would then hand the buffer to whatever LSP claims to
-- format it. For Go templates that is vscode-html-language-server, which does
-- not understand {{ }} and flattens the indentation of every if/range block on
-- save. Skip these filetypes outright.
local no_format = { gohtmltmpl = true, gotmpl = true }

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
    -- wraps long Go lines that gofumpt leaves alone; only used on demand
    golines = {
      prepend_args = { "--max-len=120", "--base-formatter=gofumpt" },
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

    -- Go: goimports first (adds/removes/groups imports), then gofumpt -- the
    -- strict superset of gofmt that gopls is also configured to use.
    go = { "goimports", "gofumpt" },
    gomod = { "gofmt" },
    gowork = { "gofmt" },

    -- a-h/templ ships its own formatter; nothing else understands .templ.
    templ = { "templ" },

    -- NOTE: gohtmltmpl / gotmpl are deliberately absent. prettier reflows
    -- {{ ... }} actions into invalid template syntax, and there is no safe
    -- html/template formatter. Indent these by hand (or with `=`).

    markdown = { "mdformat", "markdown-toc" },
  },

  format_on_save = function(bufnr)
    -- escape hatch: :FormatDisable (buffer) / :FormatDisable! (global)
    if vim.g.disable_autoformat or vim.b[bufnr].disable_autoformat then
      return
    end
    if no_format[vim.bo[bufnr].filetype] then
      return
    end
    return {
      lsp_format = "fallback",
      async = false,
      -- goimports against a cold module can take well over a second
      timeout_ms = 3000,
    }
  end,
}

return options
