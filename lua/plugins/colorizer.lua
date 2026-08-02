return {
  "catgoose/nvim-colorizer.lua",
  event = "BufReadPre",
  opts = {
    filetypes = {
      "css",
      "scss",
      "html",
      "javascript",
      "javascript.wp",
      "typescript",
      "typescriptreact",
      "lua",
    },
    user_default_options = {
      names = false, -- don't highlight color names like "red"
    },
  },
}
