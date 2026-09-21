-- Diffview has no default close key; :DiffviewClose is the only way out.
-- `q` is bound on the side panels only: in the diff windows themselves it
-- would shadow macro recording on real, editable file buffers, so there the
-- <leader>gd toggle is what closes the view.
local close = { "n", "q", "<cmd>DiffviewClose<CR>", { desc = "Close Diffview" } }

return {
  "dlyongemallo/diffview-plus.nvim",
  cmd = { "DiffviewOpen", "DiffviewFileHistory" },
  opts = {
    keymaps = {
      file_panel = { close },
      file_history_panel = { close },
    },
  },
  config = function(_, opts)
    require("diffview").setup(opts)

    -- Diffview equalizes the diff panes when the view opens, but nvim only
    -- rescales windows proportionally on a terminal resize (the right pane
    -- ends up absorbing the whole change), and a resize while another tab
    -- is showing is never re-balanced for this one. The file panel is
    -- winfixwidth, so `wincmd =` leaves it alone and just evens out the diff
    -- panes. Skipped mid manual <C-Left>/<C-Right> resize (config/keymaps.lua).
    vim.api.nvim_create_autocmd({ "VimResized", "TabEnter" }, {
      group = vim.api.nvim_create_augroup("UserDiffviewEqual", { clear = true }),
      callback = function()
        vim.schedule(function()
          if vim.g.manually_resizing_window then
            return
          end
          if require("diffview.lib").get_current_view() then
            vim.cmd("wincmd =")
          end
        end)
      end,
    })
  end,
  keys = {
    {
      "<leader>gd",
      function()
        if require("diffview.lib").get_current_view() then
          vim.cmd("DiffviewClose")
        else
          vim.cmd("DiffviewOpen")
        end
      end,
      desc = "Toggle diff view",
    },
    { "<leader>gh", "<cmd>DiffviewFileHistory<CR>", desc = "File history (Diffview)" },
  },
}
