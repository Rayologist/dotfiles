return {
  "catppuccin/nvim",
  lazy = false,
  priority = 1000,
  name = "catppuccin",
  ---@type CatppuccinOptions
  opts = {
    float = {
      transparent = true,
      solid = false,
    },
    no_italic = true,
    transparent_background = true,
    integrations = {
      lsp_trouble = true,
      mason = true,
      fidget = true,
      harpoon = true,
      diffview = true,
      blink_cmp = true,
      indent_blankline = {
        enabled = false,
        -- scope_color = 'text',
        -- colored_indent_levels = false,
      },
    },
    lsp_styles = {
      underlines = {
        errors = { "undercurl" },
        hints = { "undercurl" },
        warnings = { "undercurl" },
        information = { "undercurl" },
      },
    },
    custom_highlights = function(colors)
      -- default highlight: https://github.com/catppuccin/nvim/blob/main/lua/catppuccin/groups/integrations/treesitter.lua
      return {
        -- ai
        CmpGhostText = { fg = colors.mantle },

        -- global
        ["@property"] = { fg = colors.lavender }, -- we can delete this once catppuccin merged https://github.com/catppuccin/nvim/pull/905
        ["@lsp.typemod.variable.readonly"] = { link = "Constant" },

        -- lua
        ["@lsp.type.property.lua"] = { link = "@lsp" },

        -- html
        ["@tag.delimiter"] = { fg = colors.overlay2 },

        -- jsx, tsx
        ["@tag.attribute.tsx"] = { link = "@property" },
        ["@tag.attribute.jsx"] = { link = "@property" },
        ["@tag.tsx"] = { link = "Type" },
        ["@tag.jsx"] = { link = "Type" },
      }
    end,
  },
  config = function(_, opts)
    require("catppuccin").setup(opts)
    vim.cmd.colorscheme("catppuccin")
  end,
}
