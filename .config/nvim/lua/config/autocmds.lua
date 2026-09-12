-- Port of vimrc autocmds (python/go ft, highlight). pumvisible cleanup deleted (N/A).
local group = vim.api.nvim_create_augroup("VimrcPort", { clear = true })

vim.api.nvim_create_autocmd("TextYankPost", {
  group = group,
  callback = function()
    vim.highlight.on_yank({ timeout = 200 })
  end,
})

-- vimrc: python expandtab 4-space + indent fold (omnifunc not needed, LSP provides it)
vim.api.nvim_create_autocmd("FileType", {
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

-- vimrc: go 4-space tabs
vim.api.nvim_create_autocmd("FileType", {
  group = group,
  pattern = "go",
  callback = function()
    vim.opt_local.tabstop = 4
    vim.opt_local.shiftwidth = 4
    vim.opt_local.softtabstop = 4
  end,
})
