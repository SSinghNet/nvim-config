return {
	"nvim-treesitter/nvim-treesitter",
	branch = "main",
	event = "BufReadPost",
	build = ":TSUpdate",
	dependencies = {
		{ "nvim-treesitter/nvim-treesitter-textobjects", branch = "main" },
	},
	config = function()
		-- the "main" branch rewrite has no ensure_installed/highlight config keys;
		-- parsers are installed explicitly (async, no-op if already installed)
		require("nvim-treesitter").install({
			"go",
			"gomod",
			"java",
			"kotlin",
			"groovy",
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

		require("nvim-treesitter-textobjects").setup({
			select = {
				lookahead = true,
				selection_modes = {
					["@parameter.outer"] = "v",
					["@function.outer"] = "V",
					["@class.outer"] = "V",
				},
				include_surrounding_whitespace = false,
			},
			move = {
				set_jumps = true,
			},
		})

		local select = require("nvim-treesitter-textobjects.select")
		local move = require("nvim-treesitter-textobjects.move")

		local function map_select(lhs, query)
			vim.keymap.set({ "x", "o" }, lhs, function()
				select.select_textobject(query, "textobjects")
			end, { desc = "Select " .. query })
		end

		map_select("af", "@function.outer")
		map_select("if", "@function.inner")
		map_select("ac", "@class.outer")
		map_select("ic", "@class.inner")
		map_select("aa", "@parameter.outer")
		map_select("ia", "@parameter.inner")

		local function map_move(lhs, fn, query, desc)
			vim.keymap.set({ "n", "x", "o" }, lhs, function()
				fn(query, "textobjects")
			end, { desc = desc })
		end

		-- ]c/[c intentionally left free for gitsigns hunk navigation
		map_move("]f", move.goto_next_start, "@function.outer", "Next function start")
		map_move("[f", move.goto_previous_start, "@function.outer", "Previous function start")
	end,
}
