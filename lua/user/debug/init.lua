local dap = require('dap')
vim.g.LoadLaunchJsonSucess = true

require('dap.ext.vscode').json_decode = require('json5').parse
dap.defaults.fallback.switchbuf = 'useopen,uselast'

-- NOTE: 由於 Weissle/persistent-breakpoints.nvim 不包含 set_breakpoint 因此自行新增了如下函數
-- 或者改用我的 Fork 版本 (ESSO0428/persistent-breakpoints.nvim) 即可不定義以下函數
require('persistent-breakpoints.api').set_breakpoint = function(condition, logMessage, hitCondition)
  require('dap').set_breakpoint(condition, logMessage, hitCondition);
  require('persistent-breakpoints.api').breakpoints_changed_in_current_buffer()
end

-- 檢查 launch.json 文件是否存在
local launch_json_path = vim.fn.getcwd() .. '/.vscode/launch.json'
if vim.fn.filereadable(launch_json_path) == 0 then
  print("launch.json does not exist. Using default debug configuration.")
  vim.g.LoadLaunchJsonSucess = false
else
  -- 嘗試加載 launch.json
  local status, err = pcall(function()
    require('dap.ext.vscode').load_launchjs()
  end)
  -- 如果加載失敗，則使用備用配置
  if not status then
    print(
      table.concat(
        {
          "Failed to load launch.json. Please check for trailing commas or if the file exists.",
          "Will use default debug configuration."
        }, " "
      )
    )
    vim.g.LoadLaunchJsonSucess = false
  else
    vim.g.LoadLaunchJsonSucess = true
  end
end

-- NOTE: 根據 `lvim.builtin.dap.ui.auto_open` 的值設定是否自動開啟 DAP UI
-- 並且可以動態調整 true/false 不須關閉 neovim
-- 實踐方式為覆蓋 lunarvim 的 setup_ui 函數
require "user.debug.ui_config"

-- NOTE: toggle `lvim.builtin.dap.ui.auto_open`
lvim.builtin.which_key.mappings.d.L = {
  function() lvim.builtin.dap.ui.auto_open = not lvim.builtin.dap.ui.auto_open end,
  "Toggle UI Auto-Open"
}

-- NOTE: 顯示 DAP UI 的快捷鍵
require "user.debug.ui_helper"

lvim.builtin.which_key.mappings.s.b = { "<cmd>lua require'telescope'.extensions.dap.list_breakpoints()<cr>",
  "List breakpoints" }
lvim.builtin.which_key.mappings.s.B = { "<cmd>Telescope git_branches<cr>", "Checkout branch" }
lvim.builtin.which_key.mappings.d[';'] = { "<cmd>lua require'telescope'.extensions.dap.commands()<cr>", "Command" }
lvim.builtin.which_key.mappings.d['`'] = { "<cmd>lua require'dap'.restart()<cr>", "Restart" }


require "user.debug.bash"
require "user.debug.python"
require "user.debug.php"
require "user.debug.javascript"

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
