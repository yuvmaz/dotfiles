-- Manipulate surrounding delimiters (quotes, brackets, etc.)
return {
  "kylechui/nvim-surround",
  version = "^3.0.0",
  event = "VeryLazy",
  config = function()
    require("nvim-surround").setup({
      -- Uses sensible defaults, see plugin docs for customization
    })
  end,
}
