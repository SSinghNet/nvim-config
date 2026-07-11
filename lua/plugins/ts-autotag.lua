return {
  "windwp/nvim-ts-autotag",
  ft = {
    "html", "xml", "markdown",
    "php", "php.wp",
    "javascript", "javascript.wp", "javascriptreact", "typescript", "typescriptreact",
  },
  opts = {
    -- php.wp/javascript.wp (see plugins/wordpress.lua) aren't in the plugin's own alias
    -- table, so map them onto the same tag configs as their base filetype. Point straight
    -- at the plugin's real registered configs ("html"/"typescriptreact", which is what
    -- "php"/"javascript" themselves alias to below) rather than chaining through
    -- "php"/"javascript": the plugin applies its aliases with `pairs()` in setup, which
    -- has no defined order, so aliasing to an alias that may not have been applied yet
    -- intermittently fails with "No existing filetype 'php' to alias to!".
    aliases = {
      ["php.wp"] = "html",
      ["javascript.wp"] = "typescriptreact",
    },
  },
}
