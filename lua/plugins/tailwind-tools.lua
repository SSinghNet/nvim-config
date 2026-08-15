return {
  "luckasRanarison/tailwind-tools.nvim",
  name = "tailwind-tools",
  build = ":UpdateRemotePlugins",
  ft = { "css", "scss", "html", "javascript", "javascript.wp", "typescript", "javascriptreact", "typescriptreact" },
  dependencies = {
    "nvim-treesitter/nvim-treesitter",
    "neovim/nvim-lspconfig",
  },
  opts = {
    -- tailwindcss-language-server is already fully configured in plugins/lspconfig.lua
    -- (WP filetype coverage + cn()/cva() classRegex) -- don't let this plugin re-register
    -- or override it.
    server = {
      override = false,
    },
    document_color = {
      enabled = true,
      kind = "inline",
    },
    conceal = {
      enabled = false, -- keep raw class text visible; opt in later if wanted
    },
  },
}
