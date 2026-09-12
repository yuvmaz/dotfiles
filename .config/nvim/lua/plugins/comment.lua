-- nerdcommenter -> Comment.nvim
return {
  "numToStr/Comment.nvim",
  event = "VeryLazy",
  config = function()
    require("Comment").setup()
    local map = vim.keymap.set
    map("n", ";cc", function()
      require("Comment.api").toggle.linewise.current()
    end, { desc = "Comment line" })
    map("v", ";cc", "<ESC><cmd>lua require('Comment.api').toggle.linewise(vim.fn.visualmode())<CR>", { desc = "Comment selection" })
    -- NERDCommenter parity: <leader>c<space> toggles comment (vim relied on defaults)
    map("n", ";c<space>", function()
      require("Comment.api").toggle.linewise.current()
    end, { desc = "Toggle comment line" })
    map("v", ";c<space>", "<ESC><cmd>lua require('Comment.api').toggle.linewise(vim.fn.visualmode())<CR>", { desc = "Toggle comment selection" })
    -- NERDCommenter parity: ;cm blockwise comment
    map("n", ";cm", function()
      require("Comment.api").toggle.blockwise.current()
    end, { desc = "Block comment line" })
    map("v", ";cm", "<ESC><cmd>lua require('Comment.api').toggle.blockwise(vim.fn.visualmode())<CR>", { desc = "Block comment selection" })
    -- NERDCommenter parity: ;cu uncomment (vim relied on defaults)
    map("n", ";cu", function()
      require("Comment.api").uncomment.linewise.current()
    end, { desc = "Uncomment line" })
    map("v", ";cu", "<ESC><cmd>lua require('Comment.api').uncomment.linewise(vim.fn.visualmode())<CR>", { desc = "Uncomment selection" })
    -- NERDCommenter parity: ;c$ to-EOL and ;cA append (normal-only, like NERD)
    map("n", ";c$", function()
      require("Comment.api").insert.linewise.eol()
    end, { desc = "Comment to end of line" })
    map("n", ";cA", function()
      require("Comment.api").insert.linewise.eol()
    end, { desc = "Append comment at EOL" })
    -- NOTE: NERD ;cn/;ci/;cs/;cy/;cl/;cb/;ca (nested/invert/sexy/yank/align/altdelims)
    -- have no Comment.nvim counterpart and are intentionally left unmapped.
  end,
}
