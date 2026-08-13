return {
  "mfussenegger/nvim-jdtls",
  ft = "java",
  dependencies = { "JavaHello/spring-boot.nvim" },
  config = function()
    vim.api.nvim_create_autocmd("FileType", {
      pattern = "java",
      callback = function()
        local mason_registry = require("mason-registry")
        local jdtls_pkg = mason_registry.get_package("jdtls")
        local jdtls_path = jdtls_pkg:get_install_path()
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

        -- spring-boot.nvim ships its jdtls extension jars (bean navigation, endpoint
        -- discovery, code actions) via the vscode-spring-boot-tools mason package;
        -- force-load it here since it's ft-triggered independently and may not have
        -- loaded yet on the same FileType event that starts jdtls.
        require("lazy").load({ plugins = { "spring-boot.nvim" } })
        local ok_spring, spring_boot = pcall(require, "spring_boot")
        if ok_spring then
          vim.list_extend(bundles, spring_boot.java_extensions())
        end

        -- lombok.jar ships alongside jdtls in its mason package; without the
        -- javaagent, @Data/@Builder/etc-generated members show up as unresolved.
        local cmd = { jdtls_path .. "/bin/jdtls", "-data", workspace_dir }
        local lombok_jar = jdtls_path .. "/lombok.jar"
        if vim.fn.filereadable(lombok_jar) == 1 then
          table.insert(cmd, "--jvm-arg=-javaagent:" .. lombok_jar)
        end

        require("jdtls").start_or_attach({
          cmd = cmd,
          root_dir = require("jdtls.setup").find_root({
            "settings.gradle",
            "settings.gradle.kts",
            "build.gradle",
            "build.gradle.kts",
            "pom.xml",
            ".git",
          }),
          init_options = { bundles = bundles },
        })

        local map_opts = { buffer = true, silent = true }
        vim.keymap.set("n", "<leader>co", require("jdtls").organize_imports, vim.tbl_extend("force", map_opts, { desc = "Organize imports" }))
        vim.keymap.set({ "n", "v" }, "<leader>rv", require("jdtls").extract_variable, vim.tbl_extend("force", map_opts, { desc = "Extract variable" }))
        vim.keymap.set({ "n", "v" }, "<leader>rc", require("jdtls").extract_constant, vim.tbl_extend("force", map_opts, { desc = "Extract constant" }))
        vim.keymap.set("v", "<leader>rm", require("jdtls").extract_method, vim.tbl_extend("force", map_opts, { desc = "Extract method" }))
        vim.keymap.set("n", "<leader>uc", require("jdtls").update_project_config, vim.tbl_extend("force", map_opts, { desc = "Update project config" }))
        -- overrides the generic neotest <leader>nt/<leader>nf (plugins/neotest.lua) for
        -- java buffers only, since Java/Kotlin tests run through jdtls, not neotest
        vim.keymap.set("n", "<leader>nt", require("jdtls").test_nearest_method, vim.tbl_extend("force", map_opts, { desc = "Test nearest method" }))
        vim.keymap.set("n", "<leader>nf", require("jdtls").test_class, vim.tbl_extend("force", map_opts, { desc = "Test class" }))
      end,
    })
  end,
}
