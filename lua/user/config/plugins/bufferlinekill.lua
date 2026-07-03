local M = {}
-- NOTE: 注意 close buffer 的功能可能會因為彩虹括號套件而出錯
-- 請不要安裝和使用 mrjones2014/nvim-ts-rainbow"
-- 改用 HiPhish/nvim-ts-rainbow2
-- 或 HiPhish/rainbow-delimiters.nvim (推薦)

local function switch_to_bufferline_neighbor(windows)
  local bufferline = require("bufferline")
  local state = require("bufferline.state")

  local current = vim.api.nvim_get_current_buf()

  local elements = {}
  for _, component in ipairs(state.components) do
    local element = component:as_element()
    if element then
      table.insert(elements, element)
    end
  end

  local current_index = nil
  local current_group = nil

  for i, element in ipairs(elements) do
    if element.id == current then
      current_index = i
      current_group = element.group
      break
    end
  end

  if not current_index then
    bufferline.cycle(1)
  else
    local group_elements = {}

    if current_group ~= nil then
      for i, element in ipairs(elements) do
        if element.group == current_group then
          table.insert(group_elements, {
            index = i,
            element = element,
          })
        end
      end
    end

    local is_in_group = current_group ~= nil and #group_elements > 0
    local is_group_has_multiple_buffers = #group_elements >= 2
    local is_last_in_group = false

    if is_in_group and is_group_has_multiple_buffers then
      local last_group_item = group_elements[#group_elements]
      is_last_in_group = last_group_item.index == current_index
    end

    if is_group_has_multiple_buffers and is_last_in_group then
      -- 目前 buffer 是同 group 內最後一個，所以關閉後往前一個 bufferline buffer 移動
      bufferline.cycle(-1)
    elseif current_index == #elements then
      -- 不符合 group 特例時
      -- 如果是整個 bufferline 的最後一個，往前移動
      bufferline.cycle(-1)
    else
      -- 一般情況往下一個移動
      bufferline.cycle(1)
    end
  end

  local bufnr = vim.api.nvim_get_current_buf()

  for _, window in ipairs(windows) do
    vim.api.nvim_win_set_buf(window, bufnr)
  end
end

function M.setup()
  require("close_buffers").setup({
    preserve_window_layout = { "this" },
    next_buffer_cmd = switch_to_bufferline_neighbor,
  })

  function BufferLineKill(opts)
    opts = opts or {}
    local force = opts.force or false
    local bo = vim.bo
    local api = vim.api
    local fmt = string.format
    local fn = vim.fn
    local choice

    local bufnr = vim.api.nvim_get_current_buf()
    local bufname = api.nvim_buf_get_name(bufnr)

    if api.nvim_get_option_value("buftype", { buf = bufnr }) == "terminal" then
      if force ~= true then
        vim.cmd('BufferKill')
      else
        vim.cmd([[lua require("lvim.core.bufferline").buf_kill("bd", 0, true)]])
      end
    else
      if force ~= true then
        if bo[bufnr].modified then
          choice = fn.confirm(fmt([[Save changes to "%s"?]], bufname), "&Yes\n&No\n&Cancel")
          if choice == 1 then
            vim.api.nvim_buf_call(bufnr, function()
              vim.cmd("w")
            end)
          elseif choice == 2 then
            do end -- Empty block, no operation
          else
            return
          end
        end
      end

      -- Get list of active buffers
      local buffers = vim.tbl_filter(function(buf)
        return api.nvim_buf_is_valid(buf) and bo[buf].buflisted
      end, api.nvim_list_bufs())
      if #buffers == 1 then
        vim.cmd([[lua require("lvim.core.bufferline").buf_kill("bd", 0, true)]])
      else
        vim.cmd([[lua require('close_buffers').delete({type = 'this', force = true})]])
      end
    end
  end

  vim.api.nvim_create_user_command('BufferLineKill', function() BufferLineKill({ force = false }) end, {})
  vim.api.nvim_create_user_command('ForceBufferLineKill', function() BufferLineKill({ force = true }) end, {})
end

return M
