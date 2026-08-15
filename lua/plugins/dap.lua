return {
  "mfussenegger/nvim-dap",
  dependencies = {
    "rcarriga/nvim-dap-ui",
    "nvim-neotest/nvim-nio",
    "jay-babu/mason-nvim-dap.nvim",
    "theHamsta/nvim-dap-virtual-text",
    "mxsdev/nvim-dap-vscode-js", -- Node/Next.js/browser JS debugging (pwa-node/pwa-chrome adapters)
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

    -- Node/Next.js/browser debugging: js-debug-adapter is installed via
    -- mason-tool-installer (plugins/mason.lua) rather than mason-nvim-dap, since
    -- mason-nvim-dap has no built-in source mapping for it (same reasoning as
    -- Java's jdtls, wired separately in plugins/jdtls.lua).
    -- debugger_cmd takes precedence over debugger_path/node_path and just runs the
    -- Mason-generated "js-debug-adapter" shim on $PATH -- nvim-dap-vscode-js's own
    -- default entrypoint resolution (debugger_path .. "/out/src/vsDebugServer.js")
    -- assumes a from-source vscode-js-debug build and does NOT match Mason's package
    -- layout, so debugger_path alone would fail to find the entrypoint.
    require("dap-vscode-js").setup({
      node_path = "node",
      debugger_path = vim.fn.stdpath("data") .. "/mason/packages/js-debug-adapter",
      debugger_cmd = { "js-debug-adapter" },
      adapters = { "pwa-node", "pwa-chrome", "node-terminal" },
    })

    for _, language in ipairs({ "javascript", "typescript", "javascriptreact", "typescriptreact" }) do
      dap.configurations[language] = {
        {
          type = "pwa-node",
          request = "launch",
          name = "Launch file",
          program = "${file}",
          cwd = "${workspaceFolder}",
        },
        {
          type = "pwa-node",
          request = "attach",
          name = "Attach to process",
          processId = require("dap.utils").pick_process,
          cwd = "${workspaceFolder}",
        },
        {
          -- for `next dev`/any dev server: run it externally with
          -- `node --inspect node_modules/.bin/next dev` (or NODE_OPTIONS=--inspect),
          -- then attach here
          type = "pwa-node",
          request = "attach",
          name = "Attach to Next.js (port 9229)",
          port = 9229,
          restart = true,
          cwd = "${workspaceFolder}",
          skipFiles = { "<node_internals>/**", "**/node_modules/**" },
        },
      }
    end

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
