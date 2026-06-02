return {
  -- for wrapping html tags (emmet_ls / emmet_language_server handle the rest via LSP)
  "olrtg/nvim-emmet",
  keys = {
    {
      "<leader>xe",
      function()
        require("nvim-emmet").wrap_with_abbreviation()
      end,
      mode = { "n", "v" },
      desc = "Emmet wrap with abbreviation",
    },
  },
}
