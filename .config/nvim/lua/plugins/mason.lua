return {
  "mason-org/mason.nvim",
  lazy = false,
  dependencies = { "mason-org/mason-lspconfig.nvim" },
  config = function()
    require("mason").setup()
    require("mason-lspconfig").setup({
      ensure_installed = require("config.servers").mason_ensure,
      automatic_enable = false,
    })
  end,
}
