# Go / htmx / templates

What this config does for Go work, and the two footguns that bit us setting it up.

## Filetypes

| Extension                      | Filetype     | Treesitter                       | Formatted on save     |
| ------------------------------ | ------------ | -------------------------------- | --------------------- |
| `.go`                          | `go`         | `go`                             | goimports → gofumpt   |
| `.tmpl`, `.gohtml`             | `gohtmltmpl` | `gotmpl` + injected `html`       | **no** (see below)    |
| `.gotmpl`, `*.sql.tmpl`, …     | `gotmpl`     | `gotmpl`                         | **no**                |
| `.templ`                       | `templ`      | `templ`                          | `templ fmt`           |
| `go.mod` / `go.work`           | `gomod`/`gowork` | `gomod`/`gowork`             | gofmt                 |

`.tmpl` files are parsed by the `gotmpl` parser, which treats everything outside
`{{ }}` as one blob of text. `queries/gotmpl/injections.scm` injects the `html`
parser into that text with `injection.combined`, so a tag opened before a `{{ }}`
still matches its closing tag after it — that is what makes the markup highlight.

### Why `.tmpl` is never formatted on save

Leaving a filetype out of conform's `formatters_by_ft` is not enough: conform's
`lsp_format = "fallback"` then hands the buffer to whatever LSP claims to format
it, which for `.tmpl` is `vscode-html-language-server`. It does not understand
`{{ }}` and flattens the indentation of every `if`/`range` block on every save.
`lua/configs/conform.lua` skips these filetypes outright. Indent by hand.

## LSP servers per filetype

| Filetype     | Servers                                                         |
| ------------ | --------------------------------------------------------------- |
| `go`         | gopls                                                            |
| `gohtmltmpl` | gopls (template parsing), html, htmx, tailwindcss, emmet         |
| `templ`      | templ, html, htmx, tailwindcss, emmet                            |

gopls parses the template itself: `{{ }}` syntax diagnostics, document symbols
for fields and `{{ define }}` blocks, and go-to-definition between
`{{ template "x" }}` and its definition. It does **not** infer which struct a
template is executed with, so it cannot complete `{{ .Field }}`.

`html`'s diagnostics are dropped on template buffers — it reports every `{{ }}`
as malformed markup. Its completion, hover and folding still work.

`html`/`htmx`/`emmet` default to rooting on `package.json` or `.git` only; they
are given `go.mod`/`go.work` too, or they silently never start in a Go project's
`views/` directory.

**`go-template-lsp` is not enabled.** v0.4.1 returns an initialize result that
Neovim 0.12's LSP client rejects (`INVALID_SERVER_MESSAGE`), so it dies on
attach. gopls covers the same ground.

## gopls: you need a build newer than v0.23.0

gopls v0.23.0 — the current tagged release, and what Mason installs — is built
against an older `x/tools` than the Go 1.27 toolchain. **The moment a package
imports `net/http`, gopls publishes zero analysis diagnostics**: no `printf`, no
`nilness`, no `unusedparams`, only hard compiler errors. `gopls check` on the
same file still reports everything, so nothing looks broken.

Since every htmx/web project imports `net/http`, that removes most of the value.
`lua/configs/lspconfig.lua` therefore prefers `$GOBIN/gopls` over whatever is on
`PATH`. Keep it current with:

```sh
git clone --depth 1 https://go.googlesource.com/tools
cd tools/gopls && go install .
```

Once a release after v0.23.0 ships, `go install golang.org/x/tools/gopls@latest`
is enough and this note can go away.

A second gopls quirk is worked around in the same file: it reports template
parse errors one line *past* the end of the buffer (`unexpected EOF` at line N
of an N-line file), and `vim.diagnostic` then throws `Index out of bounds`.
Since a half-typed `{{ if }}` is the normal state of a template you are editing,
this fired constantly. `clamp_diagnostics` pulls every range back in bounds.

## Keymaps

Debugging is on `<leader>B`, not the conventional `<leader>d` — `<leader>d` is
already bound three times here (black-hole delete in `mappings.lua`, LSP line
diagnostics in `configs/lspconfig.lua`, NvChad's `<leader>ds`), so `<leader>db`
would make every `<leader>d` wait out `timeoutlen`. The test maps likewise avoid
`to`/`tx`/`tn`/`tp`/`tf`, which are the tab mappings.

### Debug (`nvim-dap` + delve)

| Key                            | Action                        |
| ------------------------------ | ----------------------------- |
| `<F5>` / `<S-F5>`              | continue / terminate          |
| `<F9>`                         | toggle breakpoint             |
| `<F10>` / `<F11>` / `<S-F11>`  | step over / into / out        |
| `<leader>Bb` / `<leader>BB`    | breakpoint / conditional      |
| `<leader>Bx`                   | clear all breakpoints         |
| `<leader>Bu` / `<leader>Br`    | toggle UI / REPL              |
| `<leader>Be`                   | evaluate (works on selection) |
| `<leader>Bt` / `<leader>Bl`    | debug nearest / last Go test  |

### Test (`neotest-golang`, runs with `-race -count=1`)

| Key                         | Action                        |
| --------------------------- | ----------------------------- |
| `<leader>tr` / `<leader>tF` | run nearest / file            |
| `<leader>ta` / `<leader>tl` | run all / re-run last         |
| `<leader>tw` / `<leader>tq` | watch file / stop             |
| `<leader>ts`                | summary tree                  |
| `<leader>tO` / `<leader>tP` | output / output panel         |

### Go helpers (`gopher.nvim`)

| Key                                        | Action                       |
| ------------------------------------------ | ---------------------------- |
| `<leader>Gsj` / `<leader>Gsy` / `<leader>Gsd` | add json / yaml / db tags |
| `<leader>GsR`                              | remove struct tags           |
| `<leader>Gie` / `<leader>Gii`              | `if err != nil` / impl iface |
| `<leader>Gt` / `<leader>GT` / `<leader>Ge` | generate tests               |
| `<leader>Gm` / `<leader>Gg`                | `go mod tidy` / `go generate` |

### Buffer-local (`after/ftplugin/go.lua`)

| Key           | Action                                     |
| ------------- | ------------------------------------------ |
| `<leader>Gb`  | `go build ./...` into the quickfix list    |
| `<leader>Gv`  | `go vet ./...` into the quickfix list      |
| `<leader>Gr`  | `go run .`                                 |
| `<leader>Ga`  | jump between `foo.go` and `foo_test.go`    |

In `.tmpl` buffers: `{{` in insert mode expands to `{{ | }}`, and
`<leader>Gi` / `<leader>Gn` / `<leader>Gd` insert `if` / `range` / `define`
blocks. `gc` uses `{{/* */}}`, because an HTML comment around an action still
executes the action.

### LSP

| Key           | Action                                              |
| ------------- | --------------------------------------------------- |
| `<leader>gh`  | toggle inlay hints (param names, inferred types)     |
| `<leader>gl`  | run code lens (gopls: run test, tidy, generate, …)   |
| `<leader>li`  | run linters now (golangci-lint on Go)                |

## Linting

`golangci-lint` runs through nvim-lint **on write only**. It analyses the whole
package by shelling out to the Go toolchain; on `InsertLeave` it locks the editor
up on anything bigger than a toy module. `lua/plugins/nvim-lint.lua` filters the
shared autocmd by filetype to do this.

## Escape hatches

- `:FormatDisable` / `:FormatDisable!` / `:FormatEnable` — turn format-on-save
  off for this buffer, or globally for the session.
- `<leader>lx` / `<leader>ll` — toggle diagnostic virtual text.
