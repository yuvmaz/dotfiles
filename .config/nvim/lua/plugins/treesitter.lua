-- Tree-sitter (replaces syntax on + filetype plugin indent on)
return {
  "nvim-treesitter/nvim-treesitter",
  branch = "main",
  lazy = false,
  build = ":TSUpdate",
  config = function()
    require("nvim-treesitter").setup({
      ensure_installed = require("config.servers").parsers,
      auto_install = true,
      highlight = { enable = true },
      indent = { enable = true },
    })
  end,
}
