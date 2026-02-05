-- Helper: Get the current selection range (Normal or Visual)
-- Returns: start_line, end_line, is_visual_mode
local function get_range()
  local mode = vim.fn.mode()
  local start_line, end_line
  local is_visual = false

  -- Check for Visual modes: v, V, or Ctrl-V
  if mode == "v" or mode == "V" or mode == "\22" then
    is_visual = true
    local line_v = vim.fn.line("v")
    local line_cur = vim.fn.line(".")
    -- Sort lines to ensure start is always <= end
    start_line = math.min(line_v, line_cur)
    end_line = math.max(line_v, line_cur)
  else
    -- Normal mode: current line only
    start_line = vim.fn.line(".")
    end_line = start_line
  end

  return start_line, end_line, is_visual
end

-- Helper: Exit visual mode if active (UX polish)
local function exit_visual_mode()
  -- Using feedkeys to robustly exit visual mode
  vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Esc>", true, false, true), "n", true)
end

-- 1. Copy Path Reference (<leader>cp)
-- Output: src/utils/helper.ts:10-15
local function copy_path_ref()
  local file_path = vim.fn.expand("%:.")
  local start_line, end_line, is_visual = get_range()

  local result
  if start_line == end_line then
    result = string.format("%s:%d", file_path, start_line)
  else
    result = string.format("%s:%d-%d", file_path, start_line, end_line)
  end

  vim.fn.setreg("+", result) -- Copy to system clipboard

  if is_visual then
    exit_visual_mode()
  end
end

-- 2. Copy Code with Context (<leader>cc)
-- Output:
-- File: `src/utils/helper.ts:10-15`
-- ```typescript
-- const code = ...
-- ```
local function copy_code_context()
  local file_path = vim.fn.expand("%:.")
  local file_type = vim.bo.filetype
  local start_line, end_line, is_visual = get_range()

  -- Get the lines from the buffer (0-indexed API, strict end index)
  local lines = vim.api.nvim_buf_get_lines(0, start_line - 1, end_line, false)
  local code_content = table.concat(lines, "\n")

  -- Format for LLM ingestion
  local location_ref
  if start_line == end_line then
    location_ref = string.format("%s:%d", file_path, start_line)
  else
    location_ref = string.format("%s:%d-%d", file_path, start_line, end_line)
  end

  local result = string.format("File: `%s`\n```%s\n%s\n```", location_ref, file_type, code_content)

  vim.fn.setreg("+", result) -- Copy to system clipboard

  if is_visual then
    exit_visual_mode()
  end
end

-- Keymaps
-- 'n' for Normal mode, 'v' for Visual mode
vim.keymap.set({ "n", "v" }, "<leader>cp", copy_path_ref, { desc = "Copy path:line for AI" })
vim.keymap.set({ "n", "v" }, "<leader>cc", copy_code_context, { desc = "Copy code block for AI" })
