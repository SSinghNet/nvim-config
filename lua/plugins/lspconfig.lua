return {
  "neovim/nvim-lspconfig",
  dependencies = {
    "mason-org/mason.nvim",
    "mason-org/mason-lspconfig.nvim",
    "bitpoke/wordpress.nvim",
    "b0o/schemastore.nvim",
  },
  config = function()
    require("mason-lspconfig").setup({
      ensure_installed = {
        "gopls", "clangd", "lua_ls", "pyright", "vtsls",
        "jsonls", "yamlls", "html", "cssls",
        "kotlin_language_server", "intelephense", "marksman", "jinja_lsp",
        "groovyls", "gradle_ls", -- groovy filetype: build.gradle DSL, Jenkinsfiles
        "rust_analyzer", "jdtls", -- installed here, but NOT auto-enabled (see below)
        "tailwindcss", "eslint", "emmet_ls",
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

    -- same retagging happens to WP-tree JS files ("javascript.wp"); keep vtsls on them
    vim.lsp.config("vtsls", {
      filetypes = vim.list_extend(
        vim.deepcopy((vim.lsp.config.vtsls or {}).filetypes or {}),
        { "javascript.wp" }
      ),
    })

    -- Tailwind CSS: also cover WP-tree JS files, and teach it to look inside
    -- cva()/cx()/cn() helper calls (common in shadcn-style components) for class names
    vim.lsp.config("tailwindcss", {
      filetypes = vim.list_extend(
        vim.deepcopy((vim.lsp.config.tailwindcss or {}).filetypes or {}),
        { "javascript.wp" }
      ),
      settings = {
        tailwindCSS = {
          experimental = {
            classRegex = {
              "cva\\(([^)]*)\\)",
              "cx\\(([^)]*)\\)",
              { "cn\\(([^)]*)\\)", "[\"'`]([^\"'`]*).*?[\"'`]" },
            },
          },
        },
      },
    })

    -- ESLint LSP (distinct from nvim-lint's CLI-based "eslint" linter in
    -- plugins/nvim-lint.lua, which stays for diagnostics-on-write). This one adds
    -- code actions ("fix all problems", organize imports) and auto-fixes on save
    -- via the LspEslintFixAll command it registers. Only attaches in projects that
    -- actually have an ESLint config file -- silent no-attach elsewhere is expected.
    local base_eslint_on_attach = vim.lsp.config.eslint.on_attach
    vim.lsp.config("eslint", {
      filetypes = vim.list_extend(
        vim.deepcopy((vim.lsp.config.eslint or {}).filetypes or {}),
        { "javascript.wp" }
      ),
      on_attach = function(client, bufnr)
        base_eslint_on_attach(client, bufnr)
        vim.api.nvim_create_autocmd("BufWritePre", {
          buffer = bufnr,
          command = "LspEslintFixAll",
        })
      end,
    })

    -- Emmet: upstream's default filetypes omit plain javascript/typescript, which
    -- we want for JSX/TSX-adjacent abbreviation expansion
    vim.lsp.config("emmet_ls", {
      filetypes = { "html", "css", "javascript", "javascriptreact", "typescript", "typescriptreact" },
    })

    -- JSON schema validation/completion (package.json, tsconfig.json, etc.) via
    -- SchemaStore's catalog. Note: shadcn's components.json has no public
    -- SchemaStore entry, so it won't get schema help here -- known catalog gap.
    vim.lsp.config("jsonls", {
      settings = {
        json = {
          schemas = require("schemastore").json.schemas(),
          validate = { enable = true },
        },
      },
    })

    vim.api.nvim_create_autocmd("LspAttach", {
      callback = function(args)
        local opts = { buffer = args.buf, silent = true }
        vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
        vim.keymap.set("n", "gr", vim.lsp.buf.references, opts)
        vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
        vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts)
        vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, opts)

        local client = vim.lsp.get_client_by_id(args.data.client_id)
        if client and client:supports_method("textDocument/inlayHint") then
          vim.keymap.set("n", "<leader>uh", function()
            local filter = { bufnr = args.buf }
            vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled(filter), filter)
          end, vim.tbl_extend("force", opts, { desc = "Toggle inlay hints" }))
        end
      end,
    })
  end,
}
