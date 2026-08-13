-- must be set before lazy.nvim loads plugin keymaps (init.lua requires this file first)
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- neovim's virtual_lines handler only splits diagnostic messages on literal "\n",
-- it does not wrap by width -- long messages (or a bigger font shrinking window
-- columns) still run off the right edge. Word-wrap to the window width ourselves.
local function wrap_diagnostic_message(diagnostic)
    local width = vim.api.nvim_win_get_width(0) - 10
    local wrapped = {}
    for paragraph in diagnostic.message:gmatch("[^\n]+") do
        local line = ""
        for word in paragraph:gmatch("%S+") do
            if line == "" then
                line = word
            elseif #line + 1 + #word <= width then
                line = line .. " " .. word
            else
                table.insert(wrapped, line)
                line = word
            end
        end
        table.insert(wrapped, line)
    end
    return table.concat(wrapped, "\n")
end

vim.diagnostic.config({
    virtual_lines = {
        current_line = true,
        format = wrap_diagnostic_message,
    },
    signs = true,
    underline = true,
    update_in_insert = false,
    severity_sort = true,
})

-- disable netrw at the very start of your init.lua
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

-- optionally enable 24-bit colour
vim.opt.termguicolors = true

vim.o.cmdheight = 0

-- Hint: use `:h <option>` to figure out the meaning if needed
vim.opt.clipboard = 'unnamedplus'   -- use system clipboard 
vim.opt.completeopt = {'menu', 'menuone', 'noselect'}
vim.opt.mouse = 'a'                 -- allow the mouse to be used in nvim

-- Tab
vim.opt.tabstop = 4                 -- number of visual spaces per TAB
vim.opt.softtabstop = 4             -- number of spaces in tab when editing
vim.opt.shiftwidth = 4              -- insert 4 spaces on a tab
vim.opt.expandtab = true            -- tabs are spaces, mainly because of Python

-- UI config
vim.opt.number = true               -- show absolute number
vim.opt.relativenumber = true       -- add numbers to each line on the left side
vim.opt.cursorline = true           -- highlight cursor line underneath the cursor horizontally
vim.opt.splitbelow = true           -- open new vertical split bottom
vim.opt.splitright = true           -- open new horizontal splits right
-- Keep equalalways on (Vim default) so the editor window gets a fair share
-- when nvim-tree opens a file by splitting itself; winminwidth puts a floor
-- under every window (even winfixwidth ones like nvim-tree/the Claude panel)
-- so rebalancing can't crush one down to near-nothing.
vim.opt.winminwidth = 20
-- vim.opt.termguicolors = true        -- enable 24-bit RGB color in the TUI
vim.opt.showmode = false            -- we are experienced, wo don't need the "-- INSERT --" mode hint

-- Searching
vim.opt.incsearch = true            -- search as characters are entered
vim.opt.hlsearch = false            -- do not highlight matches
vim.opt.ignorecase = true           -- ignore case in searches by default
vim.opt.smartcase = true            -- but make it case sensitive if an uppercase is entered

-- Persist undo history across sessions (survives closing/reopening a file)
vim.opt.undofile = true

vim.cmd("set autowriteall")
vim.cmd("au InsertLeavePre,TextChanged,TextChangedP * if &modifiable && !&readonly | silent! update | endif")



vim.cmd [[
  hi link @function Function
  hi link @variable Identifier
  hi link @type Type
  hi link @constant Constant
  hi link @keyword Keyword
]]

vim.api.nvim_create_autocmd("FileType", {
  callback = function()
    pcall(vim.treesitter.start)
  end,
})

-- claudecode.nvim's terminal split has no self-healing width like nvim-tree's
-- view.resize() does. When Vim's window equalizer runs out of flexible
-- windows to redistribute (e.g. only nvim-tree + the Claude panel are open
-- and a file gets opened by splitting the tree window), it violates
-- 'winfixwidth' on Claude's panel as a last resort and squeezes it thin.
-- Snap it back to its configured width whenever the layout changes.
vim.api.nvim_create_autocmd("WinResized", {
  callback = function()
    for _, win in ipairs(vim.api.nvim_list_wins()) do
      local buf = vim.api.nvim_win_get_buf(win)
      if vim.bo[buf].buftype == "terminal" and vim.api.nvim_buf_get_name(buf):match("claude") then
        local target = math.floor(vim.o.columns * 0.30)
        if math.abs(vim.api.nvim_win_get_width(win) - target) > 2 then
          vim.api.nvim_win_set_width(win, target)
        end
      end
    end
  end,
})

