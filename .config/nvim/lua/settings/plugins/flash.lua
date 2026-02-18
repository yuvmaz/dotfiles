-- File: lua/plugins/flash.lua
-- Plugin config for flash.nvim with EasyMotion-style mappings

return {
  "folke/flash.nvim",
  event = "VeryLazy",
  opts = {},
  config = function()
    local flash = require("flash")

    -- EasyMotion-style single-character jump across buffer
    vim.keymap.set("n", "<Leader><Leader>f", function()
      flash.jump({
        search = { mode = "char", multi_line = true },
        label = { before = false, after = true, uppercase = true },
      })
    end, { desc = "EasyMotion f style jump (buffer-wide)" })

    vim.keymap.set("n", "<Leader><Leader>F", function()
      flash.jump({
        search = { mode = "char", backward = true, multi_line = true },
        label = { before = false, after = true, uppercase = true },
      })
    end, { desc = "EasyMotion F style jump (buffer-wide)" })

    -- EasyMotion-style 't' and 'T' motions (jump *before* the target char)
    vim.keymap.set("n", "<Leader><Leader>t", function()
      flash.jump({
        search = { mode = "char", multi_line = true },
        label = { before = true, after = false, uppercase = true },
      })
    end, { desc = "EasyMotion t style jump (buffer-wide)" })

    vim.keymap.set("n", "<Leader><Leader>T", function()
      flash.jump({
        search = { mode = "char", backward = true, multi_line = true },
        label = { before = true, after = false, uppercase = true },
      })
    end, { desc = "EasyMotion T style jump (buffer-wide)" })

    -- EasyMotion-style word motions
    vim.keymap.set("n", "<Leader><Leader>w", function()
      flash.jump({
        search = { mode = "word", multi_line = true },
        label = { before = false, after = true, uppercase = true },
      })
    end, { desc = "EasyMotion w style jump (buffer-wide)" })

    vim.keymap.set("n", "<Leader><Leader>e", function()
      flash.jump({
        search = { mode = "end", multi_line = true },
        label = { before = false, after = true, uppercase = true },
      })
    end, { desc = "EasyMotion e style jump (buffer-wide)" })
  end,
}

