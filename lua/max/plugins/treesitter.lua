return {
	"nvim-treesitter/nvim-treesitter",
	event = { "BufReadPre", "BufNewFile" },
	build = ":TSUpdate",

	main = "nvim-treesitter.configs",
	opts = {
		ensure_installed = {
			"json",
			"javascript",
			"typescript",
			"tsx",
			"go",
			"gomod",
			"gosum",
			"gowork",
			"yaml",
			"html",
			"css",
			"python",
			"http",
			"markdown",
			"markdown_inline",
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
			"prisma",
			"svelte",
			"vue",
		},

		highlight = {
			enable = true,
			-- I’d set this to false unless you *need* regex highlight too
			additional_vim_regex_highlighting = { "svelte", "vue" },
		},

		indent = { enable = true },

		injections = { enable = true },

		incremental_selection = {
			enable = true,
			keymaps = {
				init_selection = "<C-space>",
				node_incremental = "<C-space>",
				node_decremental = "<C-backspace>",
			},
		},
	},
}
