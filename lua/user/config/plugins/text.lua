-- 使用 cfile 就可以用讀取檔案路徑的功能了
-- set isfname +=32
vim.opt.isfname:append { 32 }
function XOpenFileOrFold()
  local line = vim.fn.expand('<cfile>')
  local path = line:gsub("^%s*(.-)%s*$", "%1")
  if path:sub(1, 1) == '~' then
    path = vim.fn.expand('~') .. path:sub(2)
  end
  if path:sub(1, 4) == 'http' then
    local command = string.format("silent !xdg-open '%s'", path)
    vim.api.nvim_command(command)
  else
    if vim.fn.executable("explorer.exe") == 1 then
      local command = string.format("silent !explorer.exe `wslpath -w '%s'`", path)
      vim.api.nvim_command(command)
    else
      local command = string.format("silent !xdg-open '%s'", path)
      vim.api.nvim_command(command)
    end
  end
end

vim.api.nvim_create_augroup("text_file_custom", {})
vim.api.nvim_create_autocmd({
  "BufWinEnter"
}, {
  -- pattern = { "*.txt", "*.log" },
  group = "text_file_custom",
  callback = function()
    vim.keymap.set('n', 'go', '<cmd>lua XOpenFileOrFold()<cr>', { silent = true, buffer = true })
  end
})
