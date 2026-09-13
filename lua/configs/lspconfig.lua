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

    local client = vim.lsp.get_client_by_id(ev.data.client_id)

    -- Inlay hints (param names / inferred types). Off by default, <leader>gh
    -- toggles them for the current buffer.
    if client and client:supports_method "textDocument/inlayHint" then
      opts.desc = "Toggle inlay hints"
      vim.keymap.set("n", "<leader>gh", function()
        vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled { bufnr = ev.buf }, { bufnr = ev.buf })
      end, opts)
    end

    -- gopls code lenses: run test / generate / tidy / upgrade dependency.
    -- On 0.12 `codelens.enable` owns the refresh cycle; `codelens.refresh` is
    -- deprecated and a hand-rolled BufEnter/InsertLeave autocmd is redundant.
    if client and client:supports_method "textDocument/codeLens" then
      opts.desc = "Run code lens"
      vim.keymap.set("n", "<leader>gl", vim.lsp.codelens.run, opts)
      vim.lsp.codelens.enable(true, { bufnr = ev.buf })
    end
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

-- html (vscode-html-language-server) — also attach to Go HTML templates.
-- It can't parse {{ }} actions, so its diagnostics are dropped on template
-- buffers (go_template_lsp / templ own correctness there); completion, hover
-- and folding still work.
vim.lsp.config("html", {
  filetypes = { "html", "templ", "gohtmltmpl" },
  -- default is { "package.json", ".git" } -- a Go module has neither in a
  -- views/ subdirectory, and then the server silently never starts
  root_markers = { "package.json", "go.work", "go.mod", ".git" },
  handlers = {
    ["textDocument/publishDiagnostics"] = function(err, result, ctx)
      local ft = vim.bo[vim.uri_to_bufnr(result.uri)].filetype
      if ft == "gohtmltmpl" or ft == "templ" then
        return
      end
      return vim.lsp.handlers["textDocument/publishDiagnostics"](err, result, ctx)
    end,
  },
})

