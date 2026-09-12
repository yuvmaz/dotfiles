-- Native LSP replacing coc.nvim (vimrc:56-195). Rust is handled by rustaceanvim.
vim.o.updatetime = 300

vim.diagnostic.config({
  virtual_text = true,
  signs = true,
  underline = true,
  update_in_insert = false,
  severity_sort = true,
  float = { border = "rounded", source = "always" },
})

vim.api.nvim_create_autocmd("LspAttach", {
  callback = function(args)
    local opts = { buffer = args.buf, silent = true }
    pcall(vim.lsp.inlay_hint.enable, true, { bufnr = args.buf })

    local b = vim.lsp.buf
    vim.keymap.set("n", "gd", b.definition, opts)
    vim.keymap.set("n", "gD", b.declaration, opts)
    vim.keymap.set("n", "gy", b.type_definition, opts) -- vimrc gy
    vim.keymap.set("n", "gi", b.implementation, opts)
    vim.keymap.set("n", "gr", b.references, opts)
    vim.keymap.set("n", "K", b.hover, opts)
    vim.keymap.set("n", "[d", vim.diagnostic.goto_prev, opts)
    vim.keymap.set("n", "]d", vim.diagnostic.goto_next, opts)
    vim.keymap.set("n", "[g", vim.diagnostic.goto_prev, opts) -- vimrc muscle memory
    vim.keymap.set("n", "]g", vim.diagnostic.goto_next, opts)
    vim.keymap.set("n", "<leader>rn", b.rename, opts)
    vim.keymap.set("n", "<leader>f", function()
      vim.lsp.buf.format({ async = true })
    end, opts)
    vim.keymap.set("x", "<leader>f", function() -- vimrc xmap ;f format-selected
      vim.lsp.buf.format({ async = true })
    end, opts)
    vim.keymap.set("n", "<leader>ca", b.code_action, opts)
    vim.keymap.set("n", "<leader>ac", b.code_action, opts) -- vimrc ;ac muscle memory
    -- vimrc ;a (codeaction-selected, normal+visual) and ;qf (fix-current)
    vim.keymap.set({ "n", "x" }, "<leader>a", b.code_action, opts)
    vim.keymap.set("n", "<leader>as", function() -- vimrc ;as codeaction-source
      b.code_action({ context = { only = { "source" } } })
    end, opts)
    vim.keymap.set("n", "<leader>qf", function()
      b.code_action({ apply = true, context = { only = { "quickfix" } } })
    end, opts)
    -- vimrc ;re/;r (refactor) and ;cl (codelens)
    vim.keymap.set({ "n", "x" }, "<leader>r", function()
      b.code_action({ context = { only = { "refactor" } } })
    end, opts)
    vim.keymap.set("n", "<leader>re", function()
      b.code_action({ context = { only = { "refactor" } } })
    end, opts)
    vim.keymap.set("n", "<leader>cl", vim.lsp.codelens.run, opts)
    vim.keymap.set("n", "<leader>e", vim.diagnostic.open_float, opts)
    vim.keymap.set("n", "<leader>oi", function()
      b.code_action({ context = { only = { "source.organizeImports" } }, apply = true })
    end, opts)

    -- Port of vimrc CursorHold highlight (coc highlight refs)
    local client = vim.lsp.get_client_by_id(args.data.client_id)
    if client and client.server_capabilities.documentHighlightProvider then
      local hl = vim.api.nvim_create_augroup("LspDocHighlight", { clear = false })
      vim.api.nvim_clear_autocmds({ group = hl, buffer = args.buf })
      vim.api.nvim_create_autocmd("CursorHold", {
        group = hl,
        buffer = args.buf,
        callback = vim.lsp.buf.document_highlight,
      })
      vim.api.nvim_create_autocmd("CursorMoved", {
        group = hl,
        buffer = args.buf,
        callback = vim.lsp.buf.clear_references,
      })
    end
  end,
})

-- Server configs (easy expansion: add entry in servers.lua + optional settings here)
local ok_store, schemastore = pcall(require, "schemastore")

vim.lsp.config("html", {
  cmd = { "vscode-html-language-server", "--stdio" },
  filetypes = { "html" },
  root_markers = { "package.json", ".git" },
})

vim.lsp.config("jsonls", {
  cmd = { "vscode-json-language-server", "--stdio" },
  filetypes = { "json", "jsonc" },
  root_markers = { "package.json", ".git" },
  settings = {
    json = {
      validate = { enable = true },
      schemas = ok_store and schemastore.json.schemas() or {},
    },
  },
})

vim.lsp.config("yamlls", {
  cmd = { "yaml-language-server", "--stdio" },
  filetypes = { "yaml", "yml" },
  root_markers = { ".git" },
  settings = {
    yaml = {
      validate = true,
      schemaStore = { enable = false, url = "" },
      schemas = ok_store and schemastore.yaml.schemas() or {},
    },
  },
})

vim.lsp.config("basedpyright", {
  cmd = { "basedpyright-langserver", "--stdio" },
  filetypes = { "python" },
  -- NOTE: no ".git" here on purpose. Home (~) is itself a git repo, so any
  -- Python file under ~ would otherwise get workspace root = ~ and
  -- basedpyright would enumerate the whole home dir (>10s warning).
  root_markers = { "pyproject.toml", "setup.py", "setup.cfg", "requirements.txt" },
})

vim.lsp.config("ruff", {
  cmd = { "ruff", "server" },
  filetypes = { "python" },
  -- Same ".git" exclusion as basedpyright above.
  root_markers = { "pyproject.toml", "ruff.toml", ".ruff.toml", "setup.py", "setup.cfg", "requirements.txt" },
  settings = { organizeImports = true },
})

vim.lsp.config("lua_ls", {
  cmd = { "lua-language-server" }, -- resolved from mise shims via config.env
  filetypes = { "lua" },
  root_markers = { ".luarc.json", ".luarc.jsonc", ".stylua.toml", "stylua.toml", ".git" },
  settings = {
    Lua = {
      runtime = { version = "LuaJIT" },
      diagnostics = { globals = { "vim" } },
      hint = { enable = true },
    },
  },
})

-- rust_analyzer intentionally NOT enabled here; mrcjkb/rustaceanvim owns Rust.
vim.lsp.enable({ "html", "jsonls", "yamlls", "basedpyright", "ruff", "lua_ls" })
