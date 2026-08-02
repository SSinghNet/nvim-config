return {
  "folke/snacks.nvim",
  priority = 1000,
  lazy = false,
  opts = {
    -- gives vim.notify a proper popup + history, which cmdheight=0 (options.lua)
    -- otherwise leaves nowhere to land
    notifier = { enabled = true },
    dashboard = { enabled = true },
    lazygit = { enabled = true },
  },
  keys = {
    { "<leader>gg", function() Snacks.lazygit() end, desc = "Lazygit" },
  },
}
