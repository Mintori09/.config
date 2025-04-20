return {
  {
    "mfussenegger/nvim-dap",
    config = function()
      local dap = require("dap")

      dap.adapters.lldb = {
        type = "executable",
        command = "/usr/bin/lldb-vscode",
        name = "lldb",
      }

      dap.configurations.rust = {
        {
          name = "Launch",
          type = "lldb",
          request = "launch",
          program = function()
            return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/", "file")
          end,
          cwd = "${workspaceFolder}",
          stopOnEntry = false,
        },
      }
    end,
  },
  { "rcarriga/nvim-dap-ui" }, -- UI for DAP
  { "nvim-telescope/telescope-dap.nvim" }, -- Integration with Telescope
  { "theHamsta/nvim-dap-virtual-text" }, -- Show variable values inline},
}
