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
        php = { "php_cs_fixer" },
        -- WordPress-tagged PHP files (see plugins/wordpress.lua): use phpcbf with the
        -- WordPress ruleset instead of php_cs_fixer, since WPCS and PSR disagree on style
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
