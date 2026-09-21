local function pick(name, opts)
  require("config.tabs").to_editor_tab()
  require("telescope.builtin")[name](opts)
end

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
    -- Pickers that open files run from the editor tab: picking from a Diffview
    -- or terminal tab would otherwise replace a diff pane / the terminal.
    { "<leader>ff", function() pick("find_files") end, desc = "Find files" },
    { "<leader>fg", function() pick("live_grep") end, desc = "Live grep" },
    { "<leader>fb", function() pick("buffers") end, desc = "Buffers" },
    { "<leader>fh", function() require("telescope.builtin").help_tags() end, desc = "Help tags" },
    { "<leader>fo", function() pick("oldfiles") end, desc = "Recent files" },
    {
      "<leader>fw",
      function()
        -- read the word before switching tabs: it's the one under the cursor here
        local word = vim.fn.expand("<cword>")
        pick("grep_string", { search = word })
      end,
      desc = "Find word under cursor",
    },
    { "<leader>fd", function() pick("diagnostics") end, desc = "Diagnostics" },
    { "<leader>fr", function() pick("resume") end, desc = "Resume last search" },
  },
}

