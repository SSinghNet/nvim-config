return {
  "pwntester/octo.nvim",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-telescope/telescope.nvim",
    "nvim-tree/nvim-web-devicons",
  },
  cmd = "Octo",
  opts = {},
  keys = {
    { "<leader>gi", "<cmd>Octo issue list<CR>", desc = "GitHub issue list" },
    { "<leader>go", "<cmd>Octo pr list<CR>", desc = "GitHub PR list" },
  },
}
