-- Home (~) is itself a git repo whose .gitignore is "*", so fd/rg
-- return nothing under it. Disregard gitignore ONLY when the picker's
-- cwd is at/under $HOME and the nearest repo root is $HOME itself;
-- real projects (e.g. ~/repos/foo) keep respecting their own gitignore.
-- Per-session override inside any picker: <A-i> toggles ignore.
local M = {}
local home = vim.fn.expand("~")
local home_excludes = {
  "miniconda3", "Library", ".cache", ".npm", ".cargo", "node_modules",
  "__pycache__", ".Trash", "VirtualBox VMs", ".tvm",
  "*.qcow2", "*.iso", "*.dmg",
}

function M.repo_cwd()
  local cwd = vim.fn.getcwd()
  if cwd ~= home and cwd:sub(1, #home + 1) ~= home .. "/" then
    return false
  end
  local out = vim.fn.systemlist({ "git", "-C", cwd, "rev-parse", "--show-toplevel" })
  return vim.v.shell_error == 0 and out[1] == home
end

function M.fd_opts()
  local base = require("fzf-lua.defaults").defaults.files.fd_opts
  local parts = { base, "--hidden", "--no-ignore-vcs" }
  for _, pat in ipairs(home_excludes) do
    parts[#parts + 1] = "--exclude " .. vim.fn.shellescape(pat)
  end
  return table.concat(parts, " ")
end

function M.rg_opts()
  local base = require("fzf-lua.defaults").defaults.grep.rg_opts
  local parts = { base, "--hidden", "--no-ignore-vcs", "-g", vim.fn.shellescape("!.git") }
  for _, pat in ipairs(home_excludes) do
    local glob = pat:find("%*") and pat or (pat .. "/**")
    parts[#parts + 1] = "-g"
    parts[#parts + 1] = vim.fn.shellescape("!" .. glob)
  end
  return table.concat(parts, " ")
end

return M
