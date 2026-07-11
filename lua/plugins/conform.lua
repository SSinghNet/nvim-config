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
        json = { "prettier" },
        yaml = { "prettier" },
        html = { "prettier" },
        css = { "prettier" },
        markdown = { "prettier" },
        kotlin = { "ktlint" },
        php = { "php_cs_fixer" },
        -- java: no reliable standalone CLI in conform's registry; falls back to jdtls' own
        -- formatting via `format_on_save.lsp_fallback` below.
      },
      format_on_save = {
        timeout_ms = 500,
        lsp_fallback = true,
      },
    })
  end,
}
