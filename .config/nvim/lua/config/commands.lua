-- Port of vimrc :Format/:Fold/:OR (vimrc:166-172) and :PyRun/:PyDebug/:PyTest (vimrc:206-208)
vim.api.nvim_create_user_command("Format", function()
  vim.lsp.buf.format({ async = true })
end, { desc = "Format buffer with LSP" })

-- Port of vimrc :Fold (CocAction fold). Native LSP has no fold action, so
-- ensure expr folding backed by the LSP foldexpr, then close all folds.
-- Optional numeric arg sets foldlevel first (e.g. :Fold 1).
vim.api.nvim_create_user_command("Fold", function(cmd)
  if vim.wo.foldmethod == "manual" then
    vim.wo.foldmethod = "expr"
    vim.wo.foldexpr = "v:lua.vim.lsp.foldexpr()"
  end
  local level = tonumber(cmd.args or "")
  if level then
    vim.wo.foldlevel = level
  end
  vim.cmd("normal! zM")
end, { nargs = "?", desc = "Fold buffer (close all folds)" })

vim.api.nvim_create_user_command("OR", function()
  vim.lsp.buf.code_action({ context = { only = { "source.organizeImports" } }, apply = true })
end, { desc = "Organize imports" })

local py = vim.api.nvim_create_augroup("PyCommands", { clear = true })

-- Press-ENTER-to-close for PyRun/PyDebug terminals (Option 2).
-- The <CR> closer is only installed when the job exits (TermClose), so Enter
-- mid-run still goes to the program (input()/pdb) untouched.
local term_close = vim.api.nvim_create_augroup("PyRunTermClose", { clear = true })
vim.api.nvim_create_autocmd("TermClose", {
  group = term_close,
  callback = function(args)
    if not vim.api.nvim_buf_is_valid(args.buf) then
      return
    end
    if not vim.b[args.buf].pyrun_closable then
      return
    end
    vim.b[args.buf].pyrun_closable = false
    local code = vim.v.event.status
    vim.schedule(function()
      if not vim.api.nvim_buf_is_valid(args.buf) then
        return
      end
      vim.keymap.set({ "n", "t" }, "<CR>", "<cmd>bd!<CR>", {
        buffer = args.buf,
        silent = true,
        desc = "Close finished run",
      })
      vim.api.nvim_echo(
        { { string.format("[Exited %d — Press ENTER to close]", code), "MoreMsg" } },
        false,
        {}
      )
    end)
  end,
})
vim.api.nvim_create_autocmd("FileType", {
  group = py,
  pattern = "python",
  callback = function()
    vim.api.nvim_buf_create_user_command(0, "PyRun", function(cmd)
      local file = vim.fn.expand("%")
      vim.cmd("terminal python " .. vim.fn.shellescape(file) .. " " .. table.concat(cmd.fargs, " "))
      vim.b.pyrun_closable = true -- current buffer is the new terminal
    end, { nargs = "*", desc = "Run current python file" })
    vim.api.nvim_buf_create_user_command(0, "PyDebug", function(cmd)
      local file = vim.fn.expand("%")
      vim.cmd("terminal python -m pdb " .. vim.fn.shellescape(file) .. " " .. table.concat(cmd.fargs, " "))
      vim.b.pyrun_closable = true
    end, { nargs = "*", desc = "Debug current python file" })
    vim.api.nvim_buf_create_user_command(0, "PyTest", function(cmd)
      vim.cmd("!python -m pytest " .. table.concat(cmd.fargs, " "))
    end, { nargs = "*", desc = "Run pytest" })
  end,
})
