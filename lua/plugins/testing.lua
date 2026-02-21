return {
  {
    "nvim-neotest/neotest",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "antoinemadec/FixCursorHold.nvim",
      "nvim-treesitter/nvim-treesitter",
      "nvim-neotest/neotest-python",
      "nvim-neotest/nvim-nio"
    },
    cmd = { "Neotest", "NeotestFile", "NeotestNearest", "NeotestSuite", "NeotestSummary", "NeotestJump" },
    config = function()
      require("neotest").setup({
        adapters = {
          require("neotest-python")({
            dap = {
              justMyCode = false,
              console = "integratedTerminal"
            },
            -- args = { "--log-level", "DEBUG" },
            args = { "-vv", "-s" },
            runner = "pytest"
          })
        }
      })
    end
  },
}
