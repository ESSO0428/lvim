local dap = require('dap')
dap.defaults.fallback.switchbuf = 'useopen,uselast'

-- NOTE: 由於 Weissle/persistent-breakpoints.nvim 不包含 set_breakpoint 因此自行新增了如下函數
-- 或者改用我的 Fork 版本 (ESSO0428/persistent-breakpoints.nvim) 即可不定義以下函數
require('persistent-breakpoints.api').set_breakpoint = function(condition, logMessage, hitCondition)
  require('dap').set_breakpoint(condition, logMessage, hitCondition);
  require('persistent-breakpoints.api').breakpoints_changed_in_current_buffer()
end


lvim.builtin.which_key.mappings.s.b = { "<cmd>lua require'telescope'.extensions.dap.list_breakpoints()<cr>",
  "List breakpoints" }
lvim.builtin.which_key.mappings.s.B = { "<cmd>Telescope git_branches<cr>", "Checkout branch" }
lvim.builtin.which_key.mappings.d[';'] = { "<cmd>lua require'telescope'.extensions.dap.commands()<cr>", "Command" }
lvim.builtin.which_key.mappings.d['`'] = { "<cmd>lua require'dap'.restart()<cr>", "Restart" }


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
