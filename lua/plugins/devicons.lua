-- Override the .go file icon to the "Go" speed-lines logo glyph (U+E627).
-- Merges into NvChad's existing devicons opts so all the other theme icon
-- overrides are preserved.
return {
  "nvim-tree/nvim-web-devicons",
  opts = function(_, opts)
    opts.override = opts.override or {}
    opts.override.go = {
      icon = "\238\152\167", -- U+E627  Go speed-lines logo
      color = "#00ADD8",
      cterm_color = "38",
      name = "Go",
    }
    return opts
  end,
}
