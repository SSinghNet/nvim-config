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
local function toggle_terminal()
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
vim.keymap.set('n', '<C-Up>', ':resize -2<CR>', opts)
vim.keymap.set('n', '<C-Down>', ':resize +2<CR>', opts)
vim.keymap.set('n', '<C-Left>', ':vertical resize -2<CR>', opts)
vim.keymap.set('n', '<C-Right>', ':vertical resize +2<CR>', opts)

-----------------
-- Visual mode --
-----------------

-- Hint: start visual mode with the same area as the previous area and the same mode
vim.keymap.set('v', '<', '<gv', opts)
vim.keymap.set('v', '>', '>gv', opts)
