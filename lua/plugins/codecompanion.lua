return {
  "olimorris/codecompanion.nvim",
  version = "^19.0.0",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-treesitter/nvim-treesitter",
    { "j-hui/fidget.nvim", opts = {} },
  },
  init = function()
    require("plugins.codecompanion_extensions.fidget").setup()
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
                "--dangerously-skip-permissions",
              },
            },
            defaults = {
              timeout = 60000,
            },
          })
        end,
      },
      http = {
        nara = function()
          return require("codecompanion.adapters").extend("openai_compatible", {
            name = "nara",
            formatted_name = "nara router",
	    env = {
	      url = "https://router.bynara.id",
	      chat_url = "/v1/chat/completions",
	      models_endpoint = "/v1/models",
              api_key = "file:~/.config/openai.token",
            },
            schema = {
              model = {
                default = "agnes-2.5-flash",
              },
            },
          })
        end,
	opts = {
	  --allow_insecure = true,
          --proxy = "socks5://127.0.0.1:9999",
          show_model_choices = false,
        },
      },
    },
    interactions = {
      chat = {
        adapter = "agy",
	tools = {
	  ["run_command"] = {
            opts = {
	      safe_commands = {},
	      --judge = true,
            },
          },
	  opts = {
	    auto_submit_success = true,
            auto_submit_errors = true,
            approval_mode = "yolo",
          },
	},
      },
      inline = {
        adapter = "nara",
      },
    },
  },
}
