return {
  "yetone/avante.nvim",
  event = "VeryLazy",
  version = false,
  build = "make",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "MunifTanjim/nui.nvim",
    "nvim-tree/nvim-web-devicons",
  },
  opts = {
    provider = "opencode",
    mode = "agentic",
    instructions_file = "avante.md",
    selector = {
      provider = "fzf_lua",
      provider_opts = {},
    },
    behaviour = {
      auto_suggestions = false,
      auto_set_keymaps = true,
    },
    mappings = {
      ask = "<leader>xa",
      new_ask = "<leader>xn",
      zen_mode = "<leader>xz",
      edit = "<leader>xe",
      refresh = "<leader>xr",
      focus = "<leader>xf",
      stop = "<leader>xS",
      toggle = {
        default = "<leader>xx",
        debug = "<leader>xd",
        selection = "<leader>xC",
        suggestion = "<leader>xs",
        repomap = "<leader>xR",
      },
      files = {
        add_current = "<leader>xc",
        add_all_buffers = "<leader>xB",
      },
      select_model = "<leader>x?",
      select_history = "<leader>xh",
      select_acp_model = "<leader>xM",
      select_acp_mode = "<leader>xm",
    },
    acp_providers = {
      opencode = {
        command = "opencode",
        args = { "acp" },
      },
    },
  },
}
