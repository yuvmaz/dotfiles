local ok_store, schemastore = pcall(require, "schemastore")

vim.lsp.config("*", {
  capabilities = require("blink.cmp").get_lsp_capabilities(),
})

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
  -- Split: ruff = lint / quick-fix / source.organizeImports (code action,
  -- no setting needed on the new ruff server); formatting via conform
  -- ruff_format; types/hover/completion live on basedpyright.
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

vim.lsp.config("gopls", {
  cmd = { "gopls" },
  filetypes = { "go" },
  -- Same home-repo ".git" exclusion as basedpyright above.
  root_markers = { "go.mod", "go.work" },
})

-- rust_analyzer is managed by rustaceanvim.
vim.lsp.enable(require("config.servers").lsp_servers)
