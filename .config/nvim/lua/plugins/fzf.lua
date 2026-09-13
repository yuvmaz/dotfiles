return {
  "ibhagwan/fzf-lua",
  dependencies = { "nvim-tree/nvim-web-devicons" },
  config = function()
    local fzf = require("fzf-lua")
    local fzf_home = require("util.fzf-home")
    fzf.setup({
      fzf_opts = { ["--bind"] = "tab:down,shift-tab:up" },
    })
    local map = vim.keymap.set

    map("n", "<leader>ff", function()
      fzf.files(fzf_home.repo_cwd() and { fd_opts = fzf_home.fd_opts() } or {})
    end, { desc = "Fzf files" })
    map("n", "<leader>fg", function()
      fzf.live_grep(fzf_home.repo_cwd() and { rg_opts = fzf_home.rg_opts() } or {})
    end, { desc = "Fzf live grep" })
    map("n", "<leader>fb", fzf.buffers, { desc = "Fzf buffers" })
    map("n", "<leader>gs", fzf.git_files, { desc = "Fzf git files" })
    map("n", "<leader>fo", fzf.oldfiles, { desc = "Fzf oldfiles" })
    map("n", "<leader>fr", fzf.resume, { desc = "Fzf resume" })

    map("n", "<leader><space>a", fzf.lsp_workspace_diagnostics, { desc = "Diagnostics list" })
    map("n", "<leader><space>e", "<cmd>Lazy<CR>", { desc = "Manage plugins" })
    map("n", "<leader><space>c", fzf.commands, { desc = "Command palette" })
    map("n", "<leader><space>o", fzf.lsp_document_symbols, { desc = "Document outline" })
    map("n", "<leader><space>s", fzf.lsp_workspace_symbols, { desc = "Workspace symbols" })
    map("n", "<leader><space>j", "<cmd>cnext<CR>", { desc = "Next quickfix item" })
    map("n", "<leader><space>k", "<cmd>cprev<CR>", { desc = "Previous quickfix item" })
    map("n", "<leader><space>p", fzf.resume, { desc = "Resume picker" })
  end,
}