-- emmet: only emmet_language_server is enabled. Running emmet_ls alongside it
-- produces duplicate completion entries for every abbreviation.
vim.lsp.config("emmet_language_server", {
  root_markers = { "go.work", "go.mod", "package.json", ".git" },
  filetypes = {
    "css",
    "eruby",
    "html",
    "gohtmltmpl",
    "templ",
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

-- ---------------------------------------------------------------------------
-- Go
-- ---------------------------------------------------------------------------

-- gopls reports template parse errors one line PAST the end of the buffer
-- ("unexpected EOF" at line N for an N-line file). vim.diagnostic then calls
-- nvim_buf_get_lines on that line and raises "Index out of bounds", which
-- aborts whatever triggered the publish. An unterminated {{ if }} is the normal
-- state of a template you are halfway through typing, so this fires constantly.
-- Clamp every range into the buffer before handing it on.
-- gopls publishes diagnostics for files across the whole module, most of which
-- have no buffer yet -- and those are exactly the ones that blow up later, when
-- the file is finally opened and the stored range is rendered. So fall back to
-- counting lines on disk. Only template URIs pay for that read; .go files (the
-- overwhelming majority, and never the source of this bug) are skipped.
local function line_count(uri, buf)
  if vim.api.nvim_buf_is_loaded(buf) then
    return vim.api.nvim_buf_line_count(buf)
  end
  local fname = vim.uri_to_fname(uri)
  if fname:match "%.go$" or vim.fn.filereadable(fname) ~= 1 then
    return nil
  end
  return #vim.fn.readfile(fname)
end

local function last_line_text(uri, buf, lnum)
  if vim.api.nvim_buf_is_loaded(buf) then
    return vim.api.nvim_buf_get_lines(buf, lnum, lnum + 1, false)[1] or ""
  end
  return vim.fn.readfile(vim.uri_to_fname(uri), "", lnum + 1)[lnum + 1] or ""
end

local function clamp_diagnostics(err, result, ctx)
  local buf = vim.uri_to_bufnr(result.uri)
  local count = line_count(result.uri, buf)
  if count then
    local last = math.max(count - 1, 0)
    for _, d in ipairs(result.diagnostics or {}) do
      for _, pos in ipairs { d.range.start, d.range["end"] } do
        if pos.line > last then
          pos.line = last
          pos.character = #last_line_text(result.uri, buf, last)
        end
      end
      local r = d.range
      if r.start.line == r["end"].line and r.start.character > r["end"].character then
        r.start.character = r["end"].character
      end
    end
  end
  return vim.lsp.handlers["textDocument/publishDiagnostics"](err, result, ctx)
end

-- Which gopls binary to run.
--
-- The tagged release (v0.23.0, what Mason installs) is built against an older
-- x/tools than the Go 1.27 toolchain here. The moment a package imports
-- net/http, gopls fails to read the stdlib export data and silently publishes
-- ZERO analysis diagnostics -- no printf, no nilness, no unusedparams, only
-- hard compiler errors. `gopls check` on the same file still reports them, so
-- the failure is invisible unless you go looking. Since every htmx/web project
-- imports net/http, that is the whole point of this config.
--
-- A gopls built from master handles Go 1.27 fine, so prefer the one in GOBIN
-- and fall back to whatever is on PATH. Rebuild with:
--     git clone --depth 1 https://go.googlesource.com/tools
--     cd tools/gopls && go install .
-- Drop this once a release past v0.23.0 is out (`go install ...gopls@latest`
-- will then be enough) and Mason has picked it up.
local function gopls_cmd()
  local gobin = vim.env.GOBIN
  if not gobin or gobin == "" then
    gobin = vim.fs.joinpath(vim.env.GOPATH or vim.fs.joinpath(vim.uv.os_homedir(), "go"), "bin")
  end
  local exe = vim.fs.joinpath(gobin, "gopls" .. (vim.fn.has "win32" == 1 and ".exe" or ""))
  return vim.fn.executable(exe) == 1 and { exe } or { "gopls" }
end

vim.lsp.config("gopls", {
  handlers = {
    ["textDocument/publishDiagnostics"] = clamp_diagnostics,
  },
  cmd = gopls_cmd(),
  -- `gohtmltmpl` is not in nvim-lspconfig's default list, but gopls only sees a
  -- template if nvim actually sends didOpen for it -- without this the
  -- `templateExtensions` setting below is dead config.
  filetypes = { "go", "gomod", "gowork", "gotmpl", "gohtmltmpl" },
  settings = {
    gopls = {
      -- Parse Go templates: gives real {{ }} syntax diagnostics, document
      -- symbols for the fields and {{ define }} blocks, and go-to-definition
      -- between {{ template "x" }} and its definition. gopls does NOT infer
      -- which struct a template is executed with, so it cannot complete
      -- {{ .Field }} -- htmx/tailwind/emmet handle the markup half.
      -- "html" is deliberately absent: .html keeps the `html` filetype and is
      -- never sent to gopls, and listing it here only makes gopls report
      -- template errors for ordinary HTML elsewhere in the module.
      templateExtensions = { "tmpl", "gotmpl", "gohtml" },

      gofumpt = true,
      staticcheck = true,
      semanticTokens = true,
      usePlaceholders = true,
      completeUnimported = true,
      -- rank stdlib/most-used completions higher instead of alphabetically
      matcher = "Fuzzy",
      experimentalPostfixCompletions = true,
      symbolMatcher = "FastFuzzy",
      -- don't index vendored deps / build output as workspace symbols
      directoryFilters = { "-.git", "-.vscode", "-.idea", "-node_modules", "-vendor", "-tmp", "-bin" },

      analyses = {
        unusedparams = true,
        unusedwrite = true,
        unusedvariable = true,
        useany = true,
        nilness = true,
        shadow = false, -- too noisy with idiomatic `err :=` shadowing
        fieldalignment = false, -- opinionated; enable per-project if you care
      },

      -- Inline hints: parameter names, inferred types, composite-literal keys.
      -- Toggle them at runtime with <leader>gh.
      hints = {
        assignVariableTypes = true,
        compositeLiteralFields = true,
        compositeLiteralTypes = true,
        constantValues = true,
        functionTypeParameters = true,
        parameterNames = true,
        rangeVariableTypes = true,
      },

      codelenses = {
        gc_details = false,
        generate = true,
        regenerate_cgo = true,
        run_govulncheck = true,
        test = true,
        tidy = true,
        upgrade_dependency = true,
        vendor = true,
      },
    },
  },
})

-- a-h/templ (.templ) -- installed via mason as the `templ` package.
vim.lsp.config("templ", {
  filetypes = { "templ" },
})

-- htmx-lsp: completion + docs for hx-* attributes.
vim.lsp.config("htmx", {
  filetypes = { "html", "templ", "gohtmltmpl" },
  root_markers = { "go.work", "go.mod", "package.json", ".git" },
})

-- go-template-lsp (https://github.com/yayolande/go-template-lsp) is NOT enabled.
-- v0.4.1 returns an initialize result that Neovim 0.12's stricter LSP client
-- rejects outright ("INVALID_SERVER_MESSAGE"), so the server dies on attach.
-- gopls covers the same ground better anyway: with `templateExtensions` set
-- above it resolves {{ .Field }} against the struct actually passed to
-- Execute, which go-template-lsp never did. Re-enable it here if upstream
-- fixes the handshake.
--
-- vim.lsp.config("go_template_lsp", {
--   cmd = { "go-template-lsp" },
--   filetypes = { "gohtmltmpl", "gotmpl" },
--   root_markers = { "go.mod" },
-- })

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
    "gotmpl",
    "templ",
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
      templ = "html",
      gohtmltmpl = "html",
    },
  },
  settings = {
    tailwindCSS = {
      includeLanguages = {
        templ = "html",
        gohtmltmpl = "html",
        gotmpl = "html",
      },
      -- pick up `class=` inside {{ if }} blocks and Go string literals that
      -- hold class lists (e.g. `var btn = "px-4 py-2 ..."`)
      experimental = {
        classRegex = {
          [[class[:=]\s*"([^"]*)"]],
          [[Class[:=]\s*"([^"]*)"]],
          [[\bclass(?:es)?\s*[:=]\s*`([^`]*)`]],
        },
      },
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
  "templ",
  "htmx",
  "cssls",
  "lua_ls",
  "ts_ls",
  "gopls",
  "tailwindcss",
  "emmet_language_server",
  "astro",
  "svelte",
  "marksman",
}

-- read :h vim.lsp.config for changing options of lsp servers
