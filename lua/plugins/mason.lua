return {
	"mason-org/mason.nvim",
	dependencies = { "WhoIsSethDaniel/mason-tool-installer.nvim" },
	config = function()
		require("mason").setup({})
		require("mason-tool-installer").setup({
			ensure_installed = {
				-- rustfmt is intentionally excluded: it ships with rustup, not mason
				"stylua", "prettier", "black", "ktlint", "php-cs-fixer",
				-- required by nvim-treesitter (main branch) to compile parsers
				"tree-sitter-cli",
			},
		})
	end,
}
