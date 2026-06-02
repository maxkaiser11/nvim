-- folke/snacks.nvim
-- Ported from nvim-custom. NvChad keeps its own dashboard / file picker UI,
-- so the snacks dashboard is disabled here and the find-files/buffers keymaps
-- (which clash with NvChad's Telescope <leader>ff / <leader>fb) are omitted.
-- Mainly here for lazygit + a few utility pickers.
return {
  {
    "folke/snacks.nvim",
    priority = 1000,
    lazy = false,
    opts = {
      styles = {
        input = {
          keys = {
            n_esc = { "<C-c>", { "cmp_close", "cancel" }, mode = "n", expr = true },
            i_esc = { "<C-c>", { "cmp_close", "stopinsert" }, mode = "i", expr = true },
          },
        },
      },
      input = { enabled = true },
      quickfile = {
        enabled = true,
        exclude = { "latex" },
      },
      picker = {
        enabled = true,
        matchers = {
          frecency = true,
          cwd_bonus = false,
        },
        exclude = {
          ".git",
          "node_modules",
          "dist",
          "build",
        },
        formatters = {
          file = {
            filename_first = true,
            filename_only = false,
            icon_width = 2,
          },
        },
        layout = {
          preset = "telescope",
          cycle = false,
        },
        layouts = {
          select = {
            preview = false,
            layout = {
              backdrop = false,
              width = 0.6,
              min_width = 80,
              height = 0.4,
              min_height = 10,
              box = "vertical",
              border = "rounded",
              title = "{title}",
              title_pos = "center",
              { win = "input", height = 1, border = "bottom" },
              { win = "list", border = "none" },
              { win = "preview", title = "{preview}", width = 0.6, height = 0.4, border = "top" },
            },
          },
          telescope = {
            reverse = true,
            layout = {
              box = "horizontal",
              backdrop = false,
              width = 0.8,
              height = 0.9,
              border = "none",
              {
                box = "vertical",
                { win = "list", title = " Results ", title_pos = "center", border = "rounded" },
                {
                  win = "input",
                  height = 1,
                  border = "rounded",
                  title = "{title} {live} {flags}",
                  title_pos = "center",
                },
              },
              {
                win = "preview",
                title = "{preview:Preview}",
                width = 0.50,
                border = "rounded",
                title_pos = "center",
              },
            },
          },
          ivy = {
            layout = {
              box = "vertical",
              backdrop = false,
              width = 0,
              height = 0.4,
              position = "bottom",
              border = "top",
              title = " {title} {live} {flags}",
              title_pos = "left",
              { win = "input", height = 1, border = "bottom" },
              {
                box = "horizontal",
                { win = "list", border = "none" },
                { win = "preview", title = "{preview}", width = 0.5, border = "left" },
              },
            },
          },
        },
      },
      image = {
        enabled = function()
          return vim.bo.filetype == "markdown"
        end,
        doc = {
          float = false,
          inline = false,
          max_width = 50,
          max_height = 30,
          wo = {
            wrap = false,
          },
        },
        convert = {
          notify = true,
          command = "magick",
        },
        img_dirs = {
          "img",
          "images",
          "assets",
          "static",
          "public",
          "media",
          "attachments",
          "Archives/All-Vault-Images/",
          "~/Library",
          "~/Downloads",
        },
      },
      -- Custom greeting screen (ported from nvim-custom). NvChad's nvdash is
      -- disabled in chadrc.lua so this is the startup screen.
      dashboard = {
        enabled = true,
        sections = {
          { section = "header" },
          { section = "keys", gap = 1, padding = 1 },
          { section = "startup" },
          {
            section = "terminal",
            -- Renders your profile picture as ascii art. Requires the
            -- `ascii-image-converter` CLI and the image below to exist;
            -- if either is missing this pane just stays empty.
            cmd = "ascii-image-converter " .. (os.getenv "USERPROFILE" or "") .. "\\Pictures\\profile2.jpg -C -c -W 35",
            random = 15,
            pane = 2,
            indent = 15,
            height = 20,
          },
        },
      },
    },
    keys = {
      {
        "<leader>lg",
        function()
          require("snacks").lazygit()
        end,
        desc = "Lazygit",
      },
      {
        "<leader>gl",
        function()
          require("snacks").lazygit.log()
        end,
        desc = "Lazygit Logs",
      },
      {
        "<leader>rN",
        function()
          require("snacks").rename.rename_file()
        end,
        desc = "Fast Rename Current File",
      },
      {
        "<leader>dB",
        function()
          require("snacks").bufdelete()
        end,
        desc = "Delete or Close Buffer (Confirm)",
      },
      {
        "<leader>fc",
        function()
          require("snacks").picker.files { cwd = vim.fn.stdpath "config" }
        end,
        desc = "Find Config File",
      },
      {
        "<leader>fs",
        function()
          require("snacks").picker.grep()
        end,
        desc = "Grep word (Snacks)",
      },
      {
        "<leader>fws",
        function()
          require("snacks").picker.grep_word()
        end,
        desc = "Search Visual selection or Word",
        mode = { "n", "x" },
      },
      {
        "<leader>fk",
        function()
          require("snacks").picker.keymaps { layout = "ivy" }
        end,
        desc = "Search Keymaps (Snacks Picker)",
      },
      {
        "<leader>gbr",
        function()
          require("snacks").picker.git_branches { layout = "select" }
        end,
        desc = "Pick and Switch Git Branches",
      },
      {
        "<leader>vh",
        function()
          require("snacks").picker.help()
        end,
        desc = "Help Pages",
      },
    },
  },
}
