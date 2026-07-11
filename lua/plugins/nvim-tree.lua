return {
  "nvim-tree/nvim-tree.lua",
  version = "*",
  lazy = false,
  dependencies = {
    "nvim-tree/nvim-web-devicons",
  },
  config = function()
    require("nvim-tree").setup({
      filters = {
        dotfiles = false,
        git_ignored = false,
      },
    })
  end,
  keys = {
    -- Toggle tree
    { "<leader>e", "<cmd>NvimTreeToggle<CR>", desc = "Toggle NvimTree" },

    -- Focus tree
    { "<leader>o", "<cmd>NvimTreeFocus<CR>", desc = "Focus NvimTree" },

    -- Find current file in tree
    { "<leader>f", "<cmd>NvimTreeFindFile<CR>", desc = "Find file in NvimTree" },
  },
}

