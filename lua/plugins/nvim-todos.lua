return {
  "jaswdr/nvim-todos",
  cmd = "TodosToggle",
  keys = {
    { "<leader>ft", "<cmd>TodosToggle<CR>", desc = "Toggle TODOs" },
  },
  config = function()
    require("nvim-todos").setup()
  end,
}
