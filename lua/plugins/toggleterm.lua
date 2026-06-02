-- akinsho/toggleterm.nvim — opens with <C-t> (NvChad's built-in term keys are unaffected)
return {
  "akinsho/toggleterm.nvim",
  version = "*",
  keys = { [[<C-t>]] },
  cmd = { "ToggleTerm", "TermExec" },
  opts = {
    open_mapping = [[<C-t>]],
    direction = "horizontal",
    float_opts = {
      border = "rounded",
    },
  },
}
