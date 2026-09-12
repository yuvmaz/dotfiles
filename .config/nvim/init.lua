-- leader must be set before lazy/plugins load (kept ";" from vimrc)
vim.g.mapleader = ";"
vim.g.maplocalleader = ";"

require("config.env")
require("config.options")
require("config.keymaps")
require("config.autocmds")
require("config.commands")
require("config.lazy")
require("config.lsp")
