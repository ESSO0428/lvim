local dap = require('dap')
require "dap-python".setup("python", {})
local attach_config = {
  type = "python",
  request = "attach",
  name = "Attach remote (django [example])",
  cwd = "${workspaceFolder}",
  mode = "remote",
  pathMappings = {
    {
      localRoot = '${workspaceFolder}',
      remoteRoot = '/usr/local/apache2/htdocs/mysite/'
    },
  },
  django = true,
  console = "internalConsole",
  connect = function()
    local host = vim.fn.input('Host [127.0.0.1]: ')
    host = host ~= '' and host or '127.0.0.1'
    local port = tonumber(vim.fn.input('Port [5678]: ')) or 5678
    return { host = host, port = port }
  end,
}
-- 檢查 launch.json 文件是否存在
local launch_json_path = vim.fn.getcwd() .. '/.vscode/launch.json'
if vim.fn.filereadable(launch_json_path) == 0 then
  print("launch.json does not exist. Using default debug configuration.")
  table.insert(dap.configurations.python, attach_config)
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
    table.insert(dap.configurations.python, attach_config)
  end
end
