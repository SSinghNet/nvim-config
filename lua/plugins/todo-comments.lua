return {
  "folke/todo-comments.nvim",
  dependencies = { "nvim-lua/plenary.nvim", "folke/trouble.nvim" },
  event = "VeryLazy",
  opts = {},
  keys = {
    { "<leader>xt", "<cmd>Trouble todo toggle<CR>", desc = "Todo (Trouble)" },
  },
}
