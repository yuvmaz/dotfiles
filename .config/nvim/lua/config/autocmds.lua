local api = vim.api
local group = api.nvim_create_augroup("CoreConfig", { clear = true })
local env = require("config.env")

api.nvim_create_autocmd("TextYankPost", {
  group = group,
  callback = function()
    vim.highlight.on_yank({ timeout = 200 })
  end,
})

api.nvim_create_autocmd("FileType", {
  group = group,
  pattern = "python",
  callback = function()
    vim.opt_local.expandtab = true
    vim.opt_local.tabstop = 4
    vim.opt_local.shiftwidth = 4
    vim.opt_local.softtabstop = 4
    vim.opt_local.foldmethod = "indent"
  end,
})

api.nvim_create_autocmd("FileType", {
  group = group,
  pattern = "go",
  callback = function()
    vim.opt_local.expandtab = false
    vim.opt_local.tabstop = 4
    vim.opt_local.shiftwidth = 4
    vim.opt_local.softtabstop = 4
  end,
})

api.nvim_create_autocmd({ "VimEnter", "BufEnter", "DirChanged" }, {
  group = group,
  callback = function(args)
    env.activate_python_env(args.buf)
  end,
})
