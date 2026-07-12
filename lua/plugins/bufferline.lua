return {
  "akinsho/bufferline.nvim",
  dependencies = { "nvim-tree/nvim-web-devicons" },
  event = "VeryLazy",
  opts = {
    options = {
      diagnostics = "nvim_lsp",
      always_show_bufferline = true,
      offsets = {
        { filetype = "NvimTree", text = "File Explorer", separator = true },
      },
    },
  },
  keys = {
    { "<S-l>", "<cmd>BufferLineCycleNext<CR>", desc = "Next buffer" },
    { "<S-h>", "<cmd>BufferLineCyclePrev<CR>", desc = "Previous buffer" },
    {
      "<leader>bt",
      function()
        local opts = require("bufferline.config").options
        opts.always_show_bufferline = not opts.always_show_bufferline
        vim.cmd("redrawtabline")
      end,
      desc = "Toggle bufferline",
    },
  },
}
