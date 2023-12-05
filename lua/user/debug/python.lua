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
  console = "internalConsole",
  connect = function()
    local host = vim.fn.input('Host [127.0.0.1]: ')
    host = host ~= '' and host or '127.0.0.1'
    local port = tonumber(vim.fn.input('Port [5678]: ')) or 5678
    return { host = host, port = port }
  end,
}
-- NOTE: 嘗試加載 vim.fn.getcwd()/.vscode/launch.json
local status, err = pcall(function()
  require('dap.ext.vscode').load_launchjs()
end)
-- NOTE: 失敗則改用原始的配置
if not status then
  print("Failed to load launch.json. Please check for trailing commas or if the file exists.")
  table.insert(dap.configurations.python, attach_config)
end
