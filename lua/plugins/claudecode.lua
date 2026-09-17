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
    { "<leader>ac", safe_cmd("ClaudeCode"), desc = "Toggle Claude" },
    { "<leader>af", safe_cmd("ClaudeCodeFocus"), desc = "Focus Claude" },
    { "<leader>ar", safe_cmd("ClaudeCode --resume"), desc = "Resume Claude" },
    { "<leader>aC", safe_cmd("ClaudeCode --continue"), desc = "Continue Claude" },
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
