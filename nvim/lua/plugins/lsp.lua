--- @class (exact) LspConfig
--- @field lspconfig? vim.lsp.Config
--- @field enabled? boolean

--- @class (exact) ServerConfig
--- @field language_servers table<string, LspConfig>
--- @field linters string[]
--- @field formatters string[]

--- @param config ServerConfig
local function create_server_config(config)
  --- @type string[]
  local ensure_installed = {}

  vim.list_extend(ensure_installed, config.linters or {})
  vim.list_extend(ensure_installed, config.formatters or {})
  vim.list_extend(ensure_installed, vim.tbl_keys(config.language_servers or {}))

  --- @type table<string, LspConfig>
  local enabled_ls = {}

  for name, cfg in pairs(config.language_servers or {}) do
    if cfg.enabled ~= false then
      enabled_ls[name] = cfg
    end
  end

  return ensure_installed, enabled_ls
end

return {
  {
    "neovim/nvim-lspconfig",
    dependencies = {
      {
        "folke/lazydev.nvim",
        ft = "lua",
        opts = {
          library = {
            { path = "${3rd}/luv/library", words = { "vim%.uv" } },
          },
        },
      },
      {
        "mason-org/mason.nvim",
        opts = {},
      },
      {
        "mason-org/mason-lspconfig.nvim",
        opts = {
          ensure_installed = {}, -- already handled by mason-tool-installer
          automatic_installation = false,
          automatic_enable = true,
        },
      },
      "WhoIsSethDaniel/mason-tool-installer.nvim",
      -- "hrsh7th/cmp-nvim-lsp",
      "saghen/blink.cmp",
      {
        "antosha417/nvim-lsp-file-operations",
        dependencies = {
          "nvim-lua/plenary.nvim",
          "nvim-neo-tree/neo-tree.nvim",
        },
        opts = {},
      },
      "b0o/SchemaStore.nvim",
    },
    config = function()
      -- Setup keymaps for LSP clients
      vim.api.nvim_create_autocmd("LspAttach", {
        group = vim.api.nvim_create_augroup("UserLspConfig", {}),
        callback = function(e)
          local builtin = require("telescope.builtin")

          vim.keymap.set("n", "K", vim.lsp.buf.hover, { buffer = e.buf, desc = "Hover" })
          vim.keymap.set("n", "gd", builtin.lsp_definitions, {
            buffer = e.buf,
            desc = "Show LSP definitions",
          })
          vim.keymap.set("n", "gD", vim.lsp.buf.declaration, {
            buffer = e.buf,
            desc = "Show LSP declaration",
          })
          vim.keymap.set("n", "grr", builtin.lsp_references, {
            buffer = e.buf,
            desc = "Show LSP references",
          })
          vim.keymap.set("n", "gri", builtin.lsp_implementations, {
            buffer = e.buf,
            desc = "Show LSP implementations",
          })
          vim.keymap.set("n", "grt", builtin.lsp_type_definitions, {
            buffer = e.buf,
            desc = "Show LSP type definitions",
          })
          vim.keymap.set("n", "gO", builtin.lsp_document_symbols, {
            buffer = e.buf,
            desc = "Show LSP document symbols",
          })
        end,
      })

      -- diagnostics
      vim.diagnostic.config({
        float = { border = "rounded" },
        severity_sort = true,
        jump = {
          float = true,
        },
        signs = false,
        -- signs = {
        --   text = {
        --     [vim.diagnostic.severity.ERROR] = "",
        --     [vim.diagnostic.severity.WARN] = "",
        --     [vim.diagnostic.severity.HINT] = "",
        --     [vim.diagnostic.severity.INFO] = "",
        --   },
        -- },
      })

      -- lsp config
      local schema_store = require("schemastore")
      local ensure_installed, enabled_ls = create_server_config({
        linters = {
          "cspell",
          "eslint_d",
          "golangci-lint",
          "hadolint",
          "markdownlint-cli2",
          "shellcheck",
        },
        formatters = {
          "gofumpt",
          "goimports",
          "gomodifytags",
          "prettier",
          "shfmt",
          "stylua",
          "markdown-toc",
        },
        language_servers = {
          dockerls = {},
          bashls = {
            lspconfig = {
              settings = {
                bashIde = {
                  shellcheckPath = "", -- disable shellcheck because nvim-lint is used
                  shfmt = {
                    path = "", -- disable shfmt because conform is used
                  },
                },
              },
            },
          },
          docker_compose_language_service = {},
          marksman = {},
          tombi = {}, -- TOML language server
          jsonls = {
            lspconfig = {
              settings = {
                json = {
                  schemas = schema_store.json.schemas({
                    select = {
                      "package.json",
                      ".eslintrc",
                      "tsconfig.json",
                      "pnpm Workspace (pnpm-workspace.yaml)",
                      "prettierrc.json",
                      "nest-cli",
                      "Ruff",
                      "Pyright",
                    },
                  }),
                  format = {
                    enable = true,
                  },
                  validate = { enable = true },
                },
              },
            },
          },
          yamlls = {
            lspconfig = {
              settings = {
                schemas = schema_store.yaml.schemas({
                  select = {
                    "docker-compose.yml",
                    "GitHub Workflow",
                    "Taskfile config",
                  },
                }),
                redhat = { telemetry = { enabled = false } },
                yaml = {
                  keyOrdering = false,
                  format = {
                    enable = true,
                  },
                  validate = true,
                  schemaStore = {
                    -- Must disable built-in schemaStore support to use
                    -- schemas from SchemaStore.nvim plugin
                    enable = true,
                    -- Avoid TypeError: Cannot read properties of undefined (reading 'length')
                    url = "",
                  },
                },
              },
            },
          },
          lua_ls = {},
          terraformls = {},
          eslint = {},
          tflint = {},
          ts_ls = {},
          gopls = {},
          html = {},
          cssls = {},
          graphql = {},
          golangci_lint_ls = {},
          ruff = {
            lspconfig = {
              cmd_env = { RUFF_TRACE = "messages" },
              handlers = {
                --- Fixes the **“undercurl not showing”** issue:
                ---
                --- Ruff ≥ 0.5 returns *pull diagnostics* via `textDocument/diagnostic`.
                --- For unused or deprecated code it attaches `tags = { 1 | 2 }`
                ---   1 → **Unnecessary**   → highlight `DiagnosticUnnecessary`
                ---   2 → **Deprecated**    → highlight `DiagnosticDeprecated`
                ---
                --- Most color schemes place the visible undercurl on
                --- `DiagnosticUnderline{Error,Warn,Info,Hint}` groups
                --- but not on the two groups above.
                --- When Neovim sees the tag, it **switches the highlight group**,
                --- so the undercurl disappears and the text goes dim / strikethrough.
                ---
                --- Since another LSP (e.g. basedpyright) also reports on deprecated and
                --- unused code, ruff's diagnostic tags are removed to ensure the undercurl is visible.
                ---
                --- @param error?    lsp.ResponseError
                --- @param result  lsp.DocumentDiagnosticReport
                --- @param ctx     lsp.HandlerContext
                [vim.lsp.protocol.Methods.textDocument_diagnostic] = function(error, result, ctx)
                  if result and result.kind == "full" then
                    for _, diagnostic in ipairs(result.items) do
                      diagnostic.tags = nil
                    end
                  end
                  vim.lsp.handlers[vim.lsp.protocol.Methods.textDocument_diagnostic](error, result, ctx)
                end,
              },
              init_options = {
                settings = {
                  logLevel = "error",
                },
              },
            },
          },
          basedpyright = {
            lspconfig = {
              settings = {
                basedpyright = {
                  disableOrganizeImports = true, -- Using Ruff's import organizer
                  analysis = {
                    diagnosticSeverityOverrides = {},
                  },
                },
              },
            },
          },
        },
      })

      require("mason-tool-installer").setup({
        ensure_installed = ensure_installed,
      })

      -- local cmp_nvim_lsp = require("cmp_nvim_lsp")

      local blink_cmp = require("blink.cmp")
      for ls, cfg in pairs(enabled_ls) do
        -- local capabilities = cmp_nvim_lsp.default_capabilities()
        local lspconfig = cfg.lspconfig or {}
        -- if lspconfig.capabilities then
        --   capabilities = vim.tbl_deep_extend("force", {}, capabilities, lspconfig.capabilities)
        -- end
        lspconfig.capabilities = blink_cmp.get_lsp_capabilities(lspconfig.capabilities)

        vim.lsp.config(ls, lspconfig)
      end
    end,
  },
}
