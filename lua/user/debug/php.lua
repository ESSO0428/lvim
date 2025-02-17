local dap = require('dap')
local LoadLaunchJsonSucess = vim.g.LoadLaunchJsonSucess
local launch_configs = {}
local attach_configs = {}
local example_launch_configs = {}
local example_attach_configs = {}

dap.adapters.php = {
  type = "executable",
  command = "node",
  args = {
    vim.fn.stdpath('data') .. "/mason/packages/php-debug-adapter/extension/out/phpDebug.js",
  },
}
dap.configurations.php = {}
launch_configs = {
  {
    name = "Listen for Xdebug (custom connect)",
    type = "php",
    request = "launch",
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
}
example_launch_configs = {
  {
    name = "Listen for Xdebug (example)",
    type = "php",
    request = "launch",
    pathMappings = {
      ["/var/www/html/"] = "${workspaceFolder}"
    },
    port = 9003,
  }
}

local target_lang = "php"

if LoadLaunchJsonSucess == true then
  require('dap.ext.vscode').load_launchjs()
else
  Nvim.DAP.insert_dap_configs(target_lang, example_launch_configs)
  Nvim.DAP.insert_dap_configs(target_lang, example_attach_configs)
end
Nvim.DAP.insert_dap_configs(target_lang, launch_configs)
Nvim.DAP.insert_dap_configs(target_lang, attach_configs)
