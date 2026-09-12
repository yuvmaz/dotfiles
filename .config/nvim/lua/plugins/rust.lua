-- rust.vim + vim-rustfmt -> rustaceanvim (owns Rust; lsp.lua skips rust_analyzer)
return {
  "mrcjkb/rustaceanvim",
  version = "^5",
  lazy = false,
  init = function()
    vim.g.rustaceanvim = {
      server = {
        settings = {
          ["rust-analyzer"] = {
            procMacro = { enable = true }, -- ported from coc-settings.json
            cargo = { loadOutDirsFromCheck = true },
          },
        },
      },
    }
  end,
}
