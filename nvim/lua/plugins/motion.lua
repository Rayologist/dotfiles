return {
  {
    "folke/flash.nvim",
    event = "VeryLazy",
    ---@type Flash.Config
    opts = {
      modes = {
        char = {
          jump_labels = true,
        },
      },
    },
    keys = {
      {
        "s",
        mode = { "n", "x", "o" },
        function()
          require("flash").jump()
        end,
        desc = "Flash",
      },
      {
        "\\s",
        mode = { "n", "x", "o" },
        function()
          require("flash").treesitter_search()
        end,
        desc = "Flash Treesitter",
      },
      {
        "\\t",
        mode = { "n", "x", "o" },
        function()
          require("flash").treesitter()
        end,
        desc = "Flash Treesitter",
      },
      {
        "\\r",
        mode = "o",
        function()
          require("flash").remote()
        end,
        desc = "Remote Flash",
      },
      {
        "<c-s>",
        mode = { "c" },
        function()
          require("flash").toggle()
        end,
        desc = "Toggle Flash Search",
      },
    },
  },
  {
    "chaoren/vim-wordmotion",
    init = function()
      vim.g.wordmotion_prefix = "\\"
    end,
  },
  {
    "kylechui/nvim-surround",
    version = "^3.0.0", -- Use for stability; omit to use `main` branch for the latest features
    event = "VeryLazy",
    opts = {
      surrounds = {
        ["g"] = {
          add = function()
            local config = require("nvim-surround.config")
            local input = config.get_input("Type: ")

            if input then
              return { { input .. "<" }, { ">" } }
            end
          end,
        },
        ["T"] = {
          add = function()
            return { { "${" }, { "}" } }
          end,
        },
      },
    },
  },
}
