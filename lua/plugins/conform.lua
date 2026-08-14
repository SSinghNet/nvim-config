return {
  "stevearc/conform.nvim",
  event = "BufWritePre",
  config = function()
    require("conform").setup({
      formatters_by_ft = {
        go = { "gofmt" },
        rust = { "rustfmt" },
        c = { "clang-format" },
        lua = { "stylua" },
        python = { "black" },
        javascript = { "prettier" },
        typescript = { "prettier" },
        javascriptreact = { "prettier" },
        typescriptreact = { "prettier" },
        ["javascript.wp"] = { "prettier" },
        json = { "prettier" },
        yaml = { "prettier" },
        html = { "prettier" },
        css = { "prettier" },
        markdown = { "prettier" },
        kotlin = { "ktlint" },
        -- all php formatted with the WordPress ruleset (see plugins/wordpress.lua for
        -- how "php.wp" gets tagged) -- kept as two entries so a deliberately non-WP
        -- project can repoint just one line
        php = { "phpcbf" },
        ["php.wp"] = { "phpcbf" },
        -- java: no reliable standalone CLI in conform's registry; falls back to jdtls' own
        -- formatting via `format_on_save.lsp_fallback` below.
      },
      formatters = {
        phpcbf = { prepend_args = { "--standard=WordPress" } },
      },
      format_on_save = {
        -- phpcbf reloading the full WordPress ruleset (see php.wp above) consistently
        -- takes ~1.4s, well past a 500ms budget -- conform just warns "timeout" and
        -- silently skips formatting rather than erroring, so this was easy to miss.
        timeout_ms = 3000,
        lsp_fallback = true,
      },
    })
  end,
}
