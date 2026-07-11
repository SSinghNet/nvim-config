return {
  "mfussenegger/nvim-lint",
  config = function()
    local lint = require("lint")

    -- WordPress-tagged PHP files ("php.wp", see plugins/wordpress.lua) get an extra
    -- --standard=WordPress flag; plain php files keep phpcs' default standard
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
        php = { "phpcs" },
        ["php.wp"] = { "phpcs_wordpress" },
    }

    vim.api.nvim_create_autocmd({ "BufWritePost" }, {
      callback = function()
        lint.try_lint()
      end,
    })
  end,
}

