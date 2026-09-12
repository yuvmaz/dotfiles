-- Bootstrap folke/lazy.nvim and load every spec in lua/plugins/*.lua
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.uv.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable",
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
  spec = { { import = "plugins" } },
  install = { missing = true, colorscheme = { "tokyonight" } },
  checker = { enabled = false },
  performance = {
    rtp = {
      disabled_plugins = { "gzip", "matchit", "matchparen", "tarPlugin", "tohtml", "tutor", "zipPlugin" },
    },
  },
})
