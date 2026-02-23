vim.api.nvim_create_autocmd("FileType", {
  pattern = "python",
  callback = function()
    local opts = { nargs = "*" }

    -- Run current file
    vim.api.nvim_buf_create_user_command(0, "PyRun", function(cmd)
      local file = vim.fn.expand("%")
      vim.cmd("terminal python " .. vim.fn.shellescape(file) .. " " .. table.concat(cmd.fargs, " "))
    end, opts)

    -- Debug current file (real interactive terminal for pdb)
    vim.api.nvim_buf_create_user_command(0, "PyDebug", function(cmd)
      local file = vim.fn.expand("%")
      vim.cmd("terminal python -m pdb " .. vim.fn.shellescape(file) .. " " .. table.concat(cmd.fargs, " "))
    end, opts)

    -- Run pytest
    vim.api.nvim_buf_create_user_command(0, "PyTest", function(cmd)
      vim.cmd("!python -m pytest " .. table.concat(cmd.fargs, " "))
    end, opts)
  end,
})
