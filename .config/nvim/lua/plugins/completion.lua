-- Completion replacing coc#pum Tab/S-Tab/CR/C-space (vimrc:56-77)
return {
  "saghen/blink.cmp",
  version = "1.*",
  dependencies = {
    {
      "saghen/blink.compat",
      version = "2.*",
      opts = {},
    },
    "L3MON4D3/LuaSnip",
    "rafamadriz/friendly-snippets",
  },
  opts = {
    compat = {
      "avante_commands",
      "avante_mentions",
      "avante_files",
      "avante_shortcuts",
    },
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
    sources = {
      default = {
        "lsp",
        "path",
        "snippets",
        "buffer",
        "avante_commands",
        "avante_mentions",
        "avante_shortcuts",
        "avante_files",
      },
      providers = {
        avante_commands = {
          name = "avante_commands",
          module = "blink.compat.source",
          score_offset = 90,
          opts = {},
        },
        avante_files = {
          name = "avante_files",
          module = "blink.compat.source",
          score_offset = 100,
          opts = {},
        },
        avante_mentions = {
          name = "avante_mentions",
          module = "blink.compat.source",
          score_offset = 1000,
          opts = {},
        },
        avante_shortcuts = {
          name = "avante_shortcuts",
          module = "blink.compat.source",
          score_offset = 1000,
          opts = {},
        },
      },
    },
    fuzzy = { implementation = "prefer_rust_with_warning" },
  },
  opts_extend = { "sources.default" },
}
