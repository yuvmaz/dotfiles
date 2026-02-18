-- Navigate and select code structures using treesitter
return {
  "nvim-treesitter/nvim-treesitter-textobjects",
  dependencies = { "nvim-treesitter/nvim-treesitter" },
  lazy = false,
  config = function()
    pcall(function()
      require("nvim-treesitter.config").setup({
        textobjects = {
          move = {
            enable = true,
            set_jumps = true,
            goto_next_start = {
              ["]f"] = "@function.outer",
              ["]c"] = "@class.outer",
              ["]a"] = "@parameter.outer",
              ["]i"] = "@conditional.outer",
              ["]l"] = "@loop.outer",
              ["]b"] = "@block.outer",
              ["]s"] = "@assignment.outer",
              ["]o"] = "@call.outer",
            },
            goto_next_end = {
              ["]F"] = "@function.outer",
              ["]C"] = "@class.outer",
              ["]A"] = "@parameter.outer",
              ["]I"] = "@conditional.outer",
              ["]L"] = "@loop.outer",
              ["]B"] = "@block.outer",
              ["]S"] = "@assignment.outer",
              ["]O"] = "@call.outer",
            },
            goto_previous_start = {
              ["[f"] = "@function.outer",
              ["[c"] = "@class.outer",
              ["[a"] = "@parameter.outer",
              ["[i"] = "@conditional.outer",
              ["[l"] = "@loop.outer",
              ["[b"] = "@block.outer",
              ["[s"] = "@assignment.outer",
              ["[o"] = "@call.outer",
            },
            goto_previous_end = {
              ["[F"] = "@function.outer",
              ["[C"] = "@class.outer",
              ["[A"] = "@parameter.outer",
              ["[I"] = "@conditional.outer",
              ["[L"] = "@loop.outer",
              ["[B"] = "@block.outer",
              ["[S"] = "@assignment.outer",
              ["[O"] = "@call.outer",
            },
          },
          swap = {
            enable = true,
            swap_next = {
              [">A"] = "@parameter.inner",
            },
            swap_previous = {
              ["<A"] = "@parameter.inner",
            },
          },
          lsp_interop = {
            enable = true,
            border = "none",
            peek_definition_code = {
              ["<leader>df"] = "@function.outer",
              ["<leader>dF"] = "@class.outer",
            },
          },
        },
      })

      -- Helper function to register textobject keymaps
      local function register_textobject(modes, lhs, query)
        vim.keymap.set(modes, lhs, function()
          require("nvim-treesitter-textobjects.select").select_textobject(query)
        end, { noremap = true, silent = true })
      end

      -- Register all textobject selections using a loop to reduce repetition
      local textobjects = {
        f = "@function",
        c = "@class",
        a = "@parameter",
        i = "@conditional",
        l = "@loop",
        b = "@block",
        s = "@assignment",
        o = "@call",
      }

      for key, query in pairs(textobjects) do
        register_textobject({ "x", "o" }, "a" .. key, query .. ".outer")
        register_textobject({ "x", "o" }, "i" .. key, query .. ".inner")
      end
    end)
  end,
}
