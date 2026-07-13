-- NvChad LSP defaults (sets on_attach + capabilities on "*")
require("nvchad.configs.lspconfig").defaults()

-- ---------------------------------------------------------------------------
-- Extra LSP keymaps (ported from nvim-custom) layered on top of NvChad's.
-- ---------------------------------------------------------------------------
vim.api.nvim_create_autocmd("LspAttach", {
  group = vim.api.nvim_create_augroup("UserLspConfig", {}),
  callback = function(ev)
    local opts = { buffer = ev.buf, silent = true }

    opts.desc = "Show LSP references"
    vim.keymap.set("n", "gR", "<cmd>Telescope lsp_references<CR>", opts)

    opts.desc = "Go to declaration"
    vim.keymap.set("n", "gD", vim.lsp.buf.declaration, opts)

    opts.desc = "Show LSP definitions"
    vim.keymap.set("n", "gd", "<cmd>Telescope lsp_definitions<CR>", opts)

    opts.desc = "Show LSP implementations"
    vim.keymap.set("n", "gi", "<cmd>Telescope lsp_implementations<CR>", opts)

    opts.desc = "Show LSP type definitions"
    vim.keymap.set("n", "gt", "<cmd>Telescope lsp_type_definitions<CR>", opts)

    opts.desc = "See available code actions"
    vim.keymap.set({ "n", "v" }, "<leader>vca", vim.lsp.buf.code_action, opts)

    opts.desc = "Smart rename"
    vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts)

    opts.desc = "Show buffer diagnostics"
    vim.keymap.set("n", "<leader>D", "<cmd>Telescope diagnostics bufnr=0<CR>", opts)

    opts.desc = "Show line diagnostics"
    vim.keymap.set("n", "<leader>d", vim.diagnostic.open_float, opts)

    opts.desc = "Show documentation for what is under cursor"
    vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)

    opts.desc = "Restart LSP"
    vim.keymap.set("n", "<leader>rs", "<cmd>LspRestart<CR>", opts)

    vim.keymap.set("i", "<C-h>", vim.lsp.buf.signature_help, opts)
  end,
})

-- ---------------------------------------------------------------------------
-- Diagnostics
-- ---------------------------------------------------------------------------
local signs = {
  [vim.diagnostic.severity.ERROR] = " ",
  [vim.diagnostic.severity.WARN] = " ",
  [vim.diagnostic.severity.HINT] = "󰠠 ",
  [vim.diagnostic.severity.INFO] = " ",
}

local augroup = vim.api.nvim_create_augroup("LspDiagnosticsHold", { clear = true })
local virtual_text_enabled = true
vim.o.updatetime = 350

local function cursor_over_diagnostic()
  local bufnr = vim.api.nvim_get_current_buf()
  local cursor_pos = vim.api.nvim_win_get_cursor(0)
  local lnum = cursor_pos[1] - 1
  local col = cursor_pos[2]
  local diags = vim.diagnostic.get(bufnr, { lnum = lnum })
  for _, diag in ipairs(diags) do
    if diag.end_lnum == lnum and col >= diag.col and col < diag.end_col then
      return true
    end
  end
  return false
end

local function has_floating_win()
  for _, winid in ipairs(vim.api.nvim_list_wins()) do
    local cfg = vim.api.nvim_win_get_config(winid)
    if cfg.relative ~= "" then
      return true
    end
  end
  return false
end

local function update_diagnostic_config()
  vim.diagnostic.config {
    signs = { text = signs },
    virtual_text = virtual_text_enabled,
    underline = true,
    update_in_insert = true,
    float = {
      focusable = false,
      style = "minimal",
      border = "rounded",
      source = true,
    },
  }
end

update_diagnostic_config()

vim.keymap.set("n", "<leader>lx", function()
  virtual_text_enabled = not virtual_text_enabled
  update_diagnostic_config()
end, { desc = "Toggle LSP virtual text" })

