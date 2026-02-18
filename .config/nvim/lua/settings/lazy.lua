-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
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

-- Load all plugin specs from plugins directory
local plugins = {}
local plugin_dir = vim.fn.stdpath("config") .. "/lua/settings/plugins"
local plugin_files = vim.fn.globpath(plugin_dir, "*.lua", false, true)

for _, filepath in ipairs(plugin_files) do
  local filename = vim.fn.fnamemodify(filepath, ":t")
  local plugin_name = filename:gsub("%.lua$", "")
  local ok, plugin_spec = pcall(require, "settings.plugins." .. plugin_name)
  if ok and plugin_spec then
    table.insert(plugins, plugin_spec)
  end
end

-- Setup lazy.nvim
require("lazy").setup(plugins, {
  defaults = {
    lazy = false,
  },
  install = {
    missing = true,
  },
  checker = {
    enabled = true,
    notify = false,
  },
  performance = {
    rtp = {
      disabled_plugins = {
        "gzip",
        "matchit",
        "matchparen",
        "netrw",
        "netrwPlugin",
        "tarPlugin",
        "tohtml",
        "tutor",
        "zipPlugin",
      },
    },
  },
})
