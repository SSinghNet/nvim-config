return {
	"nvim-treesitter/nvim-treesitter",
	branch = "main",
	event = "BufReadPost",
	build = ":TSUpdate",
	config = function()
		-- the "main" branch rewrite has no ensure_installed/highlight config keys;
		-- parsers are installed explicitly (async, no-op if already installed)
		require("nvim-treesitter").install({
			"go",
			"gomod",
			"java",
			"kotlin",
			"php",
			"rust",
			"c",
			"lua",
			"python",
			"javascript",
			"typescript",
			"tsx",
			"json",
			"yaml",
			"html",
			"css",
			"jinja",
			"markdown",
			"markdown_inline",
		})
	end,
}
