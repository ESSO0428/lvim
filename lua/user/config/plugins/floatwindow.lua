local function open_float_window()
  -- 獲取當前緩衝區的檔案路徑
  local filepath = vim.fn.expand('%:p')
  if filepath == '' then
    filepath = '[No Name]'
  end

  -- 定義浮動窗口的尺寸
  local width = 120
  local height = 15

  -- 獲取當前光標位置
  local cursor_row, cursor_col = unpack(vim.api.nvim_win_get_cursor(0))

  -- 計算浮動窗口的起始位置
  local row = math.max(0, cursor_row - 1)
  local col = math.max(0, cursor_col - 1)

  -- 創建一個新的浮動窗口
  local float_win = vim.api.nvim_open_win(0, true, {
    relative = 'cursor',
    width = width,
    height = height,
    row = row,
    col = col,
    border = 'single',
    title = "↖ " .. filepath
  })

  -- 設置浮動窗口的一些選項
  vim.api.nvim_win_set_option(float_win, 'cursorline', true)
  vim.api.nvim_win_set_option(float_win, 'winblend', 0)
end

-- 將此函數添加到 Neovim 命令
vim.api.nvim_create_user_command('OpenFloat', open_float_window, {})
lvim.keys.normal_mode['su'] = "<Cmd>OpenFloat<CR>"

local function list_and_select_windows_in_tab()
  local tabpage = vim.api.nvim_get_current_tabpage()
  local windows = vim.api.nvim_tabpage_list_wins(tabpage)
  local window_infos = {}

  for _, win in ipairs(windows) do
    local buf = vim.api.nvim_win_get_buf(win)
    local name = vim.fn.expand('#' .. buf .. ':t') -- 獲取檔案名
    if name == '' then
      name = '[No Name]'
    end
    local filepath = vim.fn.expand('#' .. buf .. ':p') -- 獲取檔案名
    if filepath ~= '' then
      name = name .. ' (' .. filepath .. ')'
    end

    local is_float = vim.api.nvim_win_get_config(win).relative ~= ''
    local prefix = is_float and "f: " or "n: "
    table.insert(window_infos, { win = win, name = prefix .. name })
  end

  -- 將浮動窗口放在列表前面
  table.sort(window_infos, function(a, b)
    return a.name < b.name
  end)

  local buf = vim.api.nvim_create_buf(false, true)
  local lines = {}
  local function remove_line_from_list(line, lines)
    if window_infos[line] then
      table.remove(window_infos, line)
      table.remove(lines, line)
      vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
    end
  end

  for i, win_info in ipairs(window_infos) do
    lines[i] = win_info.name
  end
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)

  local width = 100
  local height = math.min(10, #lines)
  local row = math.max(1, math.floor((vim.o.lines - height) / 2))
  local col = math.max(1, math.floor((vim.o.columns - width) / 2))

  local float_win = vim.api.nvim_open_win(buf, true, {
    relative = 'editor',
    width = width,
    height = height,
    row = row,
    col = col,
    border = 'single'
  })
  vim.api.nvim_buf_set_keymap(buf, 'n', '<CR>', '', {
    callback = function()
      local line = vim.api.nvim_win_get_cursor(float_win)[1]
      local target_win = window_infos[line].win
      -- 關閉列表浮動窗口
      if vim.api.nvim_win_is_valid(float_win) then
        vim.api.nvim_win_close(float_win, true)
      end
      -- 然後切換到目標窗口
      if vim.api.nvim_win_is_valid(target_win) then
        vim.api.nvim_set_current_win(target_win)
      end
    end,
    noremap = true
  })

  -- 添加 'dd' 鍵映射
  vim.api.nvim_buf_set_keymap(buf, 'n', 'dd', '', {
    callback = function()
      local line = vim.api.nvim_win_get_cursor(float_win)[1]
      local target_win = window_infos[line] and window_infos[line].win

      -- 检查是否还有其他窗口存在
      if #window_infos > 1 then
        if target_win and vim.api.nvim_win_is_valid(target_win) then
          vim.api.nvim_win_close(target_win, false)
          vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
        else
          print("Window not valid")
        end
        remove_line_from_list(line, lines)
      else
        print("Cannot close the last window")
      end
    end,
    noremap = true
  })

  -- <c-w> 关闭已保存的文件
  vim.api.nvim_buf_set_keymap(buf, 'n', '<c-w>', '', {
    callback = function()
      local line = vim.api.nvim_win_get_cursor(float_win)[1]
      local target_win_info = window_infos[line]
      if target_win_info and vim.api.nvim_win_is_valid(target_win_info.win) then
        local target_buf = vim.api.nvim_win_get_buf(target_win_info.win)
        if vim.api.nvim_buf_is_loaded(target_buf) and not vim.api.nvim_buf_get_option(target_buf, 'modified') then
          vim.api.nvim_buf_delete(target_buf, { force = false })
          remove_line_from_list(line, lines)
        else
          print("Buffer has unsaved changes")
        end
      else
        print("Window not valid")
        remove_line_from_list(line, lines)
      end
    end,
    noremap = true
  })

  -- <leader><c-w> 强制关闭文件
  vim.api.nvim_buf_set_keymap(buf, 'n', '<leader><c-w>', '', {
    callback = function()
      local line = vim.api.nvim_win_get_cursor(float_win)[1]
      local target_win_info = window_infos[line]
      if target_win_info and vim.api.nvim_win_is_valid(target_win_info.win) then
        local target_buf = vim.api.nvim_win_get_buf(target_win_info.win)
        if vim.api.nvim_buf_is_loaded(target_buf) then
          vim.api.nvim_buf_delete(target_buf, { force = true })
        end
      else
        print("Window not valid")
      end
      remove_line_from_list(line, lines)
    end,
    noremap = true
  })
end

-- 將此函數綁定到一個命令或快捷鍵
vim.api.nvim_create_user_command('ListTabWindows', list_and_select_windows_in_tab, {})
lvim.builtin.which_key.mappings.s.w = { "<Cmd>ListTabWindows<CR>", "List Floats" }
