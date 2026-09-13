return {
  "numToStr/Comment.nvim",
  event = "VeryLazy",
  config = function()
    require("Comment").setup()
    local map = vim.keymap.set

    map("n", "<leader>cc", function()
      require("Comment.api").toggle.linewise.current()
    end, { desc = "Comment line" })
    map("v", "<leader>cc", "<ESC><cmd>lua require('Comment.api').toggle.linewise(vim.fn.visualmode())<CR>", {
      desc = "Comment selection",
    })
    map("n", "<leader>c<space>", function()
      require("Comment.api").toggle.linewise.current()
    end, { desc = "Toggle comment line" })
    map("v", "<leader>c<space>", "<ESC><cmd>lua require('Comment.api').toggle.linewise(vim.fn.visualmode())<CR>", {
      desc = "Toggle comment selection",
    })
    map("n", "<leader>cm", function()
      require("Comment.api").toggle.blockwise.current()
    end, { desc = "Block comment line" })
    map("v", "<leader>cm", "<ESC><cmd>lua require('Comment.api').toggle.blockwise(vim.fn.visualmode())<CR>", {
      desc = "Block comment selection",
    })
    map("n", "<leader>cu", function()
      require("Comment.api").uncomment.linewise.current()
    end, { desc = "Uncomment line" })
    map("v", "<leader>cu", "<ESC><cmd>lua require('Comment.api').uncomment.linewise(vim.fn.visualmode())<CR>", {
      desc = "Uncomment selection",
    })
    map("n", "<leader>c$", function()
      local cs = vim.bo.commentstring
      if cs == "" then
        return
      end

      local prefix, suffix = cs:match("^(.-)%%s(.-)$")
      prefix = prefix and prefix:gsub("%s+$", "") or ""
      suffix = suffix and suffix:gsub("^%s+", "") or ""
      if prefix == "" then
        return
      end

      local col = vim.fn.col(".")
      local line = vim.fn.getline(".")
      local before, rest = line:sub(1, col - 1), line:sub(col)
      local is_commented = rest:sub(1, #prefix) == prefix
        and (suffix == "" or rest:sub(-#suffix) == suffix)
      if is_commented then
        rest = rest:sub(#prefix + 1, suffix == "" and nil or -#suffix - 1)
        rest = rest:gsub("^ ", "", 1):gsub(" $", "", 1)
      else
        rest = prefix .. " " .. rest .. (suffix == "" and "" or " " .. suffix)
      end
      vim.fn.setline(".", before .. rest)
    end, { desc = "Comment from cursor to EOL" })
    map("n", "<leader>cA", function()
      require("Comment.api").insert.linewise.eol()
    end, { desc = "Append comment at EOL" })
  end,
}
