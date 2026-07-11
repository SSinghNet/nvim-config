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

        require("jdtls").start_or_attach({
          cmd = { jdtls_path .. "/bin/jdtls", "-data", workspace_dir },
          root_dir = require("jdtls.setup").find_root({ "pom.xml", "build.gradle", ".git" }),
        })
      end,
    })
  end,
}
