return {
	"mason-org/mason.nvim",
	dependencies = { "WhoIsSethDaniel/mason-tool-installer.nvim" },
	config = function()
		require("mason").setup({})
		require("mason-tool-installer").setup({
			ensure_installed = {
				-- rustfmt is intentionally excluded: it ships with rustup, not mason
				"stylua", "prettier", "black", "ktlint",
				-- phpcs/phpcbf: lint/format WordPress code (see plugins/nvim-lint.lua,
				-- plugins/conform.lua); WPCS ruleset itself still needs a one-time
				-- `composer global require wp-coding-standards/wpcs` + `phpcs --config-set
				-- installed_paths ...` against this mason install to enable --standard=WordPress
				"phpcs", "phpcbf",
				-- java-debug-adapter/java-test: give jdtls its dap bundles (see plugins/jdtls.lua);
				-- go/python/rust/php debug adapters are handled by mason-nvim-dap (plugins/dap.lua)
				"java-debug-adapter", "java-test",
				-- vscode-spring-boot-tools: consumed directly by spring-boot.nvim (see
				-- plugins/spring-boot.lua), not through mason-lspconfig
				"vscode-spring-boot-tools",
				-- npm-groovy-lint: Groovy/Gradle-DSL linter (see plugins/nvim-lint.lua)
				"npm-groovy-lint",
				-- required by nvim-treesitter (main branch) to compile parsers
				"tree-sitter-cli",
				-- CSS linter (see plugins/nvim-lint.lua) and Node/Next.js debug adapter
				-- (see plugins/dap.lua) -- not LSP servers, so they go here rather than
				-- mason-lspconfig's ensure_installed
				"stylelint",
				"js-debug-adapter",
			},
		})
	end,
}
