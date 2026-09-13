return {
  "windwp/nvim-ts-autotag",
  ft = {
    "html",
    "xml",
    "javascript",
    "typescript",
    "javascriptreact",
    "typescriptreact",
    "svelte",
    "vue",
    -- .templ is parsed by the `templ` treesitter parser, which does expose real
    -- HTML tag nodes, so autotag works there (unlike .tmpl -- see closetag.lua).
    "templ",
  },
  config = function()
    require("nvim-ts-autotag").setup {
      opts = {
        enable_close = true,
        enable_rename = true,
        enable_close_on_slash = false,
      },
    }
  end,
}
