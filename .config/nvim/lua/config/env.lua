-- Minimal PATH bridge for mise-owned net-new tools only
-- (fd, prettier, lua-language-server, stylua). pyenv/brew/cargo keep owning
-- python/node/rust; python3_host_prog below only pins the provider host.
local shims = vim.fn.expand("~/.local/share/mise/shims")
if vim.fn.isdirectory(shims) == 1 then
  local path = vim.env.PATH or ""
  if not path:find(shims, 1, true) then
    vim.env.PATH = shims .. ":" .. path
  end
end

-- Python provider pinned to the pyenv python that has pynvim (pyenv keeps
-- owning python; this only tells Nvim which host to use for UltiSnips)
local pyenv_py = vim.fn.expand("~/.pyenv/versions/3.12.9/bin/python")
if vim.fn.executable(pyenv_py) == 1 then
  vim.g.python3_host_prog = pyenv_py
end
