-- Completion engine with snippet support
return {
  "saghen/blink.cmp",
  dependencies = { { "SirVer/ultisnips", lazy = false }, "honza/vim-snippets", "rafamadriz/friendly-snippets" },

  -- use a release tag to download pre-built binaries
  version = "1.*",
  -- use a release tag to download pre-built binaries
  -- build from source requires nightly Rust: https://rust-lang.org/rustup/concepts/channels.html#working-with-nightly-rust
  -- build = 'cargo build --release',

  ---@module "blink.cmp"
  ---@type blink.cmp.Config
  opts = {
    snippets = { preset = 'default' },

    keymap = {
      preset = 'none',
      ['<CR>'] = { 'accept', 'fallback' },
      ['<Tab>'] = { 'select_next', 'fallback' },
      ['<S-Tab>'] = { 'select_prev', 'fallback' },
      ['<C-space>'] = { 'show_documentation',  'fallback' },
      ['<C-e>'] = { 'hide', 'fallback' },
    },

    appearance = {
      -- 'mono' for 'Nerd Font Mono' or 'normal' for 'Nerd Font'
      nerd_font_variant = "mono",
    },

    -- Only show documentation popup when manually triggered
    completion = { documentation = { auto_show = false } },

    -- Default providers for completion
    sources = {
      default = { "lsp", "path", "snippets", "buffer" },
    },

    -- Rust fuzzy matcher for better performance and typo resistance
    fuzzy = { implementation = "prefer_rust_with_warning" },
  },
  opts_extend = { "sources.default" },
}
