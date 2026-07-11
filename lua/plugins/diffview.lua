return {
  "sindrets/diffview.nvim",
  cmd = { "DiffviewOpen", "DiffviewFileHistory" },
  opts = {},
  keys = {
    { "<leader>gd", "<cmd>DiffviewOpen<CR>", desc = "Diff view" },
    { "<leader>gh", "<cmd>DiffviewFileHistory<CR>", desc = "File history (Diffview)" },
  },
}
