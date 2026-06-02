-- nvzone/showkeys — on-screen keypress display. Toggle with :ShowkeysToggle
-- (auto-start on launch was removed so it doesn't pop up over NvChad's UI by default)
return {
  "nvzone/showkeys",
  cmd = "ShowkeysToggle",
  opts = {
    position = "bottom-center",
    maxkeys = 3,
    show_count = true,
    winopts = {
      focusable = false,
      relative = "editor",
      style = "minimal",
      border = "single",
      height = 1,
      row = 1,
      col = 0,
    },
  },
}
