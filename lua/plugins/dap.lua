return {
  "mfussenegger/nvim-dap",
  dependencies = {
    "rcarriga/nvim-dap-ui",
    "nvim-neotest/nvim-nio",
    "jay-babu/mason-nvim-dap.nvim",
  },
  keys = {
    { "<leader>db", function() require("dap").toggle_breakpoint() end, desc = "Toggle breakpoint" },
    { "<leader>dc", function() require("dap").continue() end, desc = "Continue / start debugging" },
    { "<leader>di", function() require("dap").step_into() end, desc = "Step into" },
    { "<leader>do", function() require("dap").step_over() end, desc = "Step over" },
    { "<leader>dO", function() require("dap").step_out() end, desc = "Step out" },
    { "<leader>dr", function() require("dap").repl.toggle() end, desc = "Toggle REPL" },
    { "<leader>dt", function() require("dap").terminate() end, desc = "Terminate" },
    { "<leader>du", function() require("dapui").toggle() end, desc = "Toggle DAP UI" },
  },
  config = function()
    local dap, dapui = require("dap"), require("dapui")
    dapui.setup()

    dap.listeners.after.event_initialized["dapui_config"] = function() dapui.open() end
    dap.listeners.before.event_terminated["dapui_config"] = function() dapui.close() end
    dap.listeners.before.event_exited["dapui_config"] = function() dapui.close() end

    -- delve (go), debugpy (python), codelldb (rust/c/cpp -- rustaceanvim auto-detects
    -- this mason install for its own dap config), php-debug-adapter (Xdebug, listens
    -- on port 9003 by default -- relevant now that wordpress.nvim is in the mix).
    -- Java is wired separately in plugins/jdtls.lua: jdtls registers its own "java"
    -- dap adapter and mason-nvim-dap doesn't cover it.
    require("mason-nvim-dap").setup({
      ensure_installed = { "delve", "python", "codelldb", "php" },
      automatic_installation = true,
    })
  end,
}
