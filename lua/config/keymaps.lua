-- define common options
local opts = {
    noremap = true,      -- non-recursive
    silent = true,       -- do not show message
}

-----------------
-- Normal mode --
-----------------

-- Hint: see `:h vim.map.set()`
-- Better window navigation
vim.keymap.set('n', '<C-h>', '<C-w>h', opts)
vim.keymap.set('n', '<C-j>', '<C-w>j', opts)
vim.keymap.set('n', '<C-k>', '<C-w>k', opts)
vim.keymap.set('n', '<C-l>', '<C-w>l', opts)

-- Toggle line wrap
vim.keymap.set('n', '<M-z>', function() vim.wo.wrap = not vim.wo.wrap end, opts)

-- Toggle a terminal in the current window, like switching to any other buffer
-- (reuses the same terminal buffer across toggles instead of spawning a new tab)
local term_buf = nil
local prev_buf = nil

-- Claude's panel (winfixbuf, see config/options.lua) raises E1513 if you try
-- to swap its buffer, and nvim-tree's file browser shouldn't be clobbered
-- either -- find a different window for the scratch terminal instead.
local function find_window_for_terminal()
    for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
        if not vim.wo[win].winfixbuf and vim.bo[vim.api.nvim_win_get_buf(win)].filetype ~= "NvimTree" then
            return win
        end
    end
    return nil
end

local function toggle_terminal()
    local cur_win = vim.api.nvim_get_current_win()
    if vim.wo[cur_win].winfixbuf or vim.bo[vim.api.nvim_win_get_buf(cur_win)].filetype == "NvimTree" then
        local target = find_window_for_terminal()
        if target then
            vim.api.nvim_set_current_win(target)
        else
            -- vsplit inherits the CURRENT (excluded) window's buffer into the
            -- new split -- without :enew, cur_buf below would capture nvim-tree's
            -- or Claude's own buffer as "prev_buf", and toggling back would write
            -- that buffer into this window instead of a genuine previous file.
            vim.cmd('vsplit')
            vim.cmd('enew')
        end
    end

    local cur_buf = vim.api.nvim_get_current_buf()

    if term_buf and cur_buf == term_buf then
        if prev_buf and vim.api.nvim_buf_is_valid(prev_buf) then
            vim.api.nvim_win_set_buf(0, prev_buf)
        end
        return
    end

    prev_buf = cur_buf
    if term_buf and vim.api.nvim_buf_is_valid(term_buf) then
        vim.api.nvim_win_set_buf(0, term_buf)
    else
        vim.cmd('terminal')
        term_buf = vim.api.nvim_get_current_buf()

        -- typing `exit` ends the shell job but leaves a dead terminal buffer
        -- in view by default; switch back and clean it up like a real toggle
        vim.api.nvim_create_autocmd('TermClose', {
            buffer = term_buf,
            once = true,
            callback = function()
                local dead_buf = term_buf
                term_buf = nil
                if prev_buf and vim.api.nvim_buf_is_valid(prev_buf) then
                    vim.api.nvim_win_set_buf(0, prev_buf)
                end
                vim.schedule(function()
                    if vim.api.nvim_buf_is_valid(dead_buf) then
                        vim.cmd('bdelete! ' .. dead_buf)
                    end
                end)
            end,
        })
    end
    vim.cmd('startinsert')
end

vim.keymap.set('n', '<leader>t', toggle_terminal, { noremap = true, silent = true, desc = 'Toggle terminal' })

-- Close the current buffer (same as clicking the x on a bufferline tab).
-- Switches to the adjacent buffer first so the window doesn't fall back to
-- an empty scratch buffer, then deletes the buffer we switched away from.
vim.keymap.set('n', '<leader>bd', function()
    local buf = vim.api.nvim_get_current_buf()
    pcall(vim.cmd, 'BufferLineCyclePrev')
    if vim.api.nvim_get_current_buf() ~= buf then
        vim.cmd('bdelete ' .. buf)
    else
        vim.cmd('bdelete')
    end
end, { noremap = true, silent = true, desc = 'Close buffer' })

-- No leader/space-prefixed keybinds should ever fire while typing into a
-- terminal (they'd collide with normal typed text, e.g. words starting with
-- "t" after a space). <C-t> is a control-key combo, so it's safe to use to
-- drop back to normal mode from any terminal (this one, Claude Code's, etc.)
-- without ever conflicting with what's typed.
vim.keymap.set('t', '<C-t>', [[<C-\><C-n>]], { noremap = true, silent = true, desc = 'Exit terminal mode to normal' })

-- Keymap cheatsheet (which-key), pulled live from every registered keymap's desc
vim.keymap.set('n', '<leader>?', '<cmd>WhichKey<CR>', { noremap = true, silent = true, desc = 'Keymap cheatsheet' })

-- Resize with arrows
-- delta: 2 lines
-- vim.g.manually_resizing_window tells config/options.lua's WinResized
-- autocmd to skip its Claude-panel auto-correction while a manual resize is
-- in flight -- otherwise every <C-Left>/<C-Right> press just gets fought and
-- undone by that autocmd snapping Claude back to its 30% target.
-- A held key (OS key-repeat) fires this many times faster than 100ms apart;
-- each press cancels the previous pending timer so the flag only clears
-- 100ms after the LAST press, not the first one in the burst.
local resize_timer = nil
local function manual_resize(cmd)
    return function()
        vim.g.manually_resizing_window = true
        vim.cmd(cmd)
        if resize_timer then
            resize_timer:stop()
            resize_timer:close()
        end
        resize_timer = vim.defer_fn(function()
            vim.g.manually_resizing_window = false
            resize_timer = nil
        end, 100)
    end
end
vim.keymap.set('n', '<C-Up>', manual_resize('resize -2'), opts)
vim.keymap.set('n', '<C-Down>', manual_resize('resize +2'), opts)
vim.keymap.set('n', '<C-Left>', manual_resize('vertical resize -2'), opts)
vim.keymap.set('n', '<C-Right>', manual_resize('vertical resize +2'), opts)

-----------------
-- Visual mode --
-----------------

-- Hint: start visual mode with the same area as the previous area and the same mode
vim.keymap.set('v', '<', '<gv', opts)
vim.keymap.set('v', '>', '>gv', opts)
