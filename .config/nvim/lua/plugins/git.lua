-- fugitive works as-is in Nvim, kept. Loads on any :G* command.
return {
  "tpope/vim-fugitive",
  cmd = {
    "Git", "G", "Gdiffsplit", "Gvdiffsplit", "Gw", "Gwrite", "Gread",
    "Gblame", "Gedit", "Gsplit", "Gvsplit", "Gtabedit", "Ggrep",
    "GMove", "GRename", "GDelete", "GBrowse",
  },
}
