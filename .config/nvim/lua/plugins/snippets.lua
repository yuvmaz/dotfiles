-- Phase 1: keep vimrc snippet engines working (<c-j>/<c-k> triggers preserved)
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
}
