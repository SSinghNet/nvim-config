return {
  "vuki656/package-info.nvim",
  dependencies = { "MunifTanjim/nui.nvim" },
  ft = "json", -- fires for any json file; package-info.nvim no-ops on non-package.json buffers
  -- p-prefix, not n- -- n is neotest's group (plugins/neotest.lua) and was silently
  -- shadowing its <leader>ns/<leader>nt mappings
  keys = {
    { "<leader>ps", function() require("package-info").show() end, desc = "Show package versions" },
    { "<leader>ph", function() require("package-info").hide() end, desc = "Hide package versions" },
    { "<leader>pt", function() require("package-info").toggle() end, desc = "Toggle package versions" },
    { "<leader>pu", function() require("package-info").update() end, desc = "Update package" },
    { "<leader>pd", function() require("package-info").delete() end, desc = "Delete package" },
    { "<leader>pi", function() require("package-info").install() end, desc = "Install a new package" },
    { "<leader>pv", function() require("package-info").change_version() end, desc = "Change package version" },
  },
  opts = {},
}
