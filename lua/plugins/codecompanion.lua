return {
  "olimorris/codecompanion.nvim",
  version = "^19.0.0",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-treesitter/nvim-treesitter",
    { "j-hui/fidget.nvim", opts = {} },
  },
  init = function()
    require("codecompanion_extensions.fidget").setup()
  end,
  opts = {
    adapters = {
      acp = {
        agy = function()
          return require("codecompanion.adapters").extend("cagent", {
            name = "agy",
            formatted_name = "Antigravity",
            commands = {
              default = {
                "agy-acp",
              },
            },
            defaults = {
              timeout = 60000,
            },
          })
        end,
      },
    },
    interactions = {
      chat = {
        adapter = "agy",
      },
    },
  },
}
