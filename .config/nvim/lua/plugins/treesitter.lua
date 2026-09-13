-- Tree-sitter (replaces syntax on + filetype plugin indent on)
return {
  "nvim-treesitter/nvim-treesitter",
  branch = "main",
  lazy = false,
  build = ":TSUpdate",
  config = function()
    require("nvim-treesitter").setup({
      ensure_installed = require("config.servers").parsers,
      auto_install = false, -- parsers only from servers.lua (deterministic)
    })
    -- main branch: setup() only handles install lists. Highlighting and
    -- indenting need an explicit per-buffer start (silently ignored
    -- highlight/indent keys were removed). indentexpr only when a parser
    -- exists, so parser-less buffers (fzf/fugitive/terminal) are untouched.
    local ts_start = vim.api.nvim_create_augroup("TreesitterStart", { clear = true })
    vim.api.nvim_create_autocmd("FileType", {
      group = ts_start,
      callback = function(args)
        local buf = args.buf
        if not vim.treesitter.highlighter.active[buf] then
          pcall(vim.treesitter.start, buf)
        end
        if vim.treesitter.highlighter.active[buf] then
          vim.bo[buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
        end
      end,
    })
  end,
}
