-- fzf kept (replaces fzf + fzf.vim). fd comes from mise shims.
return {
  "ibhagwan/fzf-lua",
  dependencies = { "nvim-tree/nvim-web-devicons" },
  config = function()
    local fzf = require("fzf-lua")
    fzf.setup({
      fzf_opts = { ["--bind"] = "tab:down,shift-tab:up" }, -- port of $FZF_DEFAULT_OPTS
    })
    local map = vim.keymap.set
    -- Home (~) is itself a git repo whose .gitignore is "*", so fd/rg
    -- return nothing under it. Disregard gitignore ONLY when the picker's
    -- cwd is at/under $HOME and the nearest repo root is $HOME itself;
    -- real projects (e.g. ~/repos/foo) keep respecting their own gitignore.
    -- Per-session override inside any picker: <A-i> toggles ignore.
    local home = vim.fn.expand("~")
    local home_repo_cache = {}
    local function home_repo_cwd()
      local cwd = vim.fn.getcwd()
      if cwd ~= home and cwd:sub(1, #home + 1) ~= home .. "/" then
        return false
      end
      if home_repo_cache[cwd] == nil then
        local out = vim.fn.systemlist({ "git", "-C", cwd, "rev-parse", "--show-toplevel" })
        home_repo_cache[cwd] = (vim.v.shell_error == 0 and out[1] == home)
      end
      return home_repo_cache[cwd]
    end

    -- Heavy home-dir junk, excluded only in the no-ignore branch (projects
    -- keep their own gitignore behavior untouched).
    local home_excludes = {
      "miniconda3", "Library", ".cache", ".npm", ".cargo", "node_modules",
      "__pycache__", ".Trash", "VirtualBox VMs", ".tvm",
      "*.qcow2", "*.iso", "*.dmg",
    }
    local function home_fd_opts()
      local base = require("fzf-lua.defaults").defaults.files.fd_opts
      local parts = { base, "--hidden", "--no-ignore-vcs" }
      for _, pat in ipairs(home_excludes) do
        parts[#parts + 1] = "--exclude " .. vim.fn.shellescape(pat)
      end
      return table.concat(parts, " ")
    end
    local function home_rg_opts()
      local base = require("fzf-lua.defaults").defaults.grep.rg_opts
      local parts = { base, "--hidden", "--no-ignore-vcs", "-g", vim.fn.shellescape("!.git") }
      for _, pat in ipairs(home_excludes) do
        -- rg dir globs need /** to prune contents; file globs as-is.
        local glob = pat:find("%*") and pat or (pat .. "/**")
        parts[#parts + 1] = "-g"
        parts[#parts + 1] = vim.fn.shellescape("!" .. glob)
      end
      return table.concat(parts, " ")
    end

    map("n", ";ff", function()
      fzf.files(home_repo_cwd() and { fd_opts = home_fd_opts() } or {})
    end, { desc = "Fzf files" })
    map("n", ";fg", function()
      fzf.live_grep(home_repo_cwd() and { rg_opts = home_rg_opts() } or {})
    end, { desc = "Fzf live grep" })
    map("n", ";fb", fzf.buffers, { desc = "Fzf buffers" })
    map("n", ";gs", fzf.git_files, { desc = "Fzf git files" })
    map("n", ";fo", fzf.oldfiles, { desc = "Fzf oldfiles" })
    map("n", ";fr", fzf.resume, { desc = "Fzf resume" })

    -- CocList parity (vimrc:181-195 used literal <space>, kept as-is for muscle memory)
    map("n", "<space>a", fzf.lsp_workspace_diagnostics, { desc = "Diagnostics list" })
    map("n", "<space>e", "<cmd>Lazy<CR>", { desc = "Manage plugins (was CocList extensions)" })
    map("n", "<space>c", fzf.commands, { desc = "Command palette (was CocList commands)" })
    map("n", "<space>o", fzf.lsp_document_symbols, { desc = "Document outline" })
    map("n", "<space>s", fzf.lsp_workspace_symbols, { desc = "Workspace symbols" })
    map("n", "<space>j", "<cmd>cnext<CR>", { desc = "Next list item (was CocNext)" })
    map("n", "<space>k", "<cmd>cprev<CR>", { desc = "Prev list item (was CocPrev)" })
    map("n", "<space>p", fzf.resume, { desc = "Resume picker (was CocListResume)" })
  end,
}
