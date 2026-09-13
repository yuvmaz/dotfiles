-- fzf kept (replaces fzf + fzf.vim). fd comes from mise shims.
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

    map("n", ";ff", function()
      fzf.files(fzf_home.repo_cwd() and { fd_opts = fzf_home.fd_opts() } or {})
    end, { desc = "Fzf files" })
    map("n", ";fg", function()
      fzf.live_grep(fzf_home.repo_cwd() and { rg_opts = fzf_home.rg_opts() } or {})
    end, { desc = "Fzf live grep" })
    map("n", ";fb", fzf.buffers, { desc = "Fzf buffers" })
    map("n", ";gs", fzf.git_files, { desc = "Fzf git files" })
    map("n", ";fo", fzf.oldfiles, { desc = "Fzf oldfiles" })
    map("n", ";fr", fzf.resume, { desc = "Fzf resume" })

    -- CocList parity (vimrc:181-195). Ported to ;<space>* to free plain Space.
    map("n", ";<space>a", fzf.lsp_workspace_diagnostics, { desc = "Diagnostics list" })
    map("n", ";<space>e", "<cmd>Lazy<CR>", { desc = "Manage plugins (was CocList extensions)" })
    map("n", ";<space>c", fzf.commands, { desc = "Command palette (was CocList commands)" })
    map("n", ";<space>o", fzf.lsp_document_symbols, { desc = "Document outline" })
    map("n", ";<space>s", fzf.lsp_workspace_symbols, { desc = "Workspace symbols" })
    map("n", ";<space>j", "<cmd>cnext<CR>", { desc = "Next list item (was CocNext)" })
    map("n", ";<space>k", "<cmd>cprev<CR>", { desc = "Prev list item (was CocPrev)" })
    map("n", ";<space>p", fzf.resume, { desc = "Resume picker (was CocListResume)" })
  end,
}
