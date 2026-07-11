return {
  "lewis6991/gitsigns.nvim",
  event = "BufReadPre",
  opts = {},
  keys = {
    { "<leader>gp", function() require("gitsigns").preview_hunk() end, desc = "Preview git hunk" },
    { "<leader>gb", function() require("gitsigns").blame_line() end, desc = "Git blame line" },
    { "<leader>gr", function() require("gitsigns").reset_hunk() end, desc = "Reset git hunk" },
  },
}
