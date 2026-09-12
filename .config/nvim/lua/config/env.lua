-- Minimal PATH bridge for mise-owned net-new tools only
-- (fd, prettier, lua-language-server). pyenv/brew/cargo keep owning
-- python/node/rust, so python3_host_prog is intentionally NOT overridden.
local shims = vim.fn.expand("~/.local/share/mise/shims")
if vim.fn.isdirectory(shims) == 1 then
  local path = vim.env.PATH or ""
  if not path:find(shims, 1, true) then
    vim.env.PATH = shims .. ":" .. path
  end
end

-- Port of $FZF_DEFAULT_OPTS from vimrc
vim.env.FZF_DEFAULT_OPTS = "--bind tab:down,shift-tab:up"

-- Python provider pinned to the pyenv python that has pynvim (pyenv keeps
-- owning python; this only tells Nvim which host to use for UltiSnips etc.)
local pyenv_py = vim.fn.expand("~/.pyenv/versions/3.12.9/bin/python")
if vim.fn.executable(pyenv_py) == 1 then
  vim.g.python3_host_prog = pyenv_py
end
