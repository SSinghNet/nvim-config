return {
  "mfussenegger/nvim-jdtls",
  ft = "java",
  config = function()
    vim.api.nvim_create_autocmd("FileType", {
      pattern = "java",
      callback = function()
        local mason_registry = require("mason-registry")
        local jdtls_path = mason_registry.get_package("jdtls"):get_install_path()
        local project_name = vim.fn.fnamemodify(vim.fn.getcwd(), ":p:h:t")
        local workspace_dir = vim.fn.stdpath("data") .. "/jdtls-workspace/" .. project_name

        -- nvim-jdtls auto-registers a "java" dap adapter once these bundles are present
        -- (see plugins/dap.lua); no separate dap.adapters.java config needed.
        -- has_package() only means the name is a known registry entry, not that
        -- mason-tool-installer (plugins/mason.lua) has finished installing it yet --
        -- check is_installed() too, or a glob against a nonexistent path yields "",
        -- which vim.split turns into a bogus {""} bundle entry.
        local bundles = {}
        local debug_pkg = mason_registry.has_package("java-debug-adapter")
          and mason_registry.get_package("java-debug-adapter")
        if debug_pkg and debug_pkg:is_installed() then
          local debug_path = debug_pkg:get_install_path()
          vim.list_extend(
            bundles,
            vim.split(vim.fn.glob(debug_path .. "/extension/server/com.microsoft.java.debug.plugin-*.jar"), "\n", { trimempty = true })
          )
        end
        local test_pkg = mason_registry.has_package("java-test") and mason_registry.get_package("java-test")
        if test_pkg and test_pkg:is_installed() then
          local test_path = test_pkg:get_install_path()
          local jars = vim.split(vim.fn.glob(test_path .. "/extension/server/*.jar"), "\n", { trimempty = true })
          for _, jar in ipairs(jars) do
            if vim.fn.fnamemodify(jar, ":t") ~= "com.microsoft.java.test.runner-jar-with-dependencies.jar" then
              table.insert(bundles, jar)
            end
          end
        end

        require("jdtls").start_or_attach({
          cmd = { jdtls_path .. "/bin/jdtls", "-data", workspace_dir },
          root_dir = require("jdtls.setup").find_root({ "pom.xml", "build.gradle", ".git" }),
          init_options = { bundles = bundles },
        })
      end,
    })
  end,
}
