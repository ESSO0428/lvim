local dap = require('dap')
dap.adapters.php = {
  type = "executable",
  command = "node",
  args = {
    vim.loop.os_homedir() .. "/.local/share/lvim/mason/packages/php-debug-adapter/extension/out/phpDebug.js",
  },
}
