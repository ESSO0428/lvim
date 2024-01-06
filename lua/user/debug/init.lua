local dap = require('dap')
dap.defaults.fallback.switchbuf = 'useopen,uselast'
require "user.debug.python"
require "nvim-dap-virtual-text".setup()
local function reloadLaunchJson()
  local status, err = pcall(function()
    require('dap.ext.vscode').load_launchjs()
  end)
  if not status then
    print("Failed to reload launch.json. Please check for errors in the file.")
  end
end

vim.api.nvim_create_autocmd("BufWritePost", {
  pattern = "*/.vscode/launch.json",
  callback = reloadLaunchJson
})


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
