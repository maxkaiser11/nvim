-- Auto-close HTML tags in Go templates.
-- nvim-ts-autotag can't handle .tmpl files: the buffer is parsed by the `gotmpl`
-- treesitter parser, which treats HTML as plain text, so there are no tag nodes
-- for it to match. vim-closetag is regex-based and parser-independent, so it
-- works here. Scoped to gohtmltmpl only so it never double-closes tags in the
-- html/jsx/vue/svelte filetypes that nvim-ts-autotag already covers.
return {
  "alvan/vim-closetag",
  ft = { "gohtmltmpl" },
  init = function()
    vim.g.closetag_filenames = "*.tmpl"
    vim.g.closetag_filetypes = "gohtmltmpl"
    vim.g.closetag_emptyTags_caseSensitive = 1
  end,
}
