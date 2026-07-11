return {
  "windwp/nvim-ts-autotag",
  ft = {
    "html", "xml", "markdown",
    "php", "php.wp",
    "javascript", "javascript.wp", "javascriptreact", "typescript", "typescriptreact",
  },
  opts = {
    -- php.wp/javascript.wp (see plugins/wordpress.lua) aren't in the plugin's own
    -- alias table, so map them onto the same tag configs as their base filetype
    aliases = {
      ["php.wp"] = "php",
      ["javascript.wp"] = "javascript",
    },
  },
}
