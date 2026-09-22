local opt = vim.opt

opt.number = true
opt.updatetime = 300
opt.timeoutlen = 300
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

opt.termguicolors = true
opt.guifont = "JetBrainsMono Nerd Font Mono:h12"
opt.hlsearch = false
opt.incsearch = true

opt.undodir = vim.fn.stdpath("state") .. "/undo"
opt.undofile = true

opt.completeopt = { "menu", "menuone", "noselect" }
