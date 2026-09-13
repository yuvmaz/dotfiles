-- Tree-sitter textobjects: select + jump for comments (# blocks), docstrings,
-- assignments/variables, functions, classes.
-- Usage: cursor on opening line, then ]C (comment end) or ]S (docstring end).
-- Delete examples: dav (variable name), daa (whole assignment), dia (value).
return {
  "nvim-treesitter/nvim-treesitter-textobjects",
  branch = "main",
  event = { "BufReadPost", "BufNewFile" },
  dependencies = { "nvim-treesitter/nvim-treesitter" },
  config = function()
    local to = require("nvim-treesitter-textobjects")
    to.setup({
      select = { lookahead = true },
      move = { set_jumps = true },
    })

    local select = require("nvim-treesitter-textobjects.select")
    local move = require("nvim-treesitter-textobjects.move")
    local tsselect = require("util.ts-select")

    -- Select: { lhs, capture, desc }
    -- ak/ik for class because ac/ic are comments (NERDCommenter convention).
    local select_keys = {
      { "ac", "@comment.outer", "Outer comment" },
      { "ic", "@comment.inner", "Inner comment" },
      { "as", "@string.outer",  "Outer string/docstring" },
      { "is", "@string.inner",  "Inner string/docstring" },
      { "af", "@function.outer", "Outer function" },
      { "if", "@function.inner", "Inner function" },
      { "ak", "@class.outer",   "Outer class" },
      { "ik", "@class.inner",   "Inner class" },
      -- aa = whole `x = 1`, ia = value (`1`), av/iv = name (`x`).
      { "aa", "@assignment.outer", "Outer assignment" },
      { "ia", "@assignment.inner", "Inner assignment (value)" },
      { "av", "@assignment.lhs",   "Variable name" },
      { "iv", "@assignment.lhs",   "Variable name" },
    }
    for _, k in ipairs(select_keys) do
      vim.keymap.set({ "x", "o" }, k[1], function()
        select.select_textobject(k[2], "textobjects")
      end, { silent = true, desc = k[3] })
    end

    -- Move: { lhs, fn, capture, desc }
    local move_keys = {
      -- From the opening """ of a docstring, ]S jumps to the closing """.
      { "]C", move.goto_next_end,        "@comment.outer",  "Next comment end" },
      { "[C", move.goto_previous_start,  "@comment.outer",  "Previous comment start" },
      { "]S", move.goto_next_end,        "@string.outer",   "Next string/docstring end" },
      { "[S", move.goto_previous_start,  "@string.outer",   "Previous string/docstring start" },
      -- Function / class jumps (]m/[m style, vim python-ftplugin familiarity).
      { "]m", move.goto_next_start,      "@function.outer", "Next function start" },
      { "[m", move.goto_previous_start,  "@function.outer", "Previous function start" },
      { "]M", move.goto_next_end,        "@function.outer", "Next function end" },
      { "[M", move.goto_previous_end,    "@function.outer", "Previous function end" },
      { "]k", move.goto_next_start,      "@class.outer",    "Next class start" },
      { "[k", move.goto_previous_start,  "@class.outer",    "Previous class start" },
      -- Assignment jumps (mirrors ]m/]k style).
      { "]a", move.goto_next_start,      "@assignment.outer", "Next assignment start" },
      { "[a", move.goto_previous_start,  "@assignment.outer", "Previous assignment start" },
    }
    for _, k in ipairs(move_keys) do
      vim.keymap.set({ "n", "x", "o" }, k[1], function()
        k[2](k[3], "textobjects")
      end, { silent = true, desc = k[4] })
    end

    -- Port of vimrc <C-s> coc-range-select (vimrc:162-163): grow the visual
    -- selection to the parent tree-sitter node. Press repeatedly to expand.
    vim.keymap.set({ "n", "x" }, "<C-s>", function()
      local bufnr = vim.api.nvim_get_current_buf()
      pcall(function()
        vim.treesitter.get_parser(bufnr):parse(true)
      end)
      local ok, node = pcall(vim.treesitter.get_node)
      if not ok or not node then
        return
      end
      if vim.fn.mode() == "n" then
        tsselect.select_range(node)
        return
      end
      -- Visual: find the smallest ancestor strictly containing the selection,
      -- then reselect it (exit + reselect keeps it repeatable).
      -- :normal does not interpret <> notation, so <Esc> here would type
      -- literal keys (< dedents!); go through :execute for a real ESC.
      vim.cmd('execute "normal! \\<Esc>"')
      local srow, scol = unpack(vim.api.nvim_buf_get_mark(0, "<"))
      local erow, ecol = unpack(vim.api.nvim_buf_get_mark(0, ">"))
      scol, ecol = scol + 1, ecol + 1 -- marks are 0-indexed cols
      local ancestor = tsselect.containing_ancestor(node, srow, scol, erow, ecol)
      if ancestor then
        tsselect.select_range(ancestor)
      else
        -- Already at the top node: restore the selection.
        vim.cmd("normal! gv")
      end
    end, { silent = true, desc = "Expand selection to parent node" })
  end,
}
