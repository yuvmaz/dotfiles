local api = vim.api

local function shell_command(args)
  return table.concat(vim.tbl_map(vim.fn.shellescape, args), " ")
end

local function open_terminal(args, opts)
  opts = opts or {}
  if opts.layout == "tab" then
    vim.cmd("tabnew")
  else
    vim.cmd("botright 12split")
  end
  vim.cmd.terminal(shell_command(args))
  vim.b.pyrun_closable = true
end

api.nvim_create_user_command("Format", function()
  require("conform").format({ async = true, lsp_format = "fallback" })
end, { desc = "Format buffer (conform, LSP fallback)" })

api.nvim_create_user_command("Fold", function(cmd)
  if vim.wo.foldmethod == "manual" then
    vim.wo.foldmethod = "expr"
    vim.wo.foldexpr = "v:lua.vim.lsp.foldexpr()"
  end

  vim.cmd("normal! zM")
  local level = tonumber(cmd.args or "")
  if level then
    vim.wo.foldlevel = level
  end
end, { nargs = "?", desc = "Fold buffer (close all folds)" })

api.nvim_create_user_command("OR", function()
  vim.lsp.buf.code_action({ context = { only = { "source.organizeImports" } }, apply = true })
end, { desc = "Organize imports" })

local py_commands = api.nvim_create_augroup("PyCommands", { clear = true })
local terminal_close = api.nvim_create_augroup("PyRunTermClose", { clear = true })

api.nvim_create_autocmd("TermClose", {
  group = terminal_close,
  callback = function(args)
    if not api.nvim_buf_is_valid(args.buf) or not vim.b[args.buf].pyrun_closable then
      return
    end

    vim.b[args.buf].pyrun_closable = false
    local code = vim.v.event.status
    vim.schedule(function()
      if not api.nvim_buf_is_valid(args.buf) then
        return
      end

      vim.keymap.set({ "n", "t" }, "<CR>", "<cmd>bd!<CR>", {
        buffer = args.buf,
        silent = true,
        desc = "Close finished run",
      })
      api.nvim_echo({ { string.format("[Exited %d -- Press ENTER to close]", code), "MoreMsg" } }, false, {})
    end)
  end,
})

api.nvim_create_autocmd("FileType", {
  group = py_commands,
  pattern = "python",
  callback = function()
    api.nvim_buf_create_user_command(0, "PyRun", function(cmd)
      open_terminal(vim.list_extend({ "python", vim.fn.expand("%:p") }, cmd.fargs), { layout = "tab" })
    end, { nargs = "*", desc = "Run current python file" })

    api.nvim_buf_create_user_command(0, "PyDebug", function(cmd)
      open_terminal(vim.list_extend({ "python", "-m", "pdb", vim.fn.expand("%:p") }, cmd.fargs), { layout = "tab" })
    end, { nargs = "*", desc = "Debug current python file" })

    api.nvim_buf_create_user_command(0, "PyTest", function(cmd)
      open_terminal(vim.list_extend({ "python", "-m", "pytest" }, cmd.fargs))
    end, { nargs = "*", desc = "Run pytest" })

    api.nvim_buf_create_user_command(0, "Pydoc", function(cmd)
      local word = cmd.args ~= "" and cmd.args or vim.fn.expand("<cword>")
      vim.cmd("!" .. shell_command({ "python3", "-c", "import pydoc, sys; pydoc.help(sys.argv[1])", word }))
    end, { nargs = "?", desc = "Show Python docs for word under cursor" })
  end,
})
