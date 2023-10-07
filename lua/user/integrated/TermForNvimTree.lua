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
    -- local buf_size = direction == "horizontal" and buf_sizes.height or buf_sizes.width
    local buf_size = direction == "horizontal" and buf_sizes.height or buf_sizes.width * 4
    return buf_size * size
  else
    return size
  end
end

function _G.nvimtreeToggleTerm(term_mode, state)
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
  local abspath
  local is_folder
  local success, node = pcall(function()
    return state.tree:get_node()
  end)
  if success then
    abspath = node.link_to or node.path
    is_folder = node.type == "directory"
  else
    node = require("nvim-tree.lib").get_node_at_cursor()
    abspath = node.link_to or node.absolute_path
    is_folder = node.open ~= nil
  end
  -- local node = require("nvim-tree.lib").get_node_at_cursor()
  -- local abspath = node.link_to or node.absolute_path
  -- local is_folder = node.open ~= nil
  local basedir = is_folder and abspath or vim.fn.fnamemodify(abspath, ":h")
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

function _G.nvimtreeToggleTermFzfRg(term_mode, state)
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
  local abspath
  local is_folder
  local success, node = pcall(function()
    return state.tree:get_node()
  end)
  if success then
    abspath = node.link_to or node.path
    is_folder = node.type == "directory"
  else
    node = require("nvim-tree.lib").get_node_at_cursor()
    abspath = node.link_to or node.absolute_path
    is_folder = node.open ~= nil
  end
  -- local node = require("nvim-tree.lib").get_node_at_cursor()
  -- local abspath = node.link_to or node.absolute_path
  -- local is_folder = node.open ~= nil
  local basedir = is_folder and abspath or vim.fn.fnamemodify(abspath, ":h")
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

function _G.nvimtreeToggleTermRanger(term_mode, state)
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
  local abspath
  local is_folder
  local success, node = pcall(function()
    return state.tree:get_node()
  end)
  if success then
    abspath = node.link_to or node.path
    is_folder = node.type == "directory"
  else
    node = require("nvim-tree.lib").get_node_at_cursor()
    abspath = node.link_to or node.absolute_path
    is_folder = node.open ~= nil
  end
  -- local node = require("nvim-tree.lib").get_node_at_cursor()
  -- local abspath = node.link_to or node.absolute_path
  -- local is_folder = node.open ~= nil
  local basedir = is_folder and abspath or vim.fn.fnamemodify(abspath, ":h")
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
  M.add_execRanger(opts)
end

function _G.nvimtreeCder(term_mode, state)
  local abspath
  local is_folder
  local success, node = pcall(function()
    return state.tree:get_node()
  end)
  if success then
    abspath = node.link_to or node.path
    is_folder = node.type == "directory"
  else
    node = require("nvim-tree.lib").get_node_at_cursor()
    abspath = node.link_to or node.absolute_path
    is_folder = node.open ~= nil
  end
  -- local node = require("nvim-tree.lib").get_node_at_cursor()
  -- local abspath = node.link_to or node.absolute_path
  -- local is_folder = node.open ~= nil
  local basedir = is_folder and abspath or vim.fn.fnamemodify(abspath, ":h")
  local opts = {
    basedir = basedir,
  }
  M.add_exec_cder(opts)
end

M.add_exec = function(opts)
  M._exec_toggle(opts)
end
M.add_execFzfRg = function(opts)
  M._exec_toggleFzfRg(opts)
end
M.add_execRanger = function(opts)
  M._exec_toggleRanger(opts)
end



M._exec_toggle = function(opts)
  -- vim.cmd("ToggleTerm" ..
  --   " cmd=" ..
  --   opts.cmd ..
  --   " count=" .. opts.count .. " size=" .. opts.size() .. " direction=" .. opts.direction .. " dir=" .. opts.basedir)
  local venv = os.getenv("CONDA_DEFAULT_ENV") or os.getenv("VIRTUAL_ENV")
  opts.cmd = "'conda activate " .. venv .. "'"
  vim.cmd("TermExec" ..
    " cmd=" ..
    opts.cmd ..
    " count=" ..
    opts.count .. " size=" .. opts.size() .. " direction=" .. opts.direction .. " dir=" .. opts.basedir .. " go_back=0")
