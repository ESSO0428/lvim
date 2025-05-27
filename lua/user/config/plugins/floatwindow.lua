local M = {}

local ns_previewer = vim.api.nvim_create_namespace "telescope.previewers"
local jump_to_line = function(self, bufnr, lnum)
  pcall(vim.api.nvim_buf_clear_namespace, bufnr, ns_previewer, 0, -1)
  if lnum and lnum > 0 then
    pcall(vim.api.nvim_buf_add_highlight, bufnr, ns_previewer, "TelescopePreviewLine", lnum - 1, 0, -1)
    pcall(vim.api.nvim_win_set_cursor, self.state.winid, { lnum, 0 })
    vim.api.nvim_buf_call(bufnr, function()
      vim.cmd "norm! zz"
    end)
  end
end

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
  vim.api.nvim_set_option_value('cursorline', true, { win = float_win })
  vim.api.nvim_set_option_value('winblend', 0, { win = float_win })
end

-- 將此函數添加到 Neovim 命令
vim.api.nvim_create_user_command('OpenFloat', open_float_window, {})
lvim.keys.normal_mode['sw'] = "<cmd>OpenFloat<CR>"


local pickers = require('telescope.pickers')
local finders = require('telescope.finders')
local previewers = require('telescope.previewers')
local conf = require('telescope.config').values
local actions = require('telescope.actions')
local action_state = require('telescope.actions.state')

local function close_selected_window(window_infos, prompt_bufnr)
  local success, err_message = pcall(function()
    local current_picker = action_state.get_current_picker(prompt_bufnr)
    local selection = action_state.get_selected_entry()
    if selection and selection.value and vim.api.nvim_win_is_valid(selection.value.win) then
      vim.api.nvim_win_close(selection.value.win, false)

      -- 從 window_infos 中移除關閉的窗口並刷新選擇器
      for i, win_info in ipairs(window_infos) do
        if win_info.win == selection.value.win then
          table.remove(window_infos, i)
          break
        end
      end
      current_picker:refresh(finders.new_table({
        results = window_infos,
        entry_maker = function(entry)
          return {
            value = entry,
            display = entry.name,
            ordinal = entry.name,
            bufnr = entry.bufnr,
          }
        end,
      }), { reset_prompt = true })
    end
  end)

  if not success then
    print("Cannot close the last window")
    -- 可以加入其他錯誤處理邏輯，如果需要的話
  end
end

-- HACK: Avoid edgy.nvim layout conflict
-- local edgy_config = require("user.edgy").config
-- M.restricted_fts = {}
M.restricted_fts_set = {}

-- local regions = { "bottom", "left", "right", "top" }

-- 收集所有 ft
-- for _, region in ipairs(regions) do
--   if edgy_config[region] and type(edgy_config[region]) == "table" then
--     for _, obj in ipairs(edgy_config[region]) do
--       if obj.ft then
--         table.insert(restricted_fts, obj.ft)
--       end
--     end
--   end
-- end

-- **優化：改用 table 來存儲 ft，提升查找速度**
-- local restricted_fts_set = {}
-- for _, ft in ipairs(restricted_fts) do
--   restricted_fts_set[ft] = true
-- end

local function list_and_select_windows_in_tab()
  local window_infos = {}

  local windows = vim.api.nvim_tabpage_list_wins(0)
  for _, win in ipairs(windows) do
    local buf = vim.api.nvim_win_get_buf(win)
    local name = vim.fn.expand('#' .. buf .. ':t')     -- 获取文件名
    local filepath = vim.fn.expand('#' .. buf .. ':p') -- 获取文件路径
    local lnum = vim.api.nvim_win_get_cursor(win)[1]
    local src_filetype = vim.api.nvim_get_option_value("filetype", { buf = buf })

    if name == '' then
      name = '[No Name]'
    end
    if filepath ~= '' then
      name = name .. ' (' .. filepath .. ')'
    end

    local is_float = vim.api.nvim_win_get_config(win).relative ~= ''
    local prefix = is_float and "[Float]" or "[Normal]"
    if not M.restricted_fts_set[src_filetype] then
      local display_text = string.format("%-6s %-8s %s",
        tostring(win),
        prefix,
        name
      )
      table.insert(window_infos, { win = win, name = display_text, bufnr = buf, lnum = lnum })
    end
  end

  -- 对 window_infos 进行排序
  table.sort(window_infos, function(a, b)
    return a.name < b.name
  end)


  pickers.new({}, {
    prompt_title = 'Windows',
    finder = finders.new_table({
      results = window_infos,
      entry_maker = function(entry)
        if not entry or not entry.bufnr then
          return nil
        end
        return {
          value = entry,
          display = entry.name,
          ordinal = entry.name,
          bufnr = entry.bufnr,
          lnum = entry.lnum,
        }
      end,
    }),
    sorter = conf.generic_sorter({}),
    previewer = previewers.new_buffer_previewer({
      define_preview = function(self, entry, status)
        if not entry or not entry.bufnr or not vim.api.nvim_buf_is_loaded(entry.bufnr) then
          return
        end

        -- 清除预览窗口的内容
        vim.api.nvim_buf_set_lines(self.state.bufnr, 0, -1, false, {})

        -- 获取并设置内容
        local content = vim.api.nvim_buf_get_lines(entry.bufnr, 0, -1, false)
        vim.api.nvim_buf_set_lines(self.state.bufnr, 0, -1, false, content)

        -- 应用语法高亮
        local filetype = vim.api.nvim_get_option_value("filetype", { buf = entry.bufnr })
        pcall(function()
          vim.api.nvim_set_option_value('filetype', filetype, { buf = self.state.bufnr })
        end)

        -- 尝试手动触发 Tree-sitter 高亮
        pcall(function()
          vim.api.nvim_command('setlocal foldmethod=expr')
          vim.api.nvim_command('setlocal foldexpr=nvim_treesitter#foldexpr()')
          vim.schedule(function()
            jump_to_line(self, self.state.bufnr, entry.lnum)
          end)
        end)
      end,
    }),
    attach_mappings = function(prompt_bufnr, map)
      actions.select_default:replace(function()
        local selection = action_state.get_selected_entry()
        actions.close(prompt_bufnr)
        if selection and selection.value and vim.api.nvim_win_is_valid(selection.value.win) then
          vim.api.nvim_set_current_win(selection.value.win)
        end
      end)

      -- 添加 <c-d> 键映射以关闭选中的窗口并刷新选择器
      map('i', '<c-d>', function()
        close_selected_window(window_infos, prompt_bufnr)
      end)
      map('n', 'dd', function()
        close_selected_window(window_infos, prompt_bufnr)
      end)
      -- 添加 <c-d> 键映射以删除选中的 buffer
      map('n', '<c-w>', function()
        local success, err_message = pcall(function()
          actions.delete_buffer(prompt_bufnr)
        end)
        if not success then
          print("Cannot close the buffer")
          -- 可以加入其他錯誤處理邏輯，如果需要的話
        end
      end)
      return true
    end,
  }):find()
end

-- 將此函數綁定到一個命令或快捷鍵
vim.api.nvim_create_user_command('ListTabWindows', list_and_select_windows_in_tab, {})
lvim.builtin.which_key.mappings.s.w = { "<Cmd>ListTabWindows<CR>", "List Floats" }

return M
