-- claudecode.nvim's panel is a fixed-percentage split (snacks.win); in a very
-- narrow terminal (e.g. alongside nvim-tree at ~60 columns) there's genuinely
-- not enough room and snacks.win raises a raw E36 "Not enough room" error.
-- Can't manufacture room that doesn't exist, but surface it as a clean
-- notification instead of a crash-looking traceback.
local function safe_cmd(cmd)
  return function()
    -- lazy.nvim's own cmd-loader placeholder defers the real dispatch to a
    -- later tick (outside this function's stack), which would let the error
    -- below escape an unforced pcall on the plugin's first invocation. Force
    -- the load synchronously first so vim.cmd below calls the real command.
    pcall(function()
      require("lazy").load({ plugins = { "claudecode.nvim" } })
    end)
    local ok, err = pcall(vim.cmd, cmd)
    if not ok then
      vim.notify("Claude Code: " .. tostring(err), vim.log.levels.WARN, { title = "claudecode.nvim" })
    end
  end
end

-- Claude's panel belongs to the editor tab. Its toggle can't tell a panel
-- shown in another tab from one shown here, so from a Diffview / terminal tab
-- a plain toggle would close the editor tab's panel instead of reaching it.
-- From those tabs, switch to the editor tab first; `from_workspace` (default:
-- `cmd`) is what to run when a switch happened.
local function in_editor_tab(cmd, from_workspace)
  local run = safe_cmd(cmd)
  local run_after_switch = from_workspace and safe_cmd(from_workspace) or run
  return function()
    if require("config.tabs").to_editor_tab() then
      run_after_switch()
    else
      run()
    end
  end
end

return {
  "coder/claudecode.nvim",
  dependencies = { "folke/snacks.nvim" },
  config = true,
  cmd = {
    "ClaudeCode",
    "ClaudeCodeFocus",
    "ClaudeCodeSelectModel",
    "ClaudeCodeAdd",
    "ClaudeCodeSend",
    "ClaudeCodeTreeAdd",
    "ClaudeCodeStatus",
    "ClaudeCodeStart",
    "ClaudeCodeStop",
    "ClaudeCodeOpen",
    "ClaudeCodeClose",
    "ClaudeCodeDiffAccept",
    "ClaudeCodeDiffDeny",
    "ClaudeCodeCloseAllDiffs",
  },
  keys = {
    -- group label for <leader>a lives in plugins/which-key.lua
    { "<leader>ac", in_editor_tab("ClaudeCode", "ClaudeCodeFocus"), desc = "Toggle Claude" },
    { "<leader>af", in_editor_tab("ClaudeCodeFocus"), desc = "Focus Claude" },
    { "<leader>ar", in_editor_tab("ClaudeCode --resume"), desc = "Resume Claude" },
    { "<leader>aC", in_editor_tab("ClaudeCode --continue"), desc = "Continue Claude" },
    { "<leader>am", safe_cmd("ClaudeCodeSelectModel"), desc = "Select Claude model" },
    { "<leader>ab", safe_cmd("ClaudeCodeAdd %"), desc = "Add current buffer" },
    { "<leader>as", safe_cmd("ClaudeCodeSend"), mode = "v", desc = "Send to Claude" },
    {
      "<leader>as",
      safe_cmd("ClaudeCodeTreeAdd"),
      desc = "Add file",
      ft = { "NvimTree" }, -- the only tree/explorer plugin actually installed in this config
    },
    -- Diff management
    { "<leader>aa", safe_cmd("ClaudeCodeDiffAccept"), desc = "Accept diff" },
    { "<leader>ad", safe_cmd("ClaudeCodeDiffDeny"), desc = "Deny diff" },
  },
}
