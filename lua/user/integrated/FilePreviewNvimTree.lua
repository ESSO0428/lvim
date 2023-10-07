local M = {
  open_win_config = {
    relative = "editor",
    border = "rounded",
    width = 30,
    height = 30,
    row = 1,
    col = 1,
  }
}

local function get_node(state)
  local success, node = pcall(function()
    return state.tree:get_node()
  end)
  if not success then
    node = require("nvim-tree.lib").get_node_at_cursor()
  end
  return node
end

local function get_formatted_lines(state)
  local node = get_node(state)
  local abspath = node.link_to or node.absolute_path

  local fpath = "fullpath: " .. abspath

  -- 使用 wc -l 命令统计文件行数
  local line_count = vim.fn.system("wc -l " .. vim.fn.shellescape(abspath)):match("%d+")
  local lines_info = "Lines: " .. line_count

  -- 使用 head 命令预览文件内容
  local file_preview = vim.fn.systemlist("head -n 30 " .. vim.fn.shellescape(abspath))

  -- Create a separator line with the same length as fpath
  local separator = string.rep("—", #fpath)

  return vim.tbl_flatten({
    fpath,
    lines_info,
    separator,
    file_preview
  })
end

local current_popup = nil

local function setup_window(node)
  local lines = get_formatted_lines(node)

  local max_width = vim.fn.max(vim.tbl_map(function(n)
    return #n
  end, lines))

  local open_win_config = vim.tbl_extend("force", M.open_win_config, {
    width = max_width + 1,
    height = #lines,
    row = (vim.o.lines - #lines) / 2,            -- Center vertically
    col = (vim.o.columns - (max_width + 1)) / 2, -- Center horizontally
    noautocmd = true,
    zindex = 60,
  })

  local winnr = vim.api.nvim_open_win(0, false, open_win_config)
  vim.api.nvim_win_set_option(winnr, "number", false) -- Hide line numbers

  current_popup = {
    winnr = winnr,
    file_path = node.absolute_path,
  }
  local bufnr = vim.api.nvim_create_buf(false, true)
  -- vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, lines)
  -- 使用 pcall 捕获可能的错误
  local success, err = pcall(function()
    vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, lines)
  end)

  if not success then
    -- 如果出现错误，修改 lines
    lines = {
      "Error previewing this file.",
      "It might not be a text file."
    }
    vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, lines)
  end
  vim.api.nvim_win_set_buf(winnr, bufnr)
end


function M.close_popup()
  if current_popup ~= nil then
    vim.api.nvim_win_close(current_popup.winnr, { force = true })
    vim.cmd "augroup NvimTreeRemoveFilePopup | au! CursorMoved | augroup END"

    current_popup = nil
  end
end

function M.toggle_file_info(node)
  if not node then
    node = get_node()
  end

  if not node or node.name == ".." then
    return
  end

  if current_popup ~= nil then
    local is_same_node = current_popup.file_path == node.absolute_path

    M.close_popup()

    if is_same_node then
      return
    end
  end

  setup_window(node)

  vim.api.nvim_create_autocmd("CursorMoved", {
    group = vim.api.nvim_create_augroup("NvimTreeRemoveFilePopup", {}),
    callback = M.close_popup,
  })
end

function M.setup(opts)
  M.open_win_config = opts.actions.file_popup.open_win_config
end

return M
