return {
	"nvim-treesitter/nvim-treesitter",
	event = "BufReadPost", 
    build = ":TSUpdate",
	config = function()
	    require("nvim-treesitter.config").setup({
            highlight = { 
                enable = true,
                additional_vim_regex_highlighting = false,
            },
            sync_install = false,
            ensure_installed = {
                "go", 
                "gomod", 
                "java", 
                "c", 
                "lua", 
                "python", 
                "javascript", 
                "typescript"
            },
	    })
	end,
}
