-- Make mise-managed tools available when Neovim is not started from a shell.
local shims = vim.fn.expand("~/.local/share/mise/shims")
if vim.fn.isdirectory(shims) == 1 then
  local path = vim.env.PATH or ""
  if not path:find(shims, 1, true) then
    vim.env.PATH = shims .. ":" .. path
  end
end

local pynvim = vim.fn.expand("~/.local/share/nvim/pynvim-venv/bin/python")
if vim.fn.executable(pynvim) == 1 then
  vim.g.python3_host_prog = pynvim
end
