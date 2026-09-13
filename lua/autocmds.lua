require "nvchad.autocmds"

-- Highlight on yank (ported from nvim-custom)
vim.api.nvim_create_autocmd("TextYankPost", {
  desc = "Highlight when yanking (copying) text",
  group = vim.api.nvim_create_augroup("highlight-yank", { clear = true }),
  callback = function()
    vim.hl.on_yank()
  end,
})

-- ---------------------------------------------------------------------------
-- Format-on-save escape hatch (see lua/configs/conform.lua)
--   :FormatDisable   — this buffer only
--   :FormatDisable!  — globally, for the session
--   :FormatEnable    — re-enable both
-- ---------------------------------------------------------------------------
vim.api.nvim_create_user_command("FormatDisable", function(args)
  if args.bang then
    vim.g.disable_autoformat = true
    vim.notify "Format-on-save disabled globally"
  else
    vim.b.disable_autoformat = true
    vim.notify "Format-on-save disabled for this buffer"
  end
end, { desc = "Disable format-on-save", bang = true })

vim.api.nvim_create_user_command("FormatEnable", function()
  vim.b.disable_autoformat = false
  vim.g.disable_autoformat = false
  vim.notify "Format-on-save enabled"
end, { desc = "Re-enable format-on-save" })

-- ---------------------------------------------------------------------------
-- Go: `go run`/`go build` output into the quickfix list via :make
-- ---------------------------------------------------------------------------
vim.api.nvim_create_autocmd("FileType", {
  group = vim.api.nvim_create_augroup("go-makeprg", { clear = true }),
  pattern = { "go", "gomod" },
  callback = function(ev)
    vim.bo[ev.buf].makeprg = "go"
    -- `go build` reports `file.go:12:5: message`
    vim.bo[ev.buf].errorformat = table.concat({
      "%-G#%.%#",
      "%A%f:%l:%c: %m",
      "%A%f:%l: %m",
      [[%C%*\s%m]],
      "%-G%.%#",
    }, ",")
  end,
})
