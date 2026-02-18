-- Enhanced navigation with search labels and easymotion-style motions
-- Matches easymotion behavior: directional searches, no wrap-around
return {
  "folke/flash.nvim",
  event = "VeryLazy",
  config = function()
    local flash = require("flash")

    -- Setup flash with global defaults for treesitter modes
    flash.setup({
      modes = {
        treesitter = {
          jump = { autojump = false },
          highlight = { backdrop = true, matches = true },
        },
        treesitter_search = {
          jump = { autojump = false },
          highlight = { backdrop = true, matches = true },
        },
      },
    })

    -- Make flash labels more visible with bright colors
    vim.cmd([[
      highlight FlashLabel ctermfg=0 ctermbg=11 guifg=#000000 guibg=#ffff00
    ]])

    -- Helper function for label configuration
    local function label_config(before)
      return {
        before = before,
        after = not before,
        distance = true, -- closer targets first in current window
      }
    end

    -- ============================================================================
    -- CHARACTER MOTIONS: f, F, t, T
    -- Directional only, no wrap-around (matches easymotion behavior)
    -- ============================================================================

    -- f: Find character forward (inclusive, no wrap)
    vim.keymap.set({ "n", "x", "o" }, "<leader><leader>f", function()
      flash.jump({
        search = { mode = "search", forward = true, wrap = false },
        jump = { pos = "end", inclusive = true, autojump = false },
        label = label_config(false),
      })
    end, { desc = "Flash find forward" })

    -- F: Find character backward (inclusive, no wrap)
    vim.keymap.set({ "n", "x", "o" }, "<leader><leader>F", function()
      flash.jump({
        search = { mode = "search", forward = false, wrap = false },
        jump = { pos = "end", inclusive = true, autojump = false },
        label = label_config(false),
      })
    end, { desc = "Flash find backward" })

    -- t: Till character forward (exclusive, cursor before match, no wrap)
    vim.keymap.set({ "n", "x", "o" }, "<leader><leader>t", function()
      flash.jump({
        search = { mode = "search", forward = true, wrap = false },
        jump = { pos = "start", inclusive = false, autojump = false },
        label = label_config(false),
      })
    end, { desc = "Flash till forward" })

    -- T: Till character backward (exclusive, cursor before match, no wrap)
    vim.keymap.set({ "n", "x", "o" }, "<leader><leader>T", function()
      flash.jump({
        search = { mode = "search", forward = false, wrap = false },
        jump = { pos = "start", inclusive = false, autojump = false },
        label = label_config(false),
      })
    end, { desc = "Flash till backward" })

    -- ============================================================================
    -- WORD MOTIONS: w, W (start of word)
    -- Directional only, no wrap-around (matches easymotion behavior)
    -- ============================================================================

    -- w: Jump to start of next word (inclusive, no wrap)
    vim.keymap.set({ "n", "x", "o" }, "<leader><leader>w", function()
      flash.jump({
        search = { mode = "search", forward = true, wrap = false },
        pattern = [[\<]],
        jump = { pos = "end", inclusive = true, autojump = false },
        label = label_config(true),
      })
    end, { desc = "Flash word start forward" })

    -- W: Jump to start of previous word (inclusive, no wrap)
    vim.keymap.set({ "n", "x", "o" }, "<leader><leader>W", function()
      flash.jump({
        search = { mode = "search", forward = false, wrap = false },
        pattern = [[\<]],
        jump = { pos = "end", inclusive = true, autojump = false },
        label = label_config(true),
      })
    end, { desc = "Flash word start backward" })

    -- ============================================================================
    -- END-OF-WORD MOTIONS: e, E
    -- Directional only, no wrap-around (matches easymotion behavior)
    -- ============================================================================

    -- e: Jump to end of next word (inclusive, no wrap)
    vim.keymap.set({ "n", "x", "o" }, "<leader><leader>e", function()
      flash.jump({
        search = { mode = "search", forward = true, wrap = false },
        pattern = [[\>]],
        jump = { pos = "end", inclusive = true, autojump = false },
        label = label_config(true),
      })
    end, { desc = "Flash word end forward" })

    -- E: Jump to end of previous word (inclusive, no wrap)
    vim.keymap.set({ "n", "x", "o" }, "<leader><leader>E", function()
      flash.jump({
        search = { mode = "search", forward = false, wrap = false },
        pattern = [[\>]],
        jump = { pos = "end", inclusive = true, autojump = false },
        label = label_config(true),
      })
    end, { desc = "Flash word end backward" })

    -- ============================================================================
    -- ADDITIONAL USEFUL MOTIONS
    -- ============================================================================

     -- S: Treesitter navigation (structural selection)
     vim.keymap.set({ "n", "x", "o" }, "<leader><leader>s", function()
       require("flash").treesitter()
     end, { desc = "Flash treesitter" })

     -- R: Treesitter search (search with structural context)
     vim.keymap.set({ "n", "x", "o" }, "<leader><leader>r", function()
       require("flash").treesitter_search()
     end, { desc = "Flash treesitter search" })

    -- Toggle flash in search mode with Ctrl+S (useful for / and ? searches)
    vim.keymap.set("c", "<C-s>", function()
      flash.toggle()
    end, { desc = "Toggle flash search" })
  end,
}
