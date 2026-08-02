return {
  "nvim-neotest/neotest",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-neotest/nvim-nio",
    "nvim-treesitter/nvim-treesitter",
    "nvim-neotest/neotest-go",
    "nvim-neotest/neotest-python",
    "nvim-neotest/neotest-jest",
    "olimorris/neotest-phpunit",
  },
  keys = {
    { "<leader>nt", function() require("neotest").run.run() end, desc = "Run nearest test" },
    { "<leader>nf", function() require("neotest").run.run(vim.fn.expand("%")) end, desc = "Run test file" },
    { "<leader>no", function() require("neotest").output.open({ enter = true }) end, desc = "Test output" },
    { "<leader>ns", function() require("neotest").summary.toggle() end, desc = "Test summary" },
  },
  config = function()
    -- Rust tests already run through rustaceanvim (:RustLsp testables) and
    -- Java/Kotlin through jdtls -- both wire their own DAP-integrated test
    -- runners, so no neotest adapter is registered for them here.
    require("neotest").setup({
      adapters = {
        require("neotest-go"),
        require("neotest-python"),
        require("neotest-jest"),
        require("neotest-phpunit"),
      },
    })
  end,
}
