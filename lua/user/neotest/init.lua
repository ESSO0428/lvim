require("neotest").setup({
  adapters = {
    require("neotest-python")({
      dap = {
        justMyCode = false,
        console = "integratedTerminal"
      },
      args = { "--log-level", "DEBUG" },
      runner = "pytest"
    })
  }
})
