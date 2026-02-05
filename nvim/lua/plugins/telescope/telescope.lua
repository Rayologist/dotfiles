local builtin = require("telescope.builtin")
return {
  "nvim-telescope/telescope.nvim",
  cmd = "Telescope",
  dependencies = {
    "nvim-lua/plenary.nvim",
    {
      "nvim-telescope/telescope-fzf-native.nvim",
      build = "make",
    },
    {
      "nvim-telescope/telescope-ui-select.nvim",
    },
    "folke/todo-comments.nvim",
  },
  opts = function()
    local actions = require("telescope.actions")
    local function flash(prompt_bufnr)
      require("flash").jump({
        pattern = "^",
        label = { after = { 0, 0 } },
        search = {
          mode = "search",
          exclude = {
            function(win)
              return vim.bo[vim.api.nvim_win_get_buf(win)].filetype ~= "TelescopeResults"
            end,
          },
        },
        action = function(match)
          local picker = require("telescope.actions.state").get_current_picker(prompt_bufnr)
          picker:set_selection(match.pos[1] - 1)
        end,
      })
    end

    return {
      defaults = {
        selection_caret = " ",
        mappings = {
          i = {
            ["<C-k>"] = actions.move_selection_previous,
            ["<C-j>"] = actions.move_selection_next,
            ["<C-s>"] = flash,
          },
          n = {
            ["q"] = actions.close,
            ["s"] = flash,
          },
        },
      },
      extensions = {
        ["ui-select"] = {
          require("telescope.themes").get_dropdown({}),
        },
      },
    }
  end,
  config = function(_, opts)
    require("telescope").setup(opts)
    require("telescope").load_extension("ui-select")
    require("telescope").load_extension("fzf")
    require("telescope").load_extension("fidget")
  end,
  keys = {
    {
      "<leader>ft",
      "<cmd>TodoTelescope<CR>",
      desc = "Find todos",
    },
    {
      "<leader>fi",
      function()
        require("telescope").extensions.fidget.fidget()
      end,
      desc = "Find fidgets history",
    },
    {
      "<leader>fg",
      function()
        require("lua.plugins.telescope.multi_grep").multi_grep()
      end,
      { desc = "Multi Grep" },
    },
    {
      "<leader>sm",
      function()
        builtin.man_pages()
      end,
      desc = "Search man pages",
    },
    {
      "<leader>sr",
      builtin.resume,
      desc = "Resume last search",
    },
    {
      "<leader>ff",
      function()
        builtin.find_files({
          no_ignore = false,
          hidden = true,
          follow = true,
        })
      end,
      desc = "Find Files",
    },
    {
      "<leader>sd",
      function()
        builtin.diagnostics({
          bufnr = 0,
        })
      end,
      desc = "Search document diagnostics",
    },
    {
      "<leader>f:",
      function()
        builtin.command_history()
      end,
      desc = "Find command history",
    },
    {
      "<leader>fc",
      function()
        builtin.commands()
      end,
      desc = "Find command history",
    },
    {
      "<leader>fk",
      builtin.keymaps,
      desc = "Find keymaps",
    },
    {
      "<leader>fb",
      function()
        builtin.buffers({
          sort_mru = true,
          sort_lastused = true,
          ignore_current_buffer = true,
        })
      end,
      desc = "Find buffers",
    },
    {
      "<leader>fr",
      function()
        builtin.oldfiles({ only_cwd = true })
      end,
      desc = "Find recent files",
    },
    {
      "<leader>fw",
      function()
        local word = vim.fn.expand("<cword>")
        builtin.grep_string({ search = word })
      end,
      desc = "Grep (word under cursor)",
    },
    {
      "<leader>fh",
      builtin.help_tags,
      desc = "Help pages",
    },
    {
      "<leader>fg",
      builtin.git_files,
      desc = "Find files (git files)",
    },
    {
      "<leader>fs",
      function()
        local ok, query = pcall(vim.fn.input, "Grep > ")
        if not ok or query == "" then
          return
        end

        builtin.grep_string({
          search = query,
          word_match = "-w",
        })
      end,
      desc = "Grep",
    },
    {
      "<leader>fj",
      function()
        builtin.jumplist()
      end,
      desc = "Find jump list",
    },
  },
}
