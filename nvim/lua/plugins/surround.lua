return {
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
    },
  },
}
