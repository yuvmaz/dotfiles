-- Fuzzy finder for files, buffers, and search
return {
  "nvim-telescope/telescope.nvim",
  dependencies = {
    "nvim-lua/plenary.nvim",
    {
      "nvim-telescope/telescope-fzf-native.nvim",
      build = "cmake -S. -Bbuild -DCMAKE_BUILD_TYPE=Release && cmake --build build --config Release && cmake --install build --prefix build",
    },
  },
  config = function()
    local telescope = require("telescope")
    telescope.setup({
      defaults = {
        layout_strategy = "horizontal",
        layout_config = { width = 0.9, height = 0.6 },
        sorting_strategy = "descending",
        vimgrep_arguments = {
          "rg",
          "--color=never",
          "--no-heading",
          "--with-filename",
          "--line-number",
          "--column",
          "--smart-case",
          "--no-ignore-vcs",
          "--hidden",
        },
      },
      extensions = {
        fzf = {
          fuzzy = true,
          override_generic_sorter = true,
          override_file_sorter = true,
          case_mode = "smart_case",
        },
      },
    })
    telescope.load_extension("fzf")

    local map = vim.keymap.set

    -- Find files in current directory
    map("n", "<Leader>ff", function()
      local find_command = vim.fn.executable("fd") == 1
        and { "fd", "--type", "f", "--hidden", "--follow" }
        or { "find", ".", "-type", "f" }

      require("telescope.builtin").find_files({
        cwd = vim.fn.getcwd(),
        hidden = true,
        find_command = find_command,
      })
    end, { desc = "Find files in current directory" })

    -- Git files (tracked files with status)
    map("n", "<Leader>gs", function()
      require("telescope.builtin").git_files({
        cwd = vim.fn.getcwd(),
        show_untracked = true,
      })
    end, { desc = "Git files with status" })

    -- Live grep in current directory and below
    map("n", "<Leader>fg", function()
      require("telescope.builtin").live_grep({
        cwd = vim.fn.getcwd(),
      })
    end, { desc = "Live grep in current directory" })

    -- List open buffers
    map("n", "<Leader>fb", function()
      require("telescope.builtin").buffers()
    end, { desc = "List buffers" })
  end,
}

