-- Port of vimrc basic settings (vimrc:4-12,37-43,225-226)
-- Deleted as Nvim defaults: nocompatible, filetype plugin indent on, syntax
-- on, hidden, encoding, fileencoding, backspace, relativenumber=false.
local opt = vim.opt

opt.number = true
opt.updatetime = 300 -- kept from vimrc (was 300)
opt.timeoutlen = 300 -- ; leader with ;;/;c/;a/;r prefixes resolves fast
opt.signcolumn = "yes"
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

opt.undodir = vim.fn.stdpath("state") .. "/undo"
opt.undofile = true

opt.completeopt = { "menu", "menuone", "noselect" }
