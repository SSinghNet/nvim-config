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

-- Toggle a terminal split (reuses the same terminal buffer across toggles)
local term_buf = nil
local term_win = nil
local function toggle_terminal()
    if term_win and vim.api.nvim_win_is_valid(term_win) then
        vim.api.nvim_win_hide(term_win)
        term_win = nil
        return
    end

    if term_buf and vim.api.nvim_buf_is_valid(term_buf) then
        vim.cmd('botright split')
        vim.api.nvim_win_set_buf(0, term_buf)
    else
        vim.cmd('botright split | terminal')
        term_buf = vim.api.nvim_get_current_buf()
    end

    term_win = vim.api.nvim_get_current_win()
    vim.cmd('resize 15')
    vim.cmd('startinsert')
end

vim.keymap.set('n', '<leader>t', toggle_terminal, { noremap = true, silent = true, desc = 'Toggle terminal' })
vim.keymap.set('t', '<leader>t', function()
    vim.cmd('stopinsert')
    toggle_terminal()
end, { noremap = true, silent = true, desc = 'Toggle terminal' })

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
