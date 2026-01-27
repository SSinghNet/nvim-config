return {
  "mfussenegger/nvim-lint",
  config = function()
    local lint = require("lint")


    lint.linters_by_ft = {
        go = { "golangcilint" },
        javascript = { "eslint" },
        typescript = { "eslint" },
        javascriptreact = { "eslint" },
        typescriptreact = { "eslint" },
    }

    vim.api.nvim_create_autocmd({ "BufWritePost" }, {
      callback = function()
        lint.try_lint()
      end,
    })
  end,
}

