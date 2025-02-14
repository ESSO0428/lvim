local dap = require('dap')
local LoadLaunchJsonSucess = vim.g.LoadLaunchJsonSucess
local launch_configs = {}
local attach_configs = {}
local example_launch_configs = {}
local example_attach_configs = {}

dap.adapters.sh = {
  type = 'executable',
  command = vim.fn.stdpath("data") .. '/mason/packages/bash-debug-adapter/bash-debug-adapter',
  name = 'bashdb',
}
dap.configurations.sh = {}
launch_configs = {
  {
    type = 'sh',
    request = 'launch',
    name = 'Launch Bash debugger',
    showDebugOutput = true,
    -- trace = true,
    pathBashdb = vim.fn.stdpath("data") .. '/mason/packages/bash-debug-adapter/extension/bashdb_dir/bashdb',
    pathBashdbLib = vim.fn.stdpath("data") .. '/mason/packages/bash-debug-adapter/extension/bashdb_dir',
    program = '${file}',
    cwd = '${fileDirname}',
    pathCat = "cat",
    pathBash = "bash",
    pathMkfifo = "mkfifo",
    pathPkill = "pkill",
    args = {},
    env = {},
  }
}

local target_lang = "sh"

if LoadLaunchJsonSucess == true then
  require('dap.ext.vscode').load_launchjs()
else
  Nvim.DAP.insert_dap_configs(target_lang, example_launch_configs)
  Nvim.DAP.insert_dap_configs(target_lang, example_attach_configs)
end
Nvim.DAP.insert_dap_configs(target_lang, launch_configs)
Nvim.DAP.insert_dap_configs(target_lang, attach_configs)
