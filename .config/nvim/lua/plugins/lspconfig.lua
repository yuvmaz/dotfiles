-- LSP client configs live in lua/config/lsp.lua; schemastore feeds jsonls/yamlls
return {
  "neovim/nvim-lspconfig",
  lazy = false,
  dependencies = { "b0o/schemastore.nvim" },
}
