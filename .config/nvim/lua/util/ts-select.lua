-- Tree-sitter expand-selection logic ported from vimrc <C-s> coc-range-select.
-- Grows the visual selection to the enclosing parent TS node; repeatedly
-- pressing expands outward. Works without LSP. NOTE: like vim, needs
-- flow-control off (stty -ixon) for <C-s> to reach Neovim in some terminals.
local M = {}

-- Select the given node's range in the buffer.
-- Handles closed folds (foldmethod=indent) by revealing both ends with zv
-- BEFORE entering visual — zv must never run while already in visual mode.
function M.select_range(node)
  local sr, sc, er, ec = node:range()
  if er > sr then
    -- Multi-line node: linewise selection so leading indent + trailing newline
    -- are included (yank/paste/delete behave as expected).
    local last = (ec == 0) and er or (er + 1)
    vim.api.nvim_win_set_cursor(0, { sr + 1, 0 })
    vim.cmd("normal! zv")
    vim.api.nvim_win_set_cursor(0, { last, 0 })
    vim.cmd("normal! zv")
    vim.api.nvim_win_set_cursor(0, { sr + 1, 0 })
    vim.cmd("normal! V")
    vim.api.nvim_win_set_cursor(0, { last, 0 })
  else
    vim.api.nvim_win_set_cursor(0, { sr + 1, sc })
    vim.cmd("normal! zv")
    vim.api.nvim_win_set_cursor(0, { er + 1, math.max(ec - 1, 0) })
    vim.cmd("normal! zv")
    vim.api.nvim_win_set_cursor(0, { sr + 1, sc })
    vim.cmd("normal! v")
    vim.api.nvim_win_set_cursor(0, { er + 1, math.max(ec - 1, 0) })
  end
end

-- Return the smallest ancestor of `node` that strictly contains the current
-- visual selection (srow, scol, erow, ecol — all 1-indexed rows, 1-indexed
-- cols). Returns nil if the root node is already the selection.
function M.containing_ancestor(node, srow, scol, erow, ecol)
  local target = node
  while target do
    local tsr, tsc, ter, tec = target:range()
    tsr, ter = tsr + 1, ter + 1
    tsc, tec = tsc + 1, tec -- end-exclusive -> inclusive for compare
    local contains = (tsr < srow or (tsr == srow and tsc <= scol))
      and (ter > erow or (ter == erow and tec >= ecol))
    local strictly_bigger = (tsr ~= srow or tsc ~= scol or ter ~= erow or tec ~= ecol)
    if contains and strictly_bigger then
      return target
    end
    target = target:parent()
  end
  return nil
end

return M
