vim.api.nvim_create_autocmd({ "FocusGained", "BufEnter", "CursorHold", "CursorHoldI" }, {
  pattern = "*",
  callback = function()
    -- Ignore command-line mode
    if vim.fn.mode() == "c" then
      return
    end

    -- Ignore special buffers
    if vim.bo.buftype ~= "" then
      return
    end

    vim.cmd("checktime")
  end,
})

vim.api.nvim_create_autocmd("FileChangedShellPost", {
  pattern = "*",
  callback = function()
    require("gitsigns").refresh()
    require("diffview").emit("refresh_files")
  end,
})
