require("config.lsp-servers")

vim.diagnostic.config({
  virtual_text = false,
  signs = true,
  underline = true,
  update_in_insert = false,
  severity_sort = true,
  float = { border = "rounded", source = "always" },
})

local api = vim.api
local diagnostic_group = api.nvim_create_augroup("LspDiagnosticFloat", { clear = true })
local highlight_group = api.nvim_create_augroup("LspDocumentHighlight", { clear = true })
local diagnostic_windows = {}
local hover_window

local function window_is_open(window)
  return window and api.nvim_win_is_valid(window)
end

local function show_diagnostics(args)
  if window_is_open(hover_window) or window_is_open(diagnostic_windows[args.buf]) then
    return
  end

  local _, window = vim.diagnostic.open_float(args.buf, {
    focusable = false,
    close_events = { "CursorMoved", "InsertEnter", "BufHidden" },
  })
  diagnostic_windows[args.buf] = window
end

local function show_hover(bufnr)
  if window_is_open(diagnostic_windows[bufnr]) then
    api.nvim_win_close(diagnostic_windows[bufnr], true)
    diagnostic_windows[bufnr] = nil
  end
  if window_is_open(hover_window) then
    api.nvim_win_close(hover_window, true)
    hover_window = nil
  end

  local client
  for _, candidate in ipairs(vim.lsp.get_clients({ bufnr = bufnr })) do
    if candidate:supports_method("textDocument/hover", bufnr) then
      client = candidate
      break
    end
  end
  if not client then
    return
  end

  local params = vim.lsp.util.make_position_params(0, client.offset_encoding)
  client:request("textDocument/hover", params, function(err, result)
    if err then
      vim.notify(err.message, vim.log.levels.WARN)
      return
    end
    if not result or not result.contents then
      return
    end

    local lines = vim.lsp.util.convert_input_to_markdown_lines(result.contents)
    while lines[1] == "" do
      table.remove(lines, 1)
    end
    while lines[#lines] == "" do
      table.remove(lines)
    end
    if vim.tbl_isempty(lines) then
      return
    end

    local _, window = vim.lsp.util.open_floating_preview(lines, "markdown", {
      border = "rounded",
      relative = "editor",
      anchor = "SE",
      row = vim.o.lines - 2,
      col = vim.o.columns - 2,
    })
    hover_window = window
  end, bufnr)
end

local function set_lsp_keymaps(bufnr)
  local opts = { buffer = bufnr, silent = true }
  local map = vim.keymap.set
  local lsp = vim.lsp.buf

  map("n", "gd", lsp.definition, opts)
  map("n", "gD", lsp.declaration, opts)
  map("n", "gy", lsp.type_definition, opts)
  map("n", "gi", lsp.implementation, opts)
  map("n", "gr", lsp.references, opts)
  map("n", "K", function()
    show_hover(bufnr)
  end, opts)
  map("n", "[g", function()
    vim.diagnostic.jump({ count = -1 })
  end, opts)
  map("n", "]g", function()
    vim.diagnostic.jump({ count = 1 })
  end, opts)
  map("n", "<leader>rn", lsp.rename, opts)

  local format = function()
    require("conform").format({ async = true, lsp_format = "fallback" })
  end
  map({ "n", "x" }, "<leader>f", format, opts)
  map("n", "<leader>ca", lsp.code_action, opts)
  map({ "n", "x" }, "<leader>a", lsp.code_action, opts)
  map("n", "<leader>as", function()
    lsp.code_action({ context = { only = { "source" } } })
  end, opts)
  map("n", "<leader>qf", function()
    lsp.code_action({ apply = true, context = { only = { "quickfix" } } })
  end, opts)
  map({ "n", "x" }, "<leader>r", function()
    lsp.code_action({ context = { only = { "refactor" } } })
  end, opts)
  map("n", "<leader>cl", vim.lsp.codelens.run, opts)
  map("n", "<leader>e", vim.diagnostic.open_float, opts)
  map("n", "<leader>oi", function()
    lsp.code_action({ context = { only = { "source.organizeImports" } }, apply = true })
  end, opts)
end

api.nvim_create_autocmd("LspAttach", {
  callback = function(args)
    pcall(vim.lsp.inlay_hint.enable, true, { bufnr = args.buf })
    set_lsp_keymaps(args.buf)

    api.nvim_clear_autocmds({ group = diagnostic_group, buffer = args.buf })
    api.nvim_create_autocmd("CursorHold", {
      group = diagnostic_group,
      buffer = args.buf,
      callback = function()
        show_diagnostics(args)
      end,
    })

    local client = vim.lsp.get_client_by_id(args.data.client_id)
    if client and client.server_capabilities.documentHighlightProvider then
      api.nvim_clear_autocmds({ group = highlight_group, buffer = args.buf })
      api.nvim_create_autocmd("CursorHold", {
        group = highlight_group,
        buffer = args.buf,
        callback = vim.lsp.buf.document_highlight,
      })
      api.nvim_create_autocmd("CursorMoved", {
        group = highlight_group,
        buffer = args.buf,
        callback = vim.lsp.buf.clear_references,
      })
    end
  end,
})
