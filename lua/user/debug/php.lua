local dap = require('dap')
dap.adapters.php = {
  type = "executable",
  command = "node",
  args = {
    vim.fn.stdpath('data') .. "/mason/packages/php-debug-adapter/extension/out/phpDebug.js",
  },
}
