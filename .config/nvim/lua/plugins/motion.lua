-- easymotion -> flash.nvim (+ ";;" prefix aliases for muscle memory).
-- Vim used easymotion defaults with mapleader=";" so <Leader><Leader> == ";;":
-- ;;f/F/t/T/s/w/W/b/B/e/E/ge/gE/j/k/n/N (vimrc Plug 'easymotion/vim-easymotion').
-- All aliases go to flash.jump(): type the target, get labels. This is a
-- superset of the easymotion motions (one mechanism instead of 17).
-- Native f/F/t/T are additionally enhanced by flash char-mode out of the box.
local jump = function()
  require("flash").jump()
end

return {
  "folke/flash.nvim",
  event = "VeryLazy",
  opts = {},
  keys = {
    { "s", mode = { "n", "x", "o" }, jump, desc = "Flash jump" },
    { "S", mode = { "n", "x", "o" }, function() require("flash").treesitter() end, desc = "Flash treesitter" },
    { ";;f", mode = { "n", "x", "o" }, jump, desc = "Flash find char (was easymotion ;;f)" },
    { ";;F", mode = { "n", "x", "o" }, jump, desc = "Flash find char left (was easymotion ;;F)" },
    { ";;t", mode = { "n", "x", "o" }, jump, desc = "Flash till char (was easymotion ;;t)" },
    { ";;T", mode = { "n", "x", "o" }, jump, desc = "Flash till char left (was easymotion ;;T)" },
    { ";;s", mode = { "n", "x", "o" }, jump, desc = "Flash search char (was easymotion ;;s)" },
    { ";;w", mode = { "n", "x", "o" }, jump, desc = "Flash word (was easymotion ;;w)" },
    { ";;W", mode = { "n", "x", "o" }, jump, desc = "Flash WORD (was easymotion ;;W)" },
    { ";;b", mode = { "n", "x", "o" }, jump, desc = "Flash word back (was easymotion ;;b)" },
    { ";;B", mode = { "n", "x", "o" }, jump, desc = "Flash WORD back (was easymotion ;;B)" },
    { ";;e", mode = { "n", "x", "o" }, jump, desc = "Flash word end (was easymotion ;;e)" },
    { ";;E", mode = { "n", "x", "o" }, jump, desc = "Flash WORD end (was easymotion ;;E)" },
    { ";;ge", mode = { "n", "x", "o" }, jump, desc = "Flash word end back (was easymotion ;;ge)" },
    { ";;gE", mode = { "n", "x", "o" }, jump, desc = "Flash WORD end back (was easymotion ;;gE)" },
    { ";;j", mode = { "n", "x", "o" }, jump, desc = "Flash line down (was easymotion ;;j)" },
    { ";;k", mode = { "n", "x", "o" }, jump, desc = "Flash line up (was easymotion ;;k)" },
    { ";;n", mode = { "n", "x", "o" }, jump, desc = "Flash last search fwd (was easymotion ;;n)" },
    { ";;N", mode = { "n", "x", "o" }, jump, desc = "Flash last search back (was easymotion ;;N)" },
  },
}
