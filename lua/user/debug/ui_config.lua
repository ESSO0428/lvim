require("lvim.core.dap").setup_ui = function()
  local status_ok, dap = pcall(require, "dap")
  if not status_ok then
    return
  end
  local dapui = require "dapui"
  dapui.setup(lvim.builtin.dap.ui.config)

  -- if lvim.builtin.dap.ui.auto_open then
  dap.listeners.after.event_initialized["dapui_config"] = function()
    -- NOTE: Dynamic adjustment of whether to open the DAP UI
    if lvim.builtin.dap.ui.auto_open then
      dapui.open()
    end
  end
  -- dap.listeners.before.event_terminated["dapui_config"] = function()
  --   dapui.close()
  -- end
  -- dap.listeners.before.event_exited["dapui_config"] = function()
  --   dapui.close()
  -- end
  -- end

  local Log = require "lvim.core.log"

  -- until rcarriga/nvim-dap-ui#164 is fixed
  local function notify_handler(msg, level, opts)
    if level >= lvim.builtin.dap.ui.notify.threshold then
      return vim.notify(msg, level, opts)
    end

    opts = vim.tbl_extend("keep", opts or {}, {
      title = "dap-ui",
      icon = "",
      on_open = function(win)
        vim.api.nvim_set_option_value("filetype", "markdown", { buf = vim.api.nvim_win_get_buf(win) })
      end,
    })

    -- vim_log_level can be omitted
    if level == nil then
      level = Log.levels["INFO"]
    elseif type(level) == "string" then
      level = Log.levels[(level):upper()] or Log.levels["INFO"]
    else
      -- https://github.com/neovim/neovim/blob/685cf398130c61c158401b992a1893c2405cd7d2/runtime/lua/vim/lsp/log.lua#L5
      level = level + 1
    end

    msg = string.format("%s: %s", opts.title, msg)
    Log:add_entry(level, msg)
  end

  local dapui_ok, _ = xpcall(function()
    require("dapui.util").notify = notify_handler
  end, debug.traceback)
  if not dapui_ok then
    Log:debug "Unable to override dap-ui logging level"
  end
end
