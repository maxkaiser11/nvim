return {
	"akinsho/bufferline.nvim",
	version = "*",
	dependencies = { "nvim-tree/nvim-web-devicons" },
	config = function()
		require("bufferline").setup({
			options = {
				diagnostics = "nvim_lsp", -- shows LSP error/warn icons on tabs
				separator_style = "slant", -- try "slant", "slope", "thick", "thin"
				show_buffer_close_icons = true,
				show_close_icon = false,
			},
		})

		-- Keymaps
		vim.keymap.set("n", "<Tab>", "<cmd>BufferLineCycleNext<CR>")
		vim.keymap.set("n", "<S-Tab>", "<cmd>BufferLineCyclePrev<CR>")
		vim.keymap.set("n", "<leader>x", "<cmd>bd<CR>") -- close current buffer
	end,
}
