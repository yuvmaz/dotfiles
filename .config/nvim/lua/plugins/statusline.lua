-- vim-airline (coc statusline) -> lualine with LSP status
return {
  "nvim-lualine/lualine.nvim",
  event = "UIEnter",
  dependencies = { "nvim-tree/nvim-web-devicons" },
  opts = {
    options = { theme = "tokyonight" },
    sections = {
      lualine_c = { "filename", "lsp_status" },
    },
  },
}
