-- Completion replacing coc#pum Tab/S-Tab/CR/C-space (vimrc:56-77)
return {
  "saghen/blink.cmp",
  version = "1.*",
  dependencies = {
    "L3MON4D3/LuaSnip",
    "rafamadriz/friendly-snippets",
  },
  opts = {
    snippets = { preset = "luasnip" },
    keymap = {
      preset = "none",
      ["<CR>"] = { "accept", "fallback" },
      ["<Tab>"] = { "select_next", "fallback" },
      ["<S-Tab>"] = { "select_prev", "fallback" },
      ["<C-space>"] = { "show", "fallback" },
      ["<C-e>"] = { "hide", "fallback" },
      -- vimrc C-f/C-b float scroll parity (insert mode; normal-mode paging untouched)
      ["<C-f>"] = { "scroll_documentation_down", "fallback" },
      ["<C-b>"] = { "scroll_documentation_up", "fallback" },
    },
    appearance = { nerd_font_variant = "mono" },
    completion = { documentation = { auto_show = false } },
    sources = { default = { "lsp", "path", "snippets", "buffer" } },
    fuzzy = { implementation = "prefer_rust_with_warning" },
  },
  opts_extend = { "sources.default" },
}
