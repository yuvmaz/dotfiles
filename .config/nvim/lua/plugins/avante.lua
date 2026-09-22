return {
  "yetone/avante.nvim",
  event = "VeryLazy",
  version = false,
  build = "make",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "MunifTanjim/nui.nvim",
    {
      "MeanderingProgrammer/render-markdown.nvim",
      opts = { file_types = { "markdown", "Avante" } },
      ft = { "markdown", "Avante" },
    },
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
      select_model = "<leader>xM",
      select_history = "<leader>xh",
      select_acp_model = "<leader>xM",
      select_acp_mode = "<leader>xm",
    },
  },
  config = function(_, opts)
    require("avante").setup(opts)

    local function select_acp_config(select_fn)
      local avante = require("avante")
      local sidebar = avante.get(false)

      if not sidebar or not sidebar:is_open() then
        avante.open_sidebar({})
        vim.defer_fn(function()
          select_fn()
        end, 200)
        return
      end

      select_fn()
    end

    local function select_acp_model()
      select_acp_config(function()
        require("avante.api").select_acp_model()
      end)
    end

    local function select_acp_mode()
      select_acp_config(function()
        require("avante.api").select_acp_mode()
      end)
    end

    vim.keymap.set("n", "<leader>xM", select_acp_model, { desc = "avante: select ACP model" })
    vim.keymap.set("n", "<leader>xm", select_acp_mode, { desc = "avante: select ACP mode" })

    vim.api.nvim_create_user_command("AvanteModels", function()
      select_acp_model()
    end, { desc = "Select Avante ACP model" })
    vim.api.nvim_create_user_command("AvanteACPModels", function()
      select_acp_model()
    end, { desc = "Select Avante ACP model" })
    vim.api.nvim_create_user_command("AvanteACPModes", function()
      select_acp_mode()
    end, { desc = "Select Avante ACP mode" })
  end,
}
