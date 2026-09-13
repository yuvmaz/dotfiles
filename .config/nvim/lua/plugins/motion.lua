-- easymotion -> flash.nvim (+ ";;" prefix aliases for muscle memory).
-- Vim used easymotion defaults with mapleader=";" so <Leader><Leader> == ";;".
-- All aliases go to flash.jump(): type the target, get labels. This is a
-- superset of the easymotion motions (one mechanism instead of 17).
-- Native f/F/t/T are additionally enhanced by flash char-mode out of the box.
local jump = function()
  require("flash").jump()
end

local keys = {
  { "s", mode = { "n", "x", "o" }, jump, desc = "Flash jump" },
  { "S", mode = { "n", "x", "o" }, function() require("flash").treesitter() end, desc = "Flash treesitter" },
}
for _, k in ipairs({ "f","F","t","T","s","w","W","b","B","e","E","ge","gE","j","k","n","N" }) do
  keys[#keys + 1] = { ";;" .. k, mode = { "n", "x", "o" }, jump, desc = "Flash jump (easymotion ;;" .. k .. ")" }
end

return {
  "folke/flash.nvim",
  event = "VeryLazy",
  opts = {},
  keys = keys,
}
