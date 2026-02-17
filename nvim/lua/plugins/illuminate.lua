return {
  "RRethy/vim-illuminate",
  opts = {
    filetypes_denylist = { "neo-tree" },
  },
  config = function(_, opts)
    require("illuminate").configure(opts)
  end,
}
