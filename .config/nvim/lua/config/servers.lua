-- Single source of truth for languages.
-- To add a future language: add 1 entry to lsp_servers/parsers/formatters.
-- Server vim.lsp.config blocks live in config/lsp-servers.lua.
local M = {}

-- LSP servers configured via vim.lsp.config + enabled (rust via rustaceanvim, not here)
M.lsp_servers = { "html", "jsonls", "yamlls", "basedpyright", "ruff", "lua_ls", "gopls" }

-- mason-lspconfig ensure_installed uses lspconfig server names (not mason
-- package names), and mise owns fd/prettier/lua-language-server/stylua
-- binaries, so mason installs only the LSP servers with no ownership
-- duplication. gopls installs via the go toolchain.
M.mason_ensure = { "html", "jsonls", "yamlls", "basedpyright", "ruff", "gopls" }

-- Tree-sitter parsers
M.parsers = {
  "html",
  "json",
  "yaml",
  "python",
  "rust",
  "go",
  "lua",
  "vim",
  "vimdoc",
  "bash",
  "markdown",
  "markdown_inline",
}

-- conform.nvim formatters per filetype (prettier/stylua come from mise shims)
M.formatters = {
  python = { "ruff_format" },
  rust = { "rustfmt" },
  go = { "gofmt" },
  lua = { "stylua" },
  json = { "prettier" },
  yaml = { "prettier" },
  html = { "prettier" },
}

return M
