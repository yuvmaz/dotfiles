-- Port of vimrc basic settings (vimrc:4-12,37-43,225-226)
-- Deleted as Nvim defaults: nocompatible, filetype plugin indent on, syntax on.
local opt = vim.opt

opt.number = true
opt.relativenumber = false
opt.hidden = true
opt.updatetime = 300 -- kept from vimrc (was 300)
opt.signcolumn = "yes"
opt.encoding = "utf-8"
opt.fileencoding = "utf-8"
opt.backspace = { "indent", "eol", "start" }
opt.mouse = "a"

opt.tabstop = 4
opt.softtabstop = 4
opt.shiftwidth = 4
opt.expandtab = true
opt.smartindent = true

opt.wrap = false
opt.scrolloff = 8
opt.colorcolumn = "80"

opt.termguicolors = true -- required for tokyonight
opt.hlsearch = false
opt.incsearch = true

opt.undodir = os.getenv("HOME") .. "/.vim/undodir"
opt.undofile = true

opt.completeopt = { "menu", "menuone", "noselect" }
