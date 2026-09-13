-- nvim-lspconfig v2 provides lsp/*.lua default configs that the native
-- vim.lsp.config()/vim.lsp.enable() API (Nvim 0.11+) reads from rtp.
-- Server overrides live in lua/config/lsp.lua; schemastore feeds jsonls/yamlls.
return {
  "neovim/nvim-lspconfig",
  lazy = false,
  dependencies = { "b0o/schemastore.nvim" },
}
