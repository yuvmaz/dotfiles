-- Formatting driven by servers.lua:formatters (prettier from mise shims)
return {
  "stevearc/conform.nvim",
  event = "VeryLazy",
  opts = {
    formatters_by_ft = require("config.servers").formatters,
  },
}
