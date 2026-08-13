return {
  "mfussenegger/nvim-dap",
  dependencies = {
    "rcarriga/nvim-dap-ui",
    "nvim-neotest/nvim-nio",
    "jay-babu/mason-nvim-dap.nvim",
    "theHamsta/nvim-dap-virtual-text",
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
    require("nvim-dap-virtual-text").setup()

    dap.listeners.after.event_initialized["dapui_config"] = function() dapui.open() end
    dap.listeners.before.event_terminated["dapui_config"] = function() dapui.close() end
    dap.listeners.before.event_exited["dapui_config"] = function() dapui.close() end

    -- delve (go), debugpy (python), codelldb (rust/c/cpp -- rustaceanvim auto-detects
    -- this mason install for its own dap config), php-debug-adapter (Xdebug, listens
    -- on port 9003 by default -- relevant now that wordpress.nvim is in the mix),
    -- kotlin-debug-adapter (mason-nvim-dap's source mapping resolves "kotlin" to this
    -- package and auto-registers dap.adapters.kotlin -- see dap.configurations.kotlin
    -- below, which mason-nvim-dap does NOT provide on its own).
    -- Java is wired separately in plugins/jdtls.lua: jdtls registers its own "java"
    -- dap adapter and mason-nvim-dap doesn't cover it.
    require("mason-nvim-dap").setup({
      ensure_installed = { "delve", "python", "codelldb", "php", "kotlin" },
      automatic_installation = true,
    })

    -- best-effort mainClass guess: strip src/main/kotlin/, turn the path into a
    -- dotted package, and append "Kt" (Kotlin's default facade-class naming for
    -- top-level functions in a file). Adjust per-project if this doesn't match.
    dap.configurations.kotlin = {
      {
        type = "kotlin",
        request = "launch",
        name = "Launch file",
        mainClass = function()
          local path = vim.api.nvim_buf_get_name(0)
          local class = path
            :gsub(".*/src/main/kotlin/", "")
            :gsub(".*/src/test/kotlin/", "")
            :gsub("%.kt$", "Kt")
            :gsub("/", ".")
          return class
        end,
        projectRoot = "${workspaceFolder}",
      },
    }
  end,
}
