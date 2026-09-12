-- Single source of truth for languages.
-- To add a future language: add 1 entry to lsp_servers/parsers/formatters.
local M = {}

-- LSP servers configured via vim.lsp.config + enabled (rust via rustaceanvim, not here)
M.lsp_servers = { "html", "jsonls", "yamlls", "basedpyright", "ruff", "lua_ls" }

-- mason-lspconfig ensure_installed uses lspconfig server names (not mason
-- package names), and mise owns fd/prettier/lua-language-server binaries,
-- so mason installs only the LSP servers with no ownership duplication.
M.mason_ensure = { "html", "jsonls", "yamlls", "basedpyright", "ruff" }

-- Tree-sitter parsers
M.parsers = {
  "html",
  "json",
  "yaml",
  "python",
  "rust",
  "lua",
  "vim",
  "vimdoc",
  "bash",
  "markdown",
  "markdown_inline",
}

-- conform.nvim formatters per filetype (prettier comes from mise shims)
M.formatters = {
  python = { "ruff_format" },
  rust = { "rustfmt" },
  json = { "prettier" },
  yaml = { "prettier" },
  html = { "prettier" },
}

return M
