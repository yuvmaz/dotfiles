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
    -- NERDCommenter parity: ;c$ comments out cursor->EOL (Comment.nvim forces
    -- block delimiters on single-line partial ranges, so insert the line
    -- marker from commentstring manually), ;cA appends marker at EOL.
    map("n", ";c$", function()
      local cs = vim.bo.commentstring
      if cs == "" then
        return
      end
      local marker = vim.split(cs, "%s", { plain = true })[1]:gsub("%s+$", "")
      local col = vim.fn.col(".")
      local line = vim.fn.getline(".")
      local before, rest = line:sub(1, col - 1), line:sub(col)
      if rest:match("^" .. vim.pesc(marker) .. "%s") then
        rest = rest:gsub("^" .. vim.pesc(marker) .. "%s", "", 1)
      else
        rest = marker .. " " .. rest
      end
      vim.fn.setline(".", before .. rest)
    end, { desc = "Comment from cursor to EOL" })
    map("n", ";cA", function()
      require("Comment.api").insert.linewise.eol()
    end, { desc = "Append comment at EOL" })
    -- NOTE: NERD ;cn/;ci/;cs/;cy/;cl/;cb/;ca (nested/invert/sexy/yank/align/altdelims)
    -- have no Comment.nvim counterpart and are intentionally left unmapped.
  end,
}
