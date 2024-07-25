-- 定義一個函數來實現您所描述的功能
local function custom_gwl()
  -- 讀取當前的 `tw` 值
  local current_tw = vim.o.tw

  -- 提示用戶輸入新的 `tw` 值
  local new_tw = vim.fn.input('Enter the number of characters per line: ')

  -- 檢查輸入值是否為有效數字
  if tonumber(new_tw) then
    new_tw = tonumber(new_tw)
    -- 修改 `tw` 值並執行 `gwl`
    vim.o.tw = new_tw
    vim.cmd('normal! gwl')
    -- 恢復原始的 `tw` 值
    vim.o.tw = current_tw
  else
    print("Invalid input. Operation cancelled.")
  end
end

-- 創建一個用戶命令 `CustomGWL` 綁定到 `custom_gwl` 函數
vim.api.nvim_create_user_command('CustomGWL', custom_gwl, {})
vim.api.nvim_set_keymap('n', 'gww', ':CustomGWL<CR>', { noremap = true, silent = true })

-- 定義一個函數來插入指定的 code block
local function SurroundCodeWithCodeBlock()
  -- 請求用戶輸入代碼塊的語言
  vim.ui.input({ prompt = 'Enter code block language: ' }, function(language)
    if language then
      -- 獲取當前選擇的範圍
      local start_row = vim.fn.getpos("'<")[2]
      local end_row = vim.fn.getpos("'>")[2]

      -- 插入 code block 的開始和結束標記
      vim.fn.append(start_row - 1, "```" .. language)
      vim.fn.append(end_row + 1, "```")
    end
  end)
end

-- 創建一個用戶命令 `SurroundCodeWithCodeBlock` 綁定到 `SurroundCodeWithCodeBlock` 函數
vim.api.nvim_create_user_command('SurroundCodeWithCodeBlock', SurroundCodeWithCodeBlock, {})
vim.api.nvim_set_keymap('v', ',c', ':<C-U>SurroundCodeWithCodeBlock<CR>', { noremap = true, silent = true })
