return {
  "neovim/nvim-lspconfig",
  dependencies = {
    "mason-org/mason.nvim",
    "mason-org/mason-lspconfig.nvim",
    "bitpoke/wordpress.nvim",
  },
  config = function()
    require("mason-lspconfig").setup({
      ensure_installed = {
        "gopls", "clangd", "lua_ls", "pyright", "ts_ls",
        "jsonls", "yamlls", "html", "cssls",
        "kotlin_language_server", "intelephense", "marksman", "jinja_lsp",
        "rust_analyzer", "jdtls", -- installed here, but NOT auto-enabled (see below)
      },
      automatic_enable = {
        exclude = { "rust_analyzer", "jdtls" },
      },
    })

    vim.lsp.config("*", {
      capabilities = require("blink.cmp").get_lsp_capabilities(),
    })

    -- WordPress support: recognize WP core/theme/plugin functions via intelephense
    -- stubs (avoids "undefined function" on wp_* globals), and cover files that
    -- wordpress.nvim retags as "php.wp" (anything under wp-admin/wp-includes/wp-content)
    local wp = require("wordpress")
    vim.lsp.config("intelephense", {
      filetypes = wp.intelephense.filetypes,
      settings = wp.intelephense.settings,
    })

    -- same retagging happens to WP-tree JS files ("javascript.wp"); keep ts_ls on them
    vim.lsp.config("ts_ls", {
      filetypes = vim.list_extend(
        vim.deepcopy((vim.lsp.config.ts_ls or {}).filetypes or {}),
        { "javascript.wp" }
      ),
    })

    vim.api.nvim_create_autocmd("LspAttach", {
      callback = function(args)
        local opts = { buffer = args.buf, silent = true }
        vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
        vim.keymap.set("n", "gr", vim.lsp.buf.references, opts)
        vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
        vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts)
        vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, opts)
      end,
    })
  end,
}
