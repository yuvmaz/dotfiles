local M = {}

-- Rust is enabled separately by rustaceanvim.
M.lsp_servers = { "html", "jsonls", "yamlls", "basedpyright", "ruff", "lua_ls", "gopls" }

-- gopls comes from the Go toolchain; lua_ls comes from mise.
M.mason_ensure = { "html", "jsonls", "yamlls", "basedpyright", "ruff" }

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
