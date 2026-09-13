-- Make mise-managed tools available when Neovim is not started from a shell.
local shims = vim.fn.expand("~/.local/share/mise/shims")
if vim.fn.isdirectory(shims) == 1 then
  local path = vim.env.PATH or ""
  if not path:find(shims, 1, true) then
    vim.env.PATH = shims .. ":" .. path
  end
end

-- This pyenv installation provides pynvim for UltiSnips.
local pyenv_py = vim.fn.expand("~/.pyenv/versions/3.12.9/bin/python")
if vim.fn.executable(pyenv_py) == 1 then
  vim.g.python3_host_prog = pyenv_py
end