vim.keymap.set("n", "<leader>ll", function()
  virtual_text_enabled = not virtual_text_enabled
  update_diagnostic_config()

  vim.api.nvim_clear_autocmds { group = augroup }

  if not virtual_text_enabled then
    vim.api.nvim_create_autocmd("CursorHold", {
      group = augroup,
      callback = function()
        if cursor_over_diagnostic() and not has_floating_win() then
          vim.diagnostic.open_float(nil, {
            focusable = false,
            close_events = {
              "CursorMoved",
              "CursorMovedI",
              "BufHidden",
              "InsertCharPre",
              "WinLeave",
            },
          })
        end
      end,
    })
  end
end, { desc = "Toggle LSP diagnostics virtual text or precise hover" })

-- ---------------------------------------------------------------------------
-- Server-specific configuration (capabilities/on_attach come from the "*"
-- config that NvChad's defaults() sets up above).
-- ---------------------------------------------------------------------------
vim.lsp.config("lua_ls", {
  settings = {
    Lua = {
      diagnostics = {
        globals = { "vim" },
      },
      completion = {
        callSnippet = "Replace",
      },
      workspace = {
        library = {
          [vim.fn.expand "$VIMRUNTIME/lua"] = true,
          [vim.fn.stdpath "config" .. "/lua"] = true,
        },
      },
    },
  },
})

-- html (vscode-html-language-server) — also attach to Go HTML templates
vim.lsp.config("html", {
  filetypes = { "html", "templ", "gohtmltmpl" },
})

vim.lsp.config("emmet_language_server", {
  filetypes = {
    "css",
    "eruby",
    "html",
    "gohtmltmpl",
    "javascript",
    "javascriptreact",
    "less",
    "sass",
    "scss",
    "pug",
    "typescriptreact",
    "svelte",
    "vue",
    "ejs",
  },
})

vim.lsp.config("emmet_ls", {
  filetypes = {
    "html",
    "gohtmltmpl",
    "typescriptreact",
    "javascriptreact",
    "css",
    "sass",
    "scss",
    "less",
    "svelte",
    "vue",
  },
})

vim.lsp.config("ts_ls", {
  filetypes = {
    "javascript",
    "javascriptreact",
    "typescript",
    "typescriptreact",
    "vue",
  },
  single_file_support = true,
  init_options = {
    preferences = {
      includeCompletionsForModuleExports = true,
      includeCompletionsForImportStatements = true,
    },
  },
})

vim.lsp.config("gopls", {
  settings = {
    gopls = {
      analyses = {
        unusedparams = true,
      },
      staticcheck = true,
      gofumpt = true,
    },
  },
})

vim.lsp.config("cssls", {
  filetypes = { "css", "scss", "less" },
  settings = {
    css = { validate = true },
    scss = { validate = true },
    less = { validate = true },
  },
})

vim.lsp.config("tailwindcss", {
  filetypes = {
    "html",
    "gohtmltmpl",
    "css",
    "javascript",
    "typescript",
    "javascriptreact",
    "typescriptreact",
    "svelte",
    "vue",
    "astro",
  },
  init_options = {
    userLanguages = {
      astro = "html",
    },
  },
})

-- clangd (C / C++ / Objective-C)
vim.lsp.config("clangd", {
  cmd = {
    "clangd",
    "--background-index",
    "--clang-tidy",
    "--header-insertion=iwyu",
    "--completion-style=detailed",
    "--function-arg-placeholders",
    "--fallback-style=llvm",
    -- Let clangd query MinGW's g++ for its system/libstdc++ include paths.
    -- Without this clangd can't find <iostream> etc. and reports
    -- "use of undeclared identifier 'std'".
    "--query-driver=C:/mingw64/bin/*",
  },
  filetypes = { "c", "cpp", "objc", "objcpp", "cuda" },
  init_options = {
    usePlaceholders = true,
    completeUnimported = true,
    clangdFileStatus = true,
  },
})

-- Enable the servers
vim.lsp.enable {
  "clangd",
  "html",
  "cssls",
  "lua_ls",
  "ts_ls",
  "gopls",
  "tailwindcss",
  "emmet_language_server",
  "emmet_ls",
  "astro",
  "svelte",
  "marksman",
}

-- read :h vim.lsp.config for changing options of lsp servers
