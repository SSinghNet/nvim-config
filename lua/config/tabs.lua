-- Helpers for telling apart the "editor" tab (nvim-tree, files, Claude's
-- panel) from workspace tabs that own the whole screen: a Diffview tab or
-- the <leader>y terminal tab (marked t:term_tab, see config/keymaps.lua).
-- Things that open files or belong to the editor layout should run there,
-- not clobber a diff pane or the terminal.
local M = {}

local function is_diff_tab(tab)
    -- Diffview may not be loaded yet (lazy); if it isn't, no view can exist
    local lib = package.loaded["diffview.lib"]
    return lib ~= nil and lib.tabpage_to_view(tab) ~= nil
end

local function is_term_tab(tab)
    return pcall(vim.api.nvim_tabpage_get_var, tab, "term_tab")
end

function M.in_diff_tab()
    return is_diff_tab(vim.api.nvim_get_current_tabpage())
end

-- Most recently used tab that isn't a workspace tab, else the first one.
function M.editor_tab()
    local tabs = vim.api.nvim_list_tabpages()
    local function ok(tab)
        return not is_diff_tab(tab) and not is_term_tab(tab)
    end
    local prev = tabs[vim.fn.tabpagenr("#")]
    if prev and ok(prev) then
        return prev
    end
    for _, tab in ipairs(tabs) do
        if ok(tab) then
            return tab
        end
    end
    return nil
end

-- From a workspace tab, switch to the editor tab. Returns true if it
-- switched; false if already in the editor tab (or no editor tab exists), in
-- which case callers just carry on where they are.
function M.to_editor_tab()
    local cur = vim.api.nvim_get_current_tabpage()
    if not (is_diff_tab(cur) or is_term_tab(cur)) then
        return false
    end
    local target = M.editor_tab()
    if not target then
        return false
    end
    vim.api.nvim_set_current_tabpage(target)
    return true
end

return M
