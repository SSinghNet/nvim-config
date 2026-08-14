return {
  "mfussenegger/nvim-lint",
  config = function()
    local lint = require("lint")

    -- all php linted with the WordPress ruleset -- see plugins/wordpress.lua for how
    -- "php.wp" gets tagged; plain php uses the same standard too
    local phpcs_wordpress = vim.deepcopy(lint.linters.phpcs)
    table.insert(phpcs_wordpress.args, #phpcs_wordpress.args, "--standard=WordPress")
    lint.linters.phpcs_wordpress = phpcs_wordpress

    lint.linters_by_ft = {
        go = { "golangcilint" },
        javascript = { "eslint" },
        typescript = { "eslint" },
        javascriptreact = { "eslint" },
        typescriptreact = { "eslint" },
        ["javascript.wp"] = { "eslint" },
        php = { "phpcs_wordpress" },
        ["php.wp"] = { "phpcs_wordpress" },
        groovy = { "npm-groovy-lint" },
        kotlin = { "ktlint" },
    }

    vim.api.nvim_create_autocmd({ "BufWritePost" }, {
      callback = function()
        lint.try_lint()
      end,
    })
  end,
}

