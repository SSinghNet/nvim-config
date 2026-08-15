return {
  "vuki656/package-info.nvim",
  dependencies = { "MunifTanjim/nui.nvim" },
  ft = "json", -- fires for any json file; package-info.nvim no-ops on non-package.json buffers
  keys = {
    { "<leader>ns", function() require("package-info").show() end, desc = "Show package versions" },
    { "<leader>nc", function() require("package-info").hide() end, desc = "Hide package versions" },
    { "<leader>nt", function() require("package-info").toggle() end, desc = "Toggle package versions" },
    { "<leader>nu", function() require("package-info").update() end, desc = "Update package" },
    { "<leader>nd", function() require("package-info").delete() end, desc = "Delete package" },
    { "<leader>ni", function() require("package-info").install() end, desc = "Install a new package" },
    { "<leader>np", function() require("package-info").change_version() end, desc = "Change package version" },
  },
  opts = {},
}
