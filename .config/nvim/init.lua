-- Leaders must be defined before plugins are loaded.
vim.g.mapleader = ";"
vim.g.maplocalleader = ";"

-- netrwPlugin is disabled in config.lazy, so netrw never creates the
-- FileExplorer augroup. nvim-tree clears it on setup and errors with E216
-- ("No such group or event: FileExplorer") unless the group already exists.
vim.api.nvim_create_augroup("FileExplorer", { clear = false })

-- nvim ships both ftplugin/markdown.vim and ftplugin/markdown.lua mapping [[/]].
-- Both append to b:undo_ftplugin, so on the second FileType event the mappings
-- are already gone and "nunmap" raises E31. Let only the Lua one define them.
vim.g.no_markdown_maps = true

require("config.env")
require("config.options")
require("config.keymaps")
require("config.autocmds")
require("config.commands")
require("config.lazy")
require("config.lsp")
