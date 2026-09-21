return {
  "ThePrimeagen/harpoon",
  branch = "harpoon2",
  dependencies = { "nvim-lua/plenary.nvim" },
  config = function()
    require("harpoon"):setup()
  end,
  keys = {
    { "<leader>ha", function() require("harpoon"):list():add() end, desc = "Harpoon: add file" },
    -- jumping to a file runs from the editor tab so it can't replace a diff pane / the terminal
    { "<leader>he", function() require("config.tabs").to_editor_tab(); require("harpoon").ui:toggle_quick_menu(require("harpoon"):list()) end, desc = "Harpoon: quick menu" },
    { "<leader>1", function() require("config.tabs").to_editor_tab(); require("harpoon"):list():select(1) end, desc = "Harpoon: file 1" },
    { "<leader>2", function() require("config.tabs").to_editor_tab(); require("harpoon"):list():select(2) end, desc = "Harpoon: file 2" },
    { "<leader>3", function() require("config.tabs").to_editor_tab(); require("harpoon"):list():select(3) end, desc = "Harpoon: file 3" },
    { "<leader>4", function() require("config.tabs").to_editor_tab(); require("harpoon"):list():select(4) end, desc = "Harpoon: file 4" },
  },
}
