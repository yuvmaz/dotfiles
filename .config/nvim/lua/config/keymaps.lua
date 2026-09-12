-- Core keymaps ported from vimrc:41-49. Leader ";" is set in init.lua.
-- fzf maps live in lua/plugins/fzf.lua (after plugin loads).
local map = vim.keymap.set

map({ "i", "v" }, "kj", "<ESC>", { silent = true, desc = "Exit to normal" })

map("n", "<C-h>", "<C-w>h", { desc = "Window left" })
map("n", "<C-j>", "<C-w>j", { desc = "Window down" })
map("n", "<C-k>", "<C-w>k", { desc = "Window up" })
map("n", "<C-l>", "<C-w>l", { desc = "Window right" })
map("t", "<C-w>", [[<C-\><C-n><C-w>]], { desc = "Terminal window cmd" })