end

M._exec_toggleFzfRg = function(opts)
  -- vim.cmd("ToggleTerm" ..
  --   " cmd=" ..
  --   opts.cmd ..
  --   " count=" .. opts.count .. " size=" .. opts.size() .. " direction=" .. opts.direction .. " dir=" .. opts.basedir)
  local venv = os.getenv("CONDA_DEFAULT_ENV") or os.getenv("VIRTUAL_ENV")
  opts.cmd = "'conda activate " .. venv .. "; fzf_rg'"
  vim.cmd("TermExec" ..
    " cmd=" ..
    opts.cmd ..
    " count=" ..
    opts.count .. " size=" .. opts.size() .. " direction=" .. opts.direction .. " dir=" .. opts.basedir .. " go_back=0")
end

M._exec_toggleRanger = function(opts)
  -- vim.cmd("ToggleTerm" ..
  --   " cmd=" ..
  --   opts.cmd ..
  --   " count=" .. opts.count .. " size=" .. opts.size() .. " direction=" .. opts.direction .. " dir=" .. opts.basedir)
  local venv = os.getenv("CONDA_DEFAULT_ENV") or os.getenv("VIRTUAL_ENV")
  opts.cmd = "'conda activate " .. venv .. "; ranger'"

  local Terminal = require("toggleterm.terminal").Terminal
  local Ranger = Terminal:new {
    cmd = 'ranger',
    dir = opts.basedir,
    hidden = true,
    direction = "float",
    close_on_exit = true,
    on_open = function(_)
      vim.cmd "startinsert!"
    end,
    count = opts.count
  }
  Ranger:toggle()
end




M.add_exec_cder = function(opts)
  M._exec_cder(opts)
end

M._exec_cder = function(opts)
  require('telescope').setup({
    defaults = require('telescope.themes').get_ivy({}),
  })
  require('telescope').extensions.cder.cder {
    dir_command = { 'fd', '--type=d', '.', opts.basedir },
    -- dir_command = { 'fd', '--type=d', '.', os.getenv('HOME') .. "/research" },
    previewer_command =
        'exa ' ..
        '-a ' ..
        '--color=always ' ..
        '-T ' ..
        '--level=3 ' ..
        '--icons ' ..
        '--git-ignore ' ..
        '--long ' ..
        '--no-permissions ' ..
        '--no-user ' ..
        '--no-filesize ' ..
        '--git ' ..
        '--ignore-glob=.git',
    theme = 'get_ivy'
  }
  require('telescope').setup({ defaults = lvim.builtin.telescope.defaults })
end

function _G.nvimtreeToDoTelescope(term_mode, state)
  local abspath
  local is_folder
  local success, node = pcall(function()
    return state.tree:get_node()
  end)
  if success then
    abspath = node.link_to or node.path
    is_folder = node.type == "directory"
  else
    node = require("nvim-tree.lib").get_node_at_cursor()
    abspath = node.link_to or node.absolute_path
    is_folder = node.open ~= nil
  end
  -- local node = require("nvim-tree.lib").get_node_at_cursor()
  -- local abspath = node.link_to or node.absolute_path
  -- local is_folder = node.open ~= nil
  local basedir = is_folder and abspath or vim.fn.fnamemodify(abspath, ":h")
  local opts = {
    basedir = basedir,
  }
  M.add_exec_ToDoTelescope(opts)
end

M.add_exec_ToDoTelescope = function(opts)
  M._exec_ToDoTelescope(opts)
end

M._exec_ToDoTelescope = function(opts)
  vim.cmd("TodoTelescope" .. " cwd=" .. opts.basedir .. " theme=get_ivy")
end

return M
