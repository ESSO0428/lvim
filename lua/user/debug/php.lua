local dap = require('dap')
local LoadLaunchJsonSucess = vim.g.LoadLaunchJsonSucess
local launch_config = {}
local attach_config = {}
local example_launch_config = {}
local example_attach_config = {}

dap.adapters.php = {
  type = "executable",
  command = "node",
  args = {
    vim.fn.stdpath('data') .. "/mason/packages/php-debug-adapter/extension/out/phpDebug.js",
  },
}
dap.configurations.php = {}
launch_config = {
  type = "php",
  request = "launch",
  name = "Listen for Xdebug (custom connect)",
  pathMappings = function()
    local remote_path = vim.fn.input('Remote path [/var/www/html/]: ', "/var/www/html/", "file")
    local local_path = vim.fn.input('Local path [${workspaceFolder}]: ', "${workspaceFolder}", "file")
    return { [remote_path] = local_path }
  end,
  connect = function()
    local host = vim.fn.input('Host [127.0.0.1]: ')
    host = host ~= '' and host or '127.0.0.1'
    local port = tonumber(vim.fn.input('Port [9003]: ')) or 9003
    return { host = host, port = port }
  end,
}
example_launch_config = {
  type = "php",
  request = "launch",
  name = "Listen for Xdebug (example)",
  pathMappings = {
    ["/var/www/html/"] = "${workspaceFolder}"
  },
  port = 9003,
}

local function insert_config(lang, config)
  if next(config) then
    dap.configurations[lang] = dap.configurations[lang] or {}
    table.insert(dap.configurations[lang], config)
  end
end

local target_lang = "php"

if LoadLaunchJsonSucess == true then
  require('dap.ext.vscode').load_launchjs()
  insert_config(target_lang, launch_config)
  insert_config(target_lang, attach_config)
else
  insert_config(target_lang, example_launch_config)
  insert_config(target_lang, example_attach_config)
end
