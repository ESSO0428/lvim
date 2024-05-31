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

-- 設置鍵位映射，在 normal mode 下按 `gW` 執行 `CustomGWL`
vim.api.nvim_set_keymap('n', 'gww', ':CustomGWL<CR>', { noremap = true, silent = true })
