return {
  "mfussenegger/nvim-lint",
  event = { "BufReadPre", "BufNewFile" },
  config = function()
    local lint = require "lint"

    lint.linters_by_ft = {
      javascript = { "biomejs" },
      typescript = { "biomejs" },
      javascriptreact = { "biomejs" },
      typescriptreact = { "biomejs" },
      svelte = { "biomejs" },
      python = { "pylint" },
      -- golangci-lint runs the whole package, so it is far too slow for
      -- BufEnter/InsertLeave -- it is triggered on write only (see below).
      go = { "golangcilint" },
    }

    local eslint = lint.linters.eslint_d
    eslint.args = {
      "--no-warn-ignored",
      "--format",
      "json",
      "--stdin",
      "--stdin-filename",
      function()
        return vim.fn.expand "%:p"
      end,
    }

    -- golangci-lint shells out to the Go toolchain and analyses the entire
    -- package; running it on every InsertLeave locks the editor up on anything
    -- larger than a toy module.
    local write_only = { go = true }

    local lint_augroup = vim.api.nvim_create_augroup("lint", { clear = true })
    vim.api.nvim_create_autocmd({ "BufEnter", "BufWritePost", "InsertLeave" }, {
      group = lint_augroup,
      callback = function(ev)
        if write_only[vim.bo[ev.buf].filetype] and ev.event ~= "BufWritePost" then
          return
        end
        lint.try_lint()
      end,
    })

    vim.keymap.set("n", "<leader>li", function()
      lint.try_lint()
    end, { desc = "Trigger linting for current file" })
  end,
}
