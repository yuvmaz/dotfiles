-- Mason owns LSP servers only (mise owns fd/prettier/lua-language-server binaries)
return {
  "williamboman/mason.nvim",
  lazy = false,
  dependencies = { "williamboman/mason-lspconfig.nvim" },
  config = function()
    require("mason").setup()
    require("mason-lspconfig").setup({
      ensure_installed = require("config.servers").mason_ensure,
      automatic_installation = true,
      -- false: we enable servers explicitly in lua/config/lsp.lua.
      -- true would auto-enable every mason package (incl. stale pyright),
      -- causing duplicate clients (basedpyright + pyright).
      automatic_enable = false,
    })
  end,
}
