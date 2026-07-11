return {
  "neovim/nvim-lspconfig",
  dependencies = {
    "mason-org/mason.nvim",
    "mason-org/mason-lspconfig.nvim",
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
