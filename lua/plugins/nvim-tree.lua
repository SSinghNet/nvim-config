return {
  "nvim-tree/nvim-tree.lua",
  version = "*",
  lazy = false,
  dependencies = {
    "nvim-tree/nvim-web-devicons",
  },
  config = function()
    require("nvim-tree").setup({
      renderer = {
        group_empty = true,
      },
      tab = {
        sync = {
          open = true,
          close = true,
        },
      },
      update_focused_file = {
        enable = true,
        update_root = false,
      },
      filters = {
        dotfiles = false,
        git_ignored = false,
      },
      on_attach = function(bufnr)
        local api = require("nvim-tree.api")
        api.config.mappings.default_on_attach(bufnr)

        -- Expand all, but don't descend into gitignored directories
        -- (they're shown per filters.git_ignored above, just not auto-expanded)
        vim.keymap.set("n", "E", function()
          api.tree.expand_all(nil, {
            expand_until = function(_, node)
              return not node:is_git_ignored()
            end,
          })
        end, { buffer = bufnr, noremap = true, silent = true, nowait = true, desc = "Expand All (skip gitignored)" })

        -- Collapse just the folder under the cursor (recursively), not the whole tree
        vim.keymap.set("n", "W", function()
          api.node.collapse()
        end, { buffer = bufnr, noremap = true, silent = true, nowait = true, desc = "Collapse folder under cursor" })
      end,
    })
  end,
  keys = {
    -- Toggle tree
    { "<leader>e", "<cmd>NvimTreeToggle<CR>", desc = "Toggle NvimTree" },

    -- Focus tree
    { "<leader>o", "<cmd>NvimTreeFocus<CR>", desc = "Focus NvimTree" },

    -- Find current file in tree
    { "<leader>f", "<cmd>NvimTreeFindFile<CR>", desc = "Find file in NvimTree" },
  },
}

