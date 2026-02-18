-- Manage LSP servers, linters, and formatters
return {
  "williamboman/mason.nvim",
  config = function()
    require("mason").setup()
  end,
}
