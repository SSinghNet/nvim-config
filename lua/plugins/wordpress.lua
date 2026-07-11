return {
  "bitpoke/wordpress.nvim",
  -- must load at startup (not lazily) since its filetype.lua/ftplugin need to be on
  -- the runtimepath before Neovim assigns filetypes to buffers
  lazy = false,
  config = function()
    -- files get retagged "php.wp" / "javascript.wp"; keep them on the php/javascript
    -- treesitter parsers instead of trying (and failing) to load parsers by those names
    vim.treesitter.language.register("php", "php.wp")
    vim.treesitter.language.register("javascript", "javascript.wp")
  end,
}
