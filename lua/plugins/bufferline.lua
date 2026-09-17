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
      -- default close_command is a raw `bdelete! %d`: if this buffer is also
      -- open in another tab, :bdelete closes the window here (rather than
      -- falling back to an empty buffer) and leaves nvim-tree as the sole
      -- survivor, ballooning to fill the tab (same class of bug as the
      -- nvim-tree/Claude panel width fix in config/options.lua). Switch every
      -- window showing this buffer to an adjacent one first, same approach
      -- as the <leader>bd keymap in config/keymaps.lua.
      close_command = function(bufnr)
        -- Defense in depth: this buffer normally can't be Claude's own
        -- terminal (unlisted, never shown as a bufferline tab), but if any
        -- window displaying it is winfixbuf-protected, BufferLineCyclePrev
        -- there would fail silently (pcall) and the bdelete! below would
        -- then close that protected window as a side effect -- the same
        -- failure class this fix exists to prevent, just relocated.
        for _, win in ipairs(vim.fn.win_findbuf(bufnr)) do
          if vim.wo[win].winfixbuf then
            vim.notify("Can't close: shown in a protected window", vim.log.levels.WARN, { title = "bufferline" })
            return
          end
        end
        for _, win in ipairs(vim.fn.win_findbuf(bufnr)) do
          vim.api.nvim_win_call(win, function()
            pcall(vim.cmd, "BufferLineCyclePrev")
          end)
        end
        if vim.api.nvim_buf_is_valid(bufnr) then
          vim.cmd("bdelete! " .. bufnr)
        end
      end,
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
