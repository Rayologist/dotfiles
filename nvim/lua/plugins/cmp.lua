return {
  {
    "saghen/blink.cmp",
    version = "1.*",
    dependencies = {
      {
        "L3MON4D3/LuaSnip",
        version = "v2.*",
        build = "make install_jsregexp",
        opts = {
          history = true,
          delete_check_events = "TextChanged",
        },
      },
      "rafamadriz/friendly-snippets",
      "onsails/lspkind.nvim",
    },
    ---@module "blink.cmp"
    ---@type blink.cmp.Config
    opts = {
      keymap = {
        preset = "none",
        ["<C-i>"] = { "show", "show_documentation", "hide_documentation" },
        ["<C-e>"] = { "hide" },
        ["<C-y>"] = { "select_and_accept" },
        ["<C-j>"] = { "select_next" },
        ["<C-k>"] = { "select_prev" },
        ["<C-d>"] = { "scroll_documentation_down" },
        ["<C-u>"] = { "scroll_documentation_up" },
        ["<Tab>"] = { "fallback" },
      },
      snippets = {
        preset = "luasnip",
      },
      signature = {
        enabled = true,
      },
      completion = {
        menu = {
          draw = {
            columns = {
              { "kind_icon" },
              { "label", "label_description", gap = 1 },
              { "source_name" },
            },
            components = {
              kind_icon = {
                text = function(ctx)
                  return require("lspkind").presets.codicons[ctx.kind] or ""
                end,
              },
            },
          },
        },
        list = {
          selection = {
            preselect = true,
            auto_insert = false,
          },
        },
        documentation = {
          auto_show = true,
          auto_show_delay_ms = 100,
        },
        ghost_text = {
          enabled = false,
        },
      },
      sources = {
        default = function()
          local success, node = pcall(vim.treesitter.get_node)

          local string_node_types = {
            "string",
            "string_content",
            "character",
            "string_literal",
          }

          if success and node and vim.tbl_contains(string_node_types, node:type()) then
            return { "buffer", "snippets" }
          end

          return { "lazydev", "lsp", "path", "snippets", "buffer" }
        end,
        providers = {
          lazydev = {
            name = "[LZDV]",
            module = "lazydev.integrations.blink",
            score_offset = 100,
          },
          lsp = {
            name = "[LSP]",
            fallbacks = {},
            score_offset = 1,
          },
          buffer = {
            name = "[BUF]",
            max_items = 20,
          },
          path = {
            name = "[PATH]",
            opts = {
              trailing_slash = false,
              show_hidden_files_by_default = true,
            },
          },
          snippets = { name = "[SNP]" },
          cmdline = { name = "[CMD]" },
        },
      },
      cmdline = {
        enabled = true,
        keymap = {
          preset = "cmdline",
          ["<C-j>"] = { "select_next", "show" },
          ["<C-k>"] = { "select_prev", "show" },
          ["<Tab>"] = { "show", "accept" },
        },
        sources = function()
          local t = vim.fn.getcmdtype()
          if t == "/" or t == "?" then
            return { "buffer" }
          end

          if t == ":" then
            return { "cmdline", "path" }
          end
          return {}
        end,
        completion = {
          list = {
            selection = {
              auto_insert = false,
            },
          },
          menu = {
            auto_show = true,
          },
          ghost_text = {
            enabled = true,
          },
        },
      },
      fuzzy = {
        implementation = "prefer_rust_with_warning",
        sorts = {
          "exact",
          "score",
          function(a, b)
            local _, a_under = a.label:find("^_+")
            local _, b_under = b.label:find("^_+")
            a_under = a_under or 0
            b_under = b_under or 0
            if a_under ~= b_under then
              return a_under < b_under
            end
          end,
          "sort_text",
          "label",
        },
      },
    },
    opts_extend = { "sources.default" },
    config = function(_, opts)
      local ls = require("luasnip")

      require("luasnip.loaders.from_vscode").lazy_load()
      -- Load snippets from custom directory: .config/nvim/snippets
      require("luasnip.loaders.from_vscode").lazy_load({ paths = { vim.fn.stdpath("config") .. "/snippets" } })

      vim.keymap.set({ "i", "s" }, "<C-l>", function()
        ls.jump(1)
      end, { silent = true })

      vim.keymap.set({ "i", "s" }, "<C-h>", function()
        ls.jump(-1)
      end, { silent = true })

      require("blink.cmp").setup(opts)
    end,
  },
}
