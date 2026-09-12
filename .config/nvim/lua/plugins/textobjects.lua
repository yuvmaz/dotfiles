-- Tree-sitter textobjects: select + jump for comments (# blocks), docstrings,
-- assignments/variables, functions, classes.
-- Usage: cursor on opening line, then ]C (comment end) or ]S (docstring end).
-- Delete examples: dav (variable name), daa (whole assignment), dia (value).
return {
  "nvim-treesitter/nvim-treesitter-textobjects",
  branch = "main",
  dependencies = { "nvim-treesitter/nvim-treesitter" },
  config = function()
    local to = require("nvim-treesitter-textobjects")
    to.setup({
      select = { lookahead = true },
      move = { set_jumps = true },
    })

    local select = require("nvim-treesitter-textobjects.select")
    local move = require("nvim-treesitter-textobjects.move")

    -- Select: a-c/i-c comment, a-s/i-s string (docstrings included, see queries/)
    vim.keymap.set({ "x", "o" }, "ac", function()
      select.select_textobject("@comment.outer", "textobjects")
    end, { silent = true, desc = "Outer comment" })
    vim.keymap.set({ "x", "o" }, "ic", function()
      select.select_textobject("@comment.inner", "textobjects")
    end, { silent = true, desc = "Inner comment" })
    vim.keymap.set({ "x", "o" }, "as", function()
      select.select_textobject("@string.outer", "textobjects")
    end, { silent = true, desc = "Outer string/docstring" })
    vim.keymap.set({ "x", "o" }, "is", function()
      select.select_textobject("@string.inner", "textobjects")
    end, { silent = true, desc = "Inner string/docstring" })

    -- Function / class objects (vimrc coc-funcobj/classobj parity).
    -- ak/ik for class because ac/ic are comments (NERDCommenter convention).
    vim.keymap.set({ "x", "o" }, "af", function()
      select.select_textobject("@function.outer", "textobjects")
    end, { silent = true, desc = "Outer function" })
    vim.keymap.set({ "x", "o" }, "if", function()
      select.select_textobject("@function.inner", "textobjects")
    end, { silent = true, desc = "Inner function" })
    vim.keymap.set({ "x", "o" }, "ak", function()
      select.select_textobject("@class.outer", "textobjects")
    end, { silent = true, desc = "Outer class" })
    vim.keymap.set({ "x", "o" }, "ik", function()
      select.select_textobject("@class.inner", "textobjects")
    end, { silent = true, desc = "Inner class" })

    -- Assignment / variable (python @assignment.* is builtin, no custom query needed).
    -- aa = whole `x = 1`, ia = value (`1`), av/iv = name (`x`).
    vim.keymap.set({ "x", "o" }, "aa", function()
      select.select_textobject("@assignment.outer", "textobjects")
    end, { silent = true, desc = "Outer assignment" })
    vim.keymap.set({ "x", "o" }, "ia", function()
      select.select_textobject("@assignment.inner", "textobjects")
    end, { silent = true, desc = "Inner assignment (value)" })
    vim.keymap.set({ "x", "o" }, "av", function()
      select.select_textobject("@assignment.lhs", "textobjects")
    end, { silent = true, desc = "Variable name" })
    vim.keymap.set({ "x", "o" }, "iv", function()
      select.select_textobject("@assignment.lhs", "textobjects")
    end, { silent = true, desc = "Variable name" })

    -- Move: ]C/[C comment start/end, ]S/[S string/docstring start/end.
    -- From the opening """ of a docstring, ]S jumps to the closing """.
    vim.keymap.set({ "n", "x", "o" }, "]C", function()
      move.goto_next_end("@comment.outer", "textobjects")
    end, { silent = true, desc = "Next comment end" })
    vim.keymap.set({ "n", "x", "o" }, "[C", function()
      move.goto_previous_start("@comment.outer", "textobjects")
    end, { silent = true, desc = "Previous comment start" })
    vim.keymap.set({ "n", "x", "o" }, "]S", function()
      move.goto_next_end("@string.outer", "textobjects")
    end, { silent = true, desc = "Next string/docstring end" })
    vim.keymap.set({ "n", "x", "o" }, "[S", function()
      move.goto_previous_start("@string.outer", "textobjects")
    end, { silent = true, desc = "Previous string/docstring start" })

    -- Function / class jumps (]m/[m style, vim python-ftplugin familiarity)
    vim.keymap.set({ "n", "x", "o" }, "]m", function()
      move.goto_next_start("@function.outer", "textobjects")
    end, { silent = true, desc = "Next function start" })
    vim.keymap.set({ "n", "x", "o" }, "[m", function()
      move.goto_previous_start("@function.outer", "textobjects")
    end, { silent = true, desc = "Previous function start" })
    vim.keymap.set({ "n", "x", "o" }, "]M", function()
      move.goto_next_end("@function.outer", "textobjects")
    end, { silent = true, desc = "Next function end" })
    vim.keymap.set({ "n", "x", "o" }, "[M", function()
      move.goto_previous_end("@function.outer", "textobjects")
    end, { silent = true, desc = "Previous function end" })
    vim.keymap.set({ "n", "x", "o" }, "]k", function()
      move.goto_next_start("@class.outer", "textobjects")
    end, { silent = true, desc = "Next class start" })
    vim.keymap.set({ "n", "x", "o" }, "[k", function()
      move.goto_previous_start("@class.outer", "textobjects")
    end, { silent = true, desc = "Previous class start" })

    -- Assignment jumps (mirrors ]m/]k style)
    vim.keymap.set({ "n", "x", "o" }, "]a", function()
      move.goto_next_start("@assignment.outer", "textobjects")
    end, { silent = true, desc = "Next assignment start" })
    vim.keymap.set({ "n", "x", "o" }, "[a", function()
      move.goto_previous_start("@assignment.outer", "textobjects")
    end, { silent = true, desc = "Previous assignment start" })

    -- Port of vimrc <C-s> coc-range-select (vimrc:162-163): grow the visual
    -- selection to the parent tree-sitter node. Press repeatedly to expand.
    -- Works without LSP. NOTE: like vim, needs flow-control off (stty -ixon)
    -- for <C-s> to reach Neovim in some terminals.
    local function select_range(node)
      local sr, sc, er, ec = node:range()
      -- NOTE: folds start closed (foldmethod=indent, foldlevel=0) and the
      -- cursor snaps to the fold head inside closed folds, corrupting the
      -- anchor. So reveal both ends with zv BEFORE entering visual.
      -- zv must never run while in visual (it corrupts the buffer).
      if er > sr then
        -- Multi-line node: select whole lines (linewise) so leading indent
        -- and trailing newline are included (yank/paste/delete behave).
        -- End-exclusive col 0 means the node ends at that line's start,
        -- so the last included line is the previous one.
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
    vim.keymap.set({ "n", "x" }, "<C-s>", function()
      local bufnr = vim.api.nvim_get_current_buf()
      -- Ensure the tree is parsed (e.g. right after opening a file),
      -- otherwise get_node() can return nil.
      pcall(function()
        vim.treesitter.get_parser(bufnr):parse(true)
      end)
      local ok, node = pcall(vim.treesitter.get_node)
      if not ok or not node then
        return
      end
      if vim.fn.mode() == "n" then
        select_range(node)
        return
      end
      -- Visual: find the smallest ancestor strictly containing the selection,
      -- then reselect it (exit + reselect keeps it repeatable).
      -- NOTE: :normal does not interpret <> notation, so <Esc> here would
      -- type literal keys (< dedents!); go through :execute for a real ESC.
      vim.cmd('execute "normal! \\<Esc>"')
      local srow, scol = unpack(vim.api.nvim_buf_get_mark(0, "<"))
      local erow, ecol = unpack(vim.api.nvim_buf_get_mark(0, ">"))
      scol, ecol = scol + 1, ecol + 1 -- marks are 0-indexed cols
      local target = node
      while target do
        local sr, sc, er, ec = target:range()
        sr, er = sr + 1, er + 1
        sc, ec = sc + 1, ec -- end-exclusive -> inclusive for compare
        local contains = (sr < srow or (sr == srow and sc <= scol))
          and (er > erow or (er == erow and ec >= ecol))
        local strictly_bigger = (sr ~= srow or sc ~= scol or er ~= erow or ec ~= ecol)
        if contains and strictly_bigger then
          break
        end
        target = target:parent()
      end
      if target then
        select_range(target)
      else
        -- Already at the top node: restore the selection instead of
        -- leaving the user in normal mode.
        vim.cmd("normal! gv")
      end
    end, { silent = true, desc = "Expand selection to parent node" })
  end,
}
