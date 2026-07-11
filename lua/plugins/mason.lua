return {
	"mason-org/mason.nvim",
	dependencies = { "WhoIsSethDaniel/mason-tool-installer.nvim" },
	config = function()
		require("mason").setup({})
		require("mason-tool-installer").setup({
			ensure_installed = {
				-- rustfmt is intentionally excluded: it ships with rustup, not mason
				"stylua", "prettier", "black", "ktlint", "php-cs-fixer",
				-- phpcs/phpcbf: lint/format WordPress code (see plugins/nvim-lint.lua,
				-- plugins/conform.lua); WPCS ruleset itself still needs a one-time
				-- `composer global require wp-coding-standards/wpcs` + `phpcs --config-set
				-- installed_paths ...` against this mason install to enable --standard=WordPress
				"phpcs", "phpcbf",
				-- java-debug-adapter/java-test: give jdtls its dap bundles (see plugins/jdtls.lua);
				-- go/python/rust/php debug adapters are handled by mason-nvim-dap (plugins/dap.lua)
				"java-debug-adapter", "java-test",
				-- required by nvim-treesitter (main branch) to compile parsers
				"tree-sitter-cli",
			},
		})
	end,
}
