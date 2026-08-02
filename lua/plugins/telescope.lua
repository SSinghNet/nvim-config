return {
  "nvim-telescope/telescope.nvim",
  version = "*",
  dependencies = {
    "nvim-lua/plenary.nvim",
    { "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
    "nvim-telescope/telescope-ui-select.nvim",
  },
  config = function()
    require("telescope").setup({
      extensions = {
        ["ui-select"] = {
          require("telescope.themes").get_dropdown({}),
        },
      },
    })
    pcall(require("telescope").load_extension, "fzf")
    pcall(require("telescope").load_extension, "ui-select")
  end,
  keys = {
    { "<leader>ff", function() require("telescope.builtin").find_files() end, desc = "Find files" },
    { "<leader>fg", function() require("telescope.builtin").live_grep() end, desc = "Live grep" },
    { "<leader>fb", function() require("telescope.builtin").buffers() end, desc = "Buffers" },
    { "<leader>fh", function() require("telescope.builtin").help_tags() end, desc = "Help tags" },
    { "<leader>fo", function() require("telescope.builtin").oldfiles() end, desc = "Recent files" },
    { "<leader>fw", function() require("telescope.builtin").grep_string() end, desc = "Find word under cursor" },
    { "<leader>fd", function() require("telescope.builtin").diagnostics() end, desc = "Diagnostics" },
    { "<leader>fr", function() require("telescope.builtin").resume() end, desc = "Resume last search" },
  },
}

