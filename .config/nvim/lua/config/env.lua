local M = {}

local function path_parts(path)
  if not path or path == "" then
    return {}
  end
  return vim.split(path, ":", { plain = true, trimempty = true })
end

local function remove_path_entry(path, entry)
  local out = {}
  for _, part in ipairs(path_parts(path)) do
    if part ~= entry then
      out[#out + 1] = part
    end
  end
  return table.concat(out, ":")
end

local function prepend_path_entry(entry)
  local path = remove_path_entry(vim.env.PATH or "", entry)
  vim.env.PATH = (entry == "" and "" or (entry .. ":")) .. path
end

-- Make mise-managed tools available when Neovim is not started from a shell.
local shims = vim.fn.expand("~/.local/share/mise/shims")
if vim.fn.isdirectory(shims) == 1 then
  local path = vim.env.PATH or ""
  if not path:find(shims, 1, true) then
    vim.env.PATH = shims .. ":" .. path
  end
end

local active_python_bin

function M.resolve_python(_)
  local virtual_env = vim.env.VIRTUAL_ENV
  if virtual_env and virtual_env ~= "" then
    local python = virtual_env .. "/bin/python"
    if vim.fn.executable(python) == 1 then
      return python
    end
  end

  return "python"
end

function M.activate_python_env(bufnr)
  local python = M.resolve_python(bufnr)
  local python_bin = python:match("^(.*)/python$")

  if active_python_bin and active_python_bin ~= python_bin then
    vim.env.PATH = remove_path_entry(vim.env.PATH or "", active_python_bin)
    active_python_bin = nil
  end

  if python_bin then
    prepend_path_entry(python_bin)
    vim.env.VIRTUAL_ENV = python_bin:gsub("/bin$", "")
    active_python_bin = python_bin
  end

  return python
end

local pynvim = vim.fn.expand("~/.local/share/nvim/pynvim-venv/bin/python")
if vim.fn.executable(pynvim) == 1 then
  vim.g.python3_host_prog = pynvim
end

M.activate_python_env(0)

return M
