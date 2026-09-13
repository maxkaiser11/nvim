-- ---------------------------------------------------------------------------
-- Go development: debugging (dap + delve), testing (neotest) and code
-- generation helpers (gopher).
--
-- Everything here is lazy-loaded off the `go`/`gomod` filetypes or off its own
-- keymaps, so it costs nothing when you're not in a Go project.
--
-- Keymap layout (all under <leader>):
--   <F5>/<F9>/<F10>/<F11>  debug: continue / breakpoint / step over / step into
--   <leader>B*  debug       (Bb breakpoint, Bu UI, Bt test under cursor, ...)
--   <leader>t*  test        (tr nearest, tF file, ts summary, tw watch, ...)
--   <leader>G*  go helpers  (Gsj/Gsy struct tags, Gie iferr, Gii impl, Gt tests)
--
-- Why <leader>B and not the conventional <leader>d: <leader>d is already bound
-- three times in this config (black-hole delete in mappings.lua, LSP line
-- diagnostics in configs/lspconfig.lua, and NvChad's <leader>ds). Adding
-- <leader>db on top would make every <leader>d wait out `timeoutlen`.
-- Likewise the test maps avoid to/tx/tn/tp/tf, which are the tab mappings.
-- ---------------------------------------------------------------------------
return {
  -- -------------------------------------------------------------------------
  -- Debugging
  -- -------------------------------------------------------------------------
  {
    "mfussenegger/nvim-dap",
    dependencies = {
      {
        "rcarriga/nvim-dap-ui",
        dependencies = { "nvim-neotest/nvim-nio" },
        config = function()
          local dap, dapui = require "dap", require "dapui"

          dapui.setup {
            icons = { expanded = "▾", collapsed = "▸", current_frame = "▸" },
            layouts = {
              {
                elements = {
                  { id = "scopes", size = 0.35 },
                  { id = "breakpoints", size = 0.15 },
                  { id = "stacks", size = 0.25 },
                  { id = "watches", size = 0.25 },
                },
                position = "left",
                size = 44,
              },
              {
                elements = { { id = "repl", size = 0.5 }, { id = "console", size = 0.5 } },
                position = "bottom",
                size = 12,
              },
            },
          }

          -- open/close the UI automatically with the session
          dap.listeners.before.attach.dapui_config = dapui.open
          dap.listeners.before.launch.dapui_config = dapui.open
          dap.listeners.before.event_terminated.dapui_config = dapui.close
          dap.listeners.before.event_exited.dapui_config = dapui.close
        end,
      },
      {
        "theHamsta/nvim-dap-virtual-text",
        opts = { virt_text_pos = "eol", commented = true },
      },
      {
        -- delve adapter + `debug test under cursor`
        "leoluz/nvim-dap-go",
        ft = "go",
        opts = {
          delve = {
            -- On Windows delve must not be launched in a new terminal window,
            -- or nvim can't talk to it.
            detached = false,
          },
          -- `-gcflags` keeps variables from being optimised away in the inspector
          build_flags = "",
        },
      },
    },
    keys = {
      -- hot path on function keys, so stepping doesn't need the leader at all
      { "<F5>", function() require("dap").continue() end, desc = "Debug: continue / start" },
      { "<S-F5>", function() require("dap").terminate() end, desc = "Debug: terminate" },
      { "<F9>", function() require("dap").toggle_breakpoint() end, desc = "Debug: toggle breakpoint" },
      { "<F10>", function() require("dap").step_over() end, desc = "Debug: step over" },
      { "<F11>", function() require("dap").step_into() end, desc = "Debug: step into" },
      { "<S-F11>", function() require("dap").step_out() end, desc = "Debug: step out" },

      { "<leader>Bb", function() require("dap").toggle_breakpoint() end, desc = "Debug: toggle breakpoint" },
      {
        "<leader>BB",
        function()
          require("dap").set_breakpoint(vim.fn.input "Breakpoint condition: ")
        end,
        desc = "Debug: conditional breakpoint",
      },
      {
        "<leader>Bx",
        function() require("dap").clear_breakpoints() end,
        desc = "Debug: clear all breakpoints",
      },
      { "<leader>Bc", function() require("dap").continue() end, desc = "Debug: continue / start" },
      { "<leader>Br", function() require("dap").repl.toggle() end, desc = "Debug: toggle REPL" },
      { "<leader>Bq", function() require("dap").terminate() end, desc = "Debug: terminate" },
      { "<leader>Bu", function() require("dapui").toggle() end, desc = "Debug: toggle UI" },
      {
        "<leader>Be",
        function() require("dapui").eval(nil, { enter = true }) end,
        mode = { "n", "v" },
        desc = "Debug: evaluate expression",
      },
      -- Go-specific
      { "<leader>Bt", function() require("dap-go").debug_test() end, ft = "go", desc = "Debug: nearest Go test" },
      { "<leader>Bl", function() require("dap-go").debug_last_test() end, ft = "go", desc = "Debug: last Go test" },
    },
    config = function()
      local dap = require "dap"

      vim.fn.sign_define("DapBreakpoint", { text = "", texthl = "DiagnosticError", numhl = "" })
      vim.fn.sign_define("DapBreakpointCondition", { text = "", texthl = "DiagnosticWarn", numhl = "" })
      vim.fn.sign_define("DapLogPoint", { text = "", texthl = "DiagnosticInfo", numhl = "" })
      vim.fn.sign_define("DapStopped", { text = "", texthl = "DiagnosticOk", linehl = "Visual" })

      -- Debug the package in the current directory with arbitrary args, which
      -- nvim-dap-go's own configurations don't cover.
      table.insert(dap.configurations.go or {}, {
        type = "go",
        name = "Debug package (with args)",
        request = "launch",
        program = "${fileDirname}",
        args = function()
          return vim.split(vim.fn.input "Args: ", " ", { trimempty = true })
        end,
      })
    end,
  },

  -- -------------------------------------------------------------------------
  -- Test runner
  -- -------------------------------------------------------------------------
  {
    "nvim-neotest/neotest",
    dependencies = {
      "nvim-neotest/nvim-nio",
      "nvim-lua/plenary.nvim",
      "antoinemadec/FixCursorHold.nvim",
      "nvim-treesitter/nvim-treesitter",
      "fredrikaverpil/neotest-golang",
    },
    ft = { "go" },
    keys = {
      {
        "<leader>tr",
        function() require("neotest").run.run() end,
        desc = "Test: run nearest",
      },
      {
        "<leader>tF",
        function() require("neotest").run.run(vim.fn.expand "%") end,
        desc = "Test: run file",
      },
      {
        "<leader>ta",
        function() require("neotest").run.run(vim.uv.cwd()) end,
        desc = "Test: run all",
      },
      {
        "<leader>tl",
        function() require("neotest").run.run_last() end,
        desc = "Test: re-run last",
      },
      {
        "<leader>tq",
        function() require("neotest").run.stop() end,
        desc = "Test: stop",
      },
      {
        "<leader>ts",
        function() require("neotest").summary.toggle() end,
        desc = "Test: toggle summary tree",
      },
      {
        "<leader>tO",
        function() require("neotest").output.open { enter = true, auto_close = true } end,
        desc = "Test: show output",
      },
      {
        "<leader>tP",
        function() require("neotest").output_panel.toggle() end,
        desc = "Test: toggle output panel",
      },
      {
        "<leader>tw",
        function() require("neotest").watch.toggle(vim.fn.expand "%") end,
        desc = "Test: watch file",
      },
    },
    config = function()
      require("neotest").setup {
        adapters = {
          require "neotest-golang" {
            -- `-count=1` defeats Go's test result cache, so a re-run actually
            -- re-runs. `-race` catches the data races that HTTP handlers love.
            go_test_args = { "-v", "-race", "-count=1" },
            dap_go_enabled = true, -- <leader>ts in the summary tree debugs a test
          },
        },
        discovery = { enabled = true, concurrent = 1 },
        running = { concurrent = true },
        summary = {
          animated = false,
          open = "botright vsplit | vertical resize 50",
        },
        quickfix = { enabled = false }, -- diagnostics are enough; keeps qf free
        output = { open_on_run = false },
        status = { virtual_text = true, signs = true },
      }
    end,
  },

  -- -------------------------------------------------------------------------
  -- Go code generation helpers
  -- -------------------------------------------------------------------------
  {
    "olexsmir/gopher.nvim",
    ft = "go",
    dependencies = { "nvim-lua/plenary.nvim", "nvim-treesitter/nvim-treesitter" },
    -- the plugin's own :GoInstallDeps is redundant — mason-tool-installer
    -- already fetches gomodifytags / impl / gotests (see plugins/mason.lua)
    build = false,
    opts = {
      commands = {
        go = "go",
        gomodifytags = "gomodifytags",
        gotests = "gotests",
        impl = "impl",
        iferr = "iferr",
      },
    },
    keys = {
      { "<leader>Gsj", "<cmd>GoTagAdd json<cr>", ft = "go", desc = "Go: add json struct tags" },
      { "<leader>Gsy", "<cmd>GoTagAdd yaml<cr>", ft = "go", desc = "Go: add yaml struct tags" },
      { "<leader>Gsd", "<cmd>GoTagAdd db<cr>", ft = "go", desc = "Go: add db struct tags" },
      { "<leader>GsR", "<cmd>GoTagRm<cr>", ft = "go", desc = "Go: remove struct tags" },
      { "<leader>Gie", "<cmd>GoIfErr<cr>", ft = "go", desc = "Go: generate if err != nil" },
      { "<leader>Gii", "<cmd>GoImpl<cr>", ft = "go", desc = "Go: implement interface" },
      { "<leader>Gt", "<cmd>GoTestAdd<cr>", ft = "go", desc = "Go: generate test for function" },
      { "<leader>GT", "<cmd>GoTestsAll<cr>", ft = "go", desc = "Go: generate tests for all functions" },
      { "<leader>Ge", "<cmd>GoTestsExp<cr>", ft = "go", desc = "Go: generate tests for exported" },
      { "<leader>Gm", "<cmd>GoMod tidy<cr>", ft = "go", desc = "Go: go mod tidy" },
      { "<leader>Gg", "<cmd>GoGenerate<cr>", ft = "go", desc = "Go: go generate" },
    },
  },
}
