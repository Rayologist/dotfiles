vim.g.netrw_liststyle = 3
vim.g.netrw_banner = 0
vim.g.netrw_winsize = 25

-- vim.opt.guicursor = ""
vim.opt.winborder = "rounded"

vim.opt.pumheight = 10

vim.opt.nu = true
vim.opt.relativenumber = true

vim.opt.autoread = true

-- indent will be handled by the plugin: indent-o-matic
vim.opt.tabstop = 4
vim.opt.softtabstop = 4
vim.opt.shiftwidth = 2
vim.opt.expandtab = true
--
vim.opt.showmode = false
vim.opt.laststatus = 3

vim.opt.smartindent = true
vim.opt.wrap = false

-- search
vim.opt.ignorecase = true
vim.opt.smartcase = true

-- vim.opt.hlsearch = false
vim.opt.incsearch = true

-- Sets how neovim will display certain whitespace characters in the editor.
--  See `:help 'list'`
--  and `:help 'listchars'`
vim.opt.list = true
vim.opt.listchars = { tab = "» ", trail = "·", nbsp = "␣" }

-- windows
vim.opt.splitright = true
vim.opt.splitbelow = true

--
vim.opt.swapfile = false
vim.opt.backup = false
vim.opt.undodir = os.getenv("HOME") .. "/.vim/undodir"
vim.opt.undofile = true

vim.opt.termguicolors = true

vim.opt.scrolloff = 10
vim.signcolum = "yes"
vim.opt.isfname:append("@-@")

vim.opt.updatetime = 50

-- vim.opt.colorcolumn = "80"

vim.wo.signcolumn = "yes"

vim.api.nvim_set_hl(0, "LineNrAbove", { fg = "#585b70", bold = false })
vim.api.nvim_set_hl(0, "LineNr", { fg = "#cdd6f4", bold = true })
vim.api.nvim_set_hl(0, "LineNrBelow", { fg = "#585b70", bold = false })
