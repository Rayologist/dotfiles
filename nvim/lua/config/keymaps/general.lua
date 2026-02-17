vim.g.mapleader = " "
vim.g.maplocalleader = "  "

vim.keymap.set("n", "<leader>e", vim.cmd.Ex)
vim.keymap.set("n", "<leader><space>", function()
  vim.cmd("b#")
end)

vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv")
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv")

vim.keymap.set("n", "J", "mzJ`z")

vim.keymap.set("n", "<C-d>", "<C-d>zz")
vim.keymap.set("n", "<C-u>", "<C-u>zz")

vim.keymap.set("n", "n", "nzzzv")
vim.keymap.set("n", "N", "Nzzzv")

vim.keymap.set("x", "<leader>P", '"_dP')
vim.keymap.set({ "n", "v" }, "<leader>p", '"+p')

vim.keymap.set({ "n", "v" }, "<leader>y", '"+y')
vim.keymap.set("n", "<leader>Y", '"+Y')

vim.keymap.set({ "n", "v" }, "<leader>d", '"_d')

vim.keymap.set({ "n", "v" }, "gw", "<C-w>w", { desc = "Go to next window or nth window" })

-- disable native completion
vim.keymap.set("i", "<C-n>", function() end, { desc = "Disable native completion" })
vim.keymap.set("i", "<C-p>", function() end, { desc = "Disable native completion" })

-- vim.keymap.set(
--   "n",
--   "<leader>fm",
--   function() vim.lsp.buf.format() end
-- )

-- tj: Toggle hlsearch if it's on, otherwise just do "enter"
vim.keymap.set("n", "<CR>", function()
  if vim.v.hlsearch == 1 then
    vim.cmd.nohl()
    return ""
  else
    return "k<CR>"
  end
end, { expr = true })

vim.keymap.set("n", "<leader>as", function()
  local word = vim.fn.expand("<cword>")
  if word == "" or word:match("^%s*$") then
    vim.ui.input({
      prompt = "Enter word to add to cspell: ",
    }, function(input)
      if input and input ~= "" then
        vim.cmd("CSpellAdd " .. input)
      end
    end)
  else
    vim.cmd("CSpellAdd " .. word)
  end
end, { desc = "Add CSpell" })

vim.keymap.set("n", "<leader>wv", "<C-w>v", { desc = "Split window vertically" })
vim.keymap.set("n", "<leader>ws", "<C-w>s", { desc = "Split window horizontally" })
vim.keymap.set("n", "<leader>w=", "<C-w>=", { desc = "Make splits equal size" })

vim.keymap.set("n", "<leader>ww", "<C-w>w", { desc = "Make splits equal size" })

-- <C-w>d
vim.keymap.set("n", "<leader>wd", vim.diagnostic.open_float, { desc = "Show diagnostic" })

vim.keymap.set("n", "<leader>su", [[:%s/\<<C-r><C-w>\>/<C-r><C-w>/gI<Left><Left><Left>]])

-- quick fix list
-- im.keymap.set("n", "<C-k>", "<cmd>cnext<CR>zz")
-- vim.keymap.set("n", "<C-j>", "<cmd>cprev<CR>zz")
-- vim.keymap.set("n", "<leader>k", "<cmd>lnext<CR>zz")
-- vim.keymap.set("n", "<leader>j", "<cmd>lprev<CR>zz")
