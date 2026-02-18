-- Syntax highlighting and code parsing with treesitter
return {
  "nvim-treesitter/nvim-treesitter",
  build = ":TSUpdate",
  lazy = false,
  config = function()
    pcall(function()
      require("nvim-treesitter.config").setup({
        ensure_installed = { "lua", "vim", "json", "python", "rust", "yaml", "dockerfile", "bash" },
        highlight = {
          enable = true,
        },
        indent = {
          enable = true,
        },
      })
    end)
  end,
}
