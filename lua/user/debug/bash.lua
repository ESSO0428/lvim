local dap = require('dap')
local LoadLaunchJsonSucess = vim.gLoadLaunchJsonSucess
local launch_config = {}
local attach_config = {}
local example_launch_config = {}
local example_attach_config = {}

dap.adapters.sh = {
  type = 'executable',
  command = vim.fn.stdpath("data") .. '/mason/packages/bash-debug-adapter/bash-debug-adapter',
  name = 'bashdb',
}
dap.configurations.sh = {}
launch_config = {
  {
    type = 'sh',
    request = 'launch',
    name = 'Launch Bash debugger',
    -- showDebugOutput = true,
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

local function insert_config(lang, config)
  if next(config) then
    dap.configurations[lang] = dap.configurations[lang] or {}
    table.insert(dap.configurations[lang], config)
  end
end

local target_lang = "sh"

if LoadLaunchJsonSucess == true then
  require('dap.ext.vscode').load_launchjs()
  insert_config(target_lang, launch_config)
  insert_config(target_lang, attach_config)
else
  insert_config(target_lang, example_launch_config)
  insert_config(target_lang, example_attach_config)
end
