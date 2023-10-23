local M = {}
-- local Log = require "lvim.core.log"

--- Get current buffer size
---@return {width: number, height: number}
local function get_buf_size()
  local cbuf = vim.api.nvim_get_current_buf()
  local bufinfo = vim.tbl_filter(function(buf)
    return buf.bufnr == cbuf
  end, vim.fn.getwininfo(vim.api.nvim_get_current_win()))[1]
  if bufinfo == nil then
    return { width = -1, height = -1 }
  end
  return { width = bufinfo.width, height = bufinfo.height }
end

--- Get the dynamic terminal size in cells
---@param direction number
---@param size number
---@return integer
local function get_dynamic_terminal_size(direction, size)
  size = size or lvim.builtin.terminal.size
  if direction ~= "float" and tostring(size):find(".", 1, true) then
    size = math.min(size, 1.0)
    local buf_sizes = get_buf_size()
    local buf_size = direction == "horizontal" and buf_sizes.height or buf_sizes.width
    return buf_size * size
  else
    return size
  end
end

function _G.ToggleTermExec(term_mode)
  local execs = lvim.builtin.terminal.execs
  local exec = nil
  local i = nil
  if term_mode == "horizontal" then
    exec = execs[1]
    i = 1
  elseif term_mode == "vertical" then
    exec = execs[2]
    i = 2
  elseif term_mode == "float" then
    exec = execs[3]
    i = 3
  end
  local direction = exec[4] or lvim.builtin.terminal.direction
  local basedir = vim.api.nvim_call_function("getcwd", { 0 })
  local opts = {
    cmd = exec[1] or lvim.builtin.terminal.shell,
    keymap = exec[2],
    label = exec[3],
    -- NOTE: unable to consistently bind id/count <= 9, see #2146
    count = i + 100,
    direction = direction,
    basedir = basedir,
    size = function()
      return get_dynamic_terminal_size(direction, exec[5])
    end,
  }
  M.add_exec(opts)
end

function _G.ToggleTermExecFzfRg(term_mode)
  local execs = lvim.builtin.terminal.execs
  local exec = nil
  local i = nil
  if term_mode == "horizontal" then
    exec = execs[1]
    i = 1
  elseif term_mode == "vertical" then
    exec = execs[2]
    i = 2
  elseif term_mode == "float" then
    exec = execs[3]
    i = 3
  end
  local direction = exec[4] or lvim.builtin.terminal.direction
  local basedir = vim.api.nvim_call_function("getcwd", { 0 })
  local opts = {
    cmd = exec[1] or lvim.builtin.terminal.shell,
    keymap = exec[2],
    label = exec[3],
    -- NOTE: unable to consistently bind id/count <= 9, see #2146
    count = i + 100,
    direction = direction,
    basedir = basedir,
    size = function()
      return get_dynamic_terminal_size(direction, exec[5])
    end,
  }
  M.add_execFzfRg(opts)
end

M.add_exec = function(opts)
  M._exec_toggle(opts)
end

M.add_execFzfRg = function(opts)
  M._exec_toggleFzfRg(opts)
end


M._exec_toggle = function(opts)
  -- vim.cmd("ToggleTerm" ..
  --   " cmd=" ..
  --   opts.cmd ..
  --   " count=" .. opts.count .. " size=" .. opts.size() .. " direction=" .. opts.direction .. " dir=" .. opts.basedir)
  local venv = os.getenv("CONDA_DEFAULT_ENV") or os.getenv("VIRTUAL_ENV")
  opts.cmd = "'conda activate " .. venv .. "'"
  if venv == vim.g.PythonEnv then
    opts.cmd = ""
  end
  vim.cmd("TermExec" ..
    " cmd=" ..
    opts.cmd ..
    " count=" ..
    -- opts.count .. " size=" .. opts.size() .. " direction=" .. opts.direction .. " go_back=0")
    opts.count .. " size=" .. opts.size() .. " direction=" .. opts.direction .. " dir=" .. opts.basedir .. " go_back=0")
end

M._exec_toggleFzfRg = function(opts)
  -- vim.cmd("ToggleTerm" ..
  --   " cmd=" ..
  --   opts.cmd ..
  --   " count=" .. opts.count .. " size=" .. opts.size() .. " direction=" .. opts.direction .. " dir=" .. opts.basedir)
  local venv = os.getenv("CONDA_DEFAULT_ENV") or os.getenv("VIRTUAL_ENV")
  opts.cmd = "'conda activate " .. venv .. "; fzf_rg'"
  if venv == vim.g.PythonEnv then
    opts.cmd = "'fzf_rg'"
  end
  vim.cmd("TermExec" ..
    " cmd=" ..
    opts.cmd ..
    " count=" ..
    -- opts.count .. " size=" .. opts.size() .. " direction=" .. opts.direction .. " go_back=0")
    opts.count .. " size=" .. opts.size() .. " direction=" .. opts.direction .. " dir=" .. opts.basedir .. " go_back=0")
end

return M
