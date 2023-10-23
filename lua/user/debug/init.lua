require "user.debug.python"
require "nvim-dap-virtual-text".setup()


lvim.builtin.dap.ui.config.layouts = {
  {
    elements = {
      { id = "scopes",      size = 0.33 },
      { id = "breakpoints", size = 0.17 },
      { id = "stacks",      size = 0.25 },
      { id = "watches",     size = 0.25 },
    },
    size = 0.25,
    position = "left",
  },
  {
    elements = {
      { id = "repl",    size = 0.45 },
      { id = "console", size = 0.55 },
    },
    size = 0.27,
    position = "bottom",
  },
}
