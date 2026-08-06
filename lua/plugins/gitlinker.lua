return {
  "linrongbin16/gitlinker.nvim",
  cmd = "GitLink",
  opts = {},
  keys = {
    {
      "<leader>gl",
      function() require("gitlinker").link() end,
      mode = { "n", "v" },
      desc = "Copy GitHub permalink",
    },
  },
}
