return {
  "SirVer/ultisnips",
  lazy = false,
  dependencies = { "honza/vim-snippets" },
  init = function()
    vim.g.UltiSnipsExpandTrigger = "<c-j>"
    vim.g.UltiSnipsJumpForwardTrigger = "<c-j>"
    vim.g.UltiSnipsJumpBackwardTrigger = "<c-k>"
    vim.g.UltiSnipsEditSplit = "vertical"
  end,
  config = function()
    vim.keymap.set("i", "<C-k>", "<C-r>=UltiSnips#JumpBackwards()<CR>", {
      silent = true,
      desc = "Jump to previous snippet field",
    })
    vim.keymap.set("s", "<C-k>", "<Esc><cmd>call UltiSnips#JumpBackwards()<CR>", {
      silent = true,
      desc = "Jump to previous snippet field",
    })
  end,
}
