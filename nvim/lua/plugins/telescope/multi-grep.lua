local pickers = require("telescope.pickers")
local finders = require("telescope.finders")
local entry_maker = require("telescope.make_entry")
local conf = require("telescope.config").values
local sorters = require("telescope.sorters")

local flatten = function(t)
  return vim.iter(t):flatten():totable()
end

local SEP, ESCAPE = "::", "\\::"
local SENTINEL = string.char(0x1F) -- ASCII “Unit Separator”
  .. tostring(os.time()) -- seconds since epoch
  .. tostring(math.random(1e9)) -- pseudo‑random 0‒999 999 999
  .. string.char(0x1F)

--- @param prompt string
--- @return { [1]: string, [2]: string } | nil
local function parse_prompt(prompt)
  if not prompt or prompt == "" then
    return nil
  end
  local masked = prompt:gsub(ESCAPE, SENTINEL)
  local splitted_text = vim.split(masked, SEP)
  if #splitted_text > 2 then
    vim.notify(
      "Multi Grep: Too many separators, please use at most one separator. You should escape the separator with '\\'.",
      vim.log.levels.WARN
    )
    return nil
  end
  local pattern = splitted_text[1]:gsub(SENTINEL, SEP)
  local filters = splitted_text[2]
  return { pattern, filters }
end

--- @class MultiGrepOpts
--- @field title string | nil
--- @field cwd string | nil
--- @field vimgrep_arguments string[] | nil
--- @field glob_pattern string[] | nil

--- @param opts MultiGrepOpts | nil
local function multi_grep(opts)
  opts = opts or {}
  opts.cwd = opts.cwd or vim.uv.cwd()
  local vimgrep_arguments = opts.vimgrep_arguments or conf.vimgrep_arguments

  --- @type string[]
  local glob_pattern = {}

  if type(opts.glob_pattern) == "table" then
    for _, pattern in ipairs(opts.glob_pattern) do
      table.insert(glob_pattern, "--glob")
      table.insert(glob_pattern, pattern)
    end
  end

  local finder = finders.new_async_job({
    --- @param prompt string
    command_generator = function(prompt)
      local parsed = parse_prompt(prompt)

      if not parsed then
        return nil
      end

      local pattern, filters = unpack(parsed)

      --- @type string[]
      local args = flatten({ vimgrep_arguments, glob_pattern })

      if filters and filters ~= "" then
        for _, filter in ipairs(vim.split(filters, ",")) do
          filter = vim.trim(filter)
          table.insert(args, "--glob") -- file path
          table.insert(args, filter)
        end
      end

      return flatten({
        args,
        "--",
        pattern,
      })
    end,
    entry_maker = entry_maker.gen_from_vimgrep(opts),
    cwd = opts.cwd,
  })

  pickers
    .new(opts, {
      debounce = 300,
      prompt_title = "Multi Grep" .. (opts.title and " - " .. opts.title or ""),
      finder = finder,
      previewer = conf.grep_previewer(opts),
      sorter = sorters.new({
        scoring_function = function()
          return 1
        end,

        -- highlighter = function(_, prompt, display)
        --   local fzy = require("telescope.algos.fzy")
        --   local parsed = parse_prompt(prompt)
        --
        --   if not parsed then
        --     return fzy.positions("", display)
        --   end
        --
        --   local pattern = unpack(parsed)
        --
        --   return fzy.positions(pattern, display)
        -- end,
      }),
    })
    :find()
end

return {
  "multi-grep.nvim",
  dir = ".",
  keys = {
    {
      "<leader>/",
      function()
        multi_grep()
      end,
      { desc = "Multi Grep" },
    },
    {
      "<leader>fp",
      function()
        multi_grep({
          title = "Neovim Packages",
          glob_pattern = { "*.lua", "*.vim" },
          cwd = vim.fs.joinpath(vim.fn.stdpath("data"), "lazy"),
        })
      end,
      { desc = "Find Packages" },
    },
  },
}
