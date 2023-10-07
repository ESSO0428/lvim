local dap = require('dap')
require "dap-python".setup("python", {})
dap.adapters.python = {
  type = "executable",
  command = "python",
  args = { "-m", "debugpy.adapter" },
}
dap.configurations.python = {
  {
    type = 'python',
    request = 'launch',
    name = "Launch PythonScript",
    program = "${file}",
    justMyCode = true,
    console = "internalConsole",
  },
  {
    type = "python",
    request = "attach",
    name = "Attach Remote pydebug",
    cwd = "${workspaceFolder}",
    -- cwd = vim.fn.getcwd(),
    pathMappings = {
      {
        -- localRoot = vim.fn.getcwd(),
        localRoot = '${workspaceFolder}',
        remoteRoot = '/usr/local/apache2/htdocs/mysite/'
      },
    },
    console = "internalConsole",
    host = function()
      local value = vim.fn.input('Host [127.0.0.1]: ')
      if value ~= "" then
        return value
      end
      return '127.0.0.1'
    end,
    port = function()
      local val = vim.fn.input('Port: ')
      if val ~= "" then
        return val
      end
      return 5678
    end,
  },
  {
    type = 'python',
    request = 'launch',
    name = "Launch django project",
    -- program = "${file}";
    program = "${workspaceFolder}/manage.py",
    args = {
      "runserver",
      "--noreload",
      -- "--insecure",
      "127.0.0.1:80"
    },
    console = "internalConsole",
    django = true
    -- port = 5678,
  },
}
