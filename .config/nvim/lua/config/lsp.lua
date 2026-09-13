-- Native LSP replacing coc.nvim (vimrc:56-195). Rust is handled by rustaceanvim.
-- Server configs live in lsp-servers.lua (loaded here).
require("config.lsp-servers")

vim.diagnostic.config({
  virtual_text = true,
  signs = true,
  underline = true,
  update_in_insert = false,
  severity_sort = true,
  float = { border = "rounded", source = "always" },
})

local hl = vim.api.nvim_create_augroup("LspDocHighlight", { clear = true })

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
    -- [d/]d are Nvim built-ins; [g/]g kept for vimrc muscle memory
    vim.keymap.set("n", "[g", vim.diagnostic.goto_prev, opts)
    vim.keymap.set("n", "]g", vim.diagnostic.goto_next, opts)
    vim.keymap.set("n", "<leader>rn", b.rename, opts)
    local format = function()
      require("conform").format({ async = true, lsp_fallback = true })
    end
    vim.keymap.set("n", "<leader>f", format, opts)
    vim.keymap.set("x", "<leader>f", format, opts) -- vimrc xmap ;f format-selected
    vim.keymap.set("n", "<leader>ca", b.code_action, opts)
    -- vimrc ;a (codeaction-selected, normal+visual) and ;qf (fix-current)
    vim.keymap.set({ "n", "x" }, "<leader>a", b.code_action, opts)
    vim.keymap.set("n", "<leader>as", function() -- vimrc ;as codeaction-source
      b.code_action({ context = { only = { "source" } } })
    end, opts)
    vim.keymap.set("n", "<leader>qf", function()
      b.code_action({ apply = true, context = { only = { "quickfix" } } })
    end, opts)
    -- vimrc ;r (refactor) and ;cl (codelens)
    vim.keymap.set({ "n", "x" }, "<leader>r", function()
      b.code_action({ context = { only = { "refactor" } } })
    end, opts)
    vim.keymap.set("n", "<leader>cl", vim.lsp.codelens.run, opts)
    vim.keymap.set("n", "<leader>e", vim.diagnostic.open_float, opts)
    vim.keymap.set("n", "<leader>oi", function()
      b.code_action({ context = { only = { "source.organizeImports" } }, apply = true })
    end, opts)

    -- Port of vimrc CursorHold highlight (coc highlight refs).
    local client = vim.lsp.get_client_by_id(args.data.client_id)
    if client and client.server_capabilities.documentHighlightProvider then
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
