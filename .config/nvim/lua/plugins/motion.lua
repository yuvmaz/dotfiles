local jump = function()
  require("flash").jump()
end

local keys = {
  { "s", mode = { "n", "x", "o" }, jump, desc = "Flash jump" },
  {
    "S",
    mode = { "n", "o" },
    function() require("flash").treesitter() end,
    desc = "Flash treesitter",
  },
  {
    "<leader>S",
    mode = "x",
    function() require("flash").treesitter() end,
    desc = "Flash treesitter",
  },
}
for _, key in ipairs({ "f", "F", "t", "T", "s", "w", "W", "b", "B", "e", "E", "ge", "gE", "j", "k", "n", "N" }) do
  keys[#keys + 1] = {
    "<leader><leader>" .. key,
    mode = { "n", "x", "o" },
    jump,
    desc = "Flash jump (;;" .. key .. ")",
  }
end

return {
  "folke/flash.nvim",
  event = "VeryLazy",
  opts = {},
  keys = keys,
}
