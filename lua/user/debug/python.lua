local dap = require('dap')
local LoadLaunchJsonSucess = vim.gLoadLaunchJsonSucess
local launch_config = {}
local attach_config = {}
local example_launch_config = {}
local example_attach_config = {}

require "dap-python".setup("python", {})
example_attach_config = {
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

local function insert_config(lang, config)
  if next(config) then
    dap.configurations[lang] = dap.configurations[lang] or {}
    table.insert(dap.configurations[lang], config)
  end
end

local target_lang = "python"

if LoadLaunchJsonSucess == true then
  require('dap.ext.vscode').load_launchjs()
  insert_config(target_lang, launch_config)
  insert_config(target_lang, attach_config)
else
  insert_config(target_lang, example_launch_config)
  insert_config(target_lang, example_attach_config)
end
