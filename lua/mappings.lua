require "nvchad.mappings"

-- add yours here

local map = vim.keymap.set
local opts = { noremap = true, silent = true }

map("n", ";", ":", { desc = "CMD enter command mode" })
map("i", "jk", "<ESC>")

-- toggle file explorer (NvChad maps <leader>e to focus-only; make it toggle)
map("n", "<leader>e", "<cmd>NvimTreeToggle<CR>", { desc = "Toggle file explorer" })

vim.g.maplocalleader = " "

-- ---------------------------------------------------------------------------
-- General editing (ported from nvim-custom)
-- ---------------------------------------------------------------------------

-- re-source current file
map("n", "<leader><leader>", function()
  if vim.bo.filetype == "lua" then
    vim.cmd "source %"
  else
    vim.notify("Not a Lua config file — nothing to source", vim.log.levels.WARN)
  end
end, { desc = "Source current file" })

-- move selected lines up/down
map("v", "J", ":m '>+1<CR>gv=gv", { desc = "Move selection down" })
map("v", "K", ":m '<-2<CR>gv=gv", { desc = "Move selection up" })

-- keep cursor centered
map("n", "J", "mzJ`z")
map("n", "<C-d>", "<C-d>zz", { desc = "Half page down (centered)" })
map("n", "<C-u>", "<C-u>zz", { desc = "Half page up (centered)" })
map("n", "n", "nzzzv")
map("n", "N", "Nzzzv")

-- keep selection when indenting
map("v", "<", "<gv", opts)
map("v", ">", ">gv", opts)

-- paste/delete without clobbering the yank register
map("v", "p", '"_dp', opts)
map("n", "<leader>Y", [["+Y]], opts)
map({ "n", "v" }, "<leader>d", [["_d]])
map("n", "x", '"_x', opts)

-- ctrl-c as escape / clear search highlight
map("i", "<C-c>", "<Esc>")
map("n", "<C-c>", ":nohl<CR>", { desc = "Clear search highlight", silent = true })

-- format with the built-in LSP formatter
map("n", "<leader>f", vim.lsp.buf.format, { desc = "LSP format" })

-- disable Q
map("n", "Q", "<nop>")

-- start a tmux session (no-op without tmux)
map("n", "<C-f>", "<cmd>silent !tmux neww tmux-sessionizer<CR>")

-- replace word under cursor globally
map("n", "<leader>s", [[:%s/\<<C-r><C-w>\>/<C-r><C-w>/gI<Left><Left><Left>]], { desc = "Replace word under cursor" })

-- make file executable
map("n", "<leader>X", "<cmd>!chmod +x %<CR>", { silent = true, desc = "Make file executable" })

-- tabs
map("n", "<leader>to", "<cmd>tabnew<CR>", { desc = "New tab" })
map("n", "<leader>tx", "<cmd>tabclose<CR>", { desc = "Close tab" })
map("n", "<leader>tn", "<cmd>tabn<CR>", { desc = "Next tab" })
map("n", "<leader>tp", "<cmd>tabp<CR>", { desc = "Previous tab" })
map("n", "<leader>tf", "<cmd>tabnew %<CR>", { desc = "Open current file in new tab" })

-- splits
map("n", "<leader>sv", "<C-w>v", { desc = "Split window vertically" })
map("n", "<leader>sh", "<C-w>s", { desc = "Split window horizontally" })
map("n", "<leader>se", "<C-w>=", { desc = "Make splits equal size" })
map("n", "<leader>sx", "<cmd>close<CR>", { desc = "Close current split" })

-- copy file path to clipboard
map("n", "<leader>fp", function()
  local filePath = vim.fn.expand "%:~"
  vim.fn.setreg("+", filePath)
  print("File path copied to clipboard: " .. filePath)
end, { desc = "Copy file path to clipboard" })

-- terminal window navigation
map("t", "<C-h>", "<C-\\><C-n><C-w>h")
map("t", "<C-j>", "<C-\\><C-n><C-w>j")
map("t", "<C-k>", "<C-\\><C-n><C-w>k")
map("t", "<C-l>", "<C-\\><C-n><C-w>l")

-- ---------------------------------------------------------------------------
-- Telescope extras (NvChad's default Telescope maps stay as-is)
-- ---------------------------------------------------------------------------
map("n", "<leader>pr", "<cmd>Telescope oldfiles<CR>", { desc = "Recent files" })
map("n", "<leader>pWs", function()
  local word = vim.fn.expand "<cWORD>"
  require("telescope.builtin").grep_string { search = word }
end, { desc = "Grep WORD under cursor" })

-- ---------------------------------------------------------------------------
-- Conform manual format
-- ---------------------------------------------------------------------------
map({ "n", "v" }, "<leader>mp", function()
  require("conform").format {
    lsp_fallback = true,
    async = false,
    timeout_ms = 1000,
  }
end, { desc = "Format file or range" })
