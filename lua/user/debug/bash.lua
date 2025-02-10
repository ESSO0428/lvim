local dap = require('dap')
dap.adapters.sh = {
  type = 'executable',
  command = vim.fn.stdpath("data") .. '/mason/packages/bash-debug-adapter/bash-debug-adapter',
  name = 'bashdb',
}
dap.configurations.sh = {
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
