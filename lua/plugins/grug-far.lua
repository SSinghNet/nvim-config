return {
  "MagicDuck/grug-far.nvim",
  cmd = "GrugFar",
  opts = {},
  keys = {
    { "<leader>sr", function() require("grug-far").open() end, desc = "Search and replace" },
  },
}
