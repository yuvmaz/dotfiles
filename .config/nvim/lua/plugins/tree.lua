-- NERDTree -> nvim-tree, same ";n" toggle (vimrc:42)
return {
  "nvim-tree/nvim-tree.lua",
  version = false,
  lazy = false,
  dependencies = { "nvim-tree/nvim-web-devicons" },
  config = function()
    local api = require("nvim-tree.api")
    local function on_attach(bufnr)
      api.config.mappings.default_on_attach(bufnr)
      local function opts(desc)
        return { desc = "nvim-tree: " .. desc, buffer = bufnr, noremap = true, silent = true, nowait = true }
      end
      -- vim-style directory navigation (missing from nvim-tree defaults)
      vim.keymap.set("n", "l", api.node.open.edit, opts("Open"))
      vim.keymap.set("n", "h", api.node.navigate.parent_close, opts("Close Directory"))
    end
    require("nvim-tree").setup({
      -- Your ~/.gitignore ignores everything ("*"), and nvim-tree hides
      -- gitignored files by default, which made lua/config/ etc. invisible.
      git = { ignore = false },
      filters = { dotfiles = false },
      on_attach = on_attach,
      view = { width = 30, side = "left" },
      renderer = { icons = { show = { git = true, folder = true, file = true, folder_arrow = true } } },
      actions = { open_file = { quit_on_open = false } },
    })
    vim.keymap.set("n", ";n", "<cmd>NvimTreeToggle<CR>", { noremap = true, silent = true, desc = "Toggle file tree" })
  end,
}
