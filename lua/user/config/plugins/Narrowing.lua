-- Custom function to implement the Narrow effect outside the selected area
function narrow_except_selection(visual_mode)
  -- 保存當前視窗位置
  local start_line, end_line
  if visual_mode then
    -- Get the currently selected area (visual mode)
    _, start_line, _, _ = unpack(vim.fn.getpos("'<"))
    _, end_line, _, _ = unpack(vim.fn.getpos("'>"))
    vim.cmd('split')
    vim.cmd('UfoDisable')
  else
    local ok, err = pcall(function()
      vim.cmd('normal! zaza')
    end)
    if not ok then
      print("Not Found Fold")
      return
    end

    vim.cmd('split')
    vim.cmd('UfoDisable')
    start_line, _ = unpack(vim.api.nvim_win_get_cursor(0))

    vim.cmd('normal! ]z')
    end_line, _ = unpack(vim.api.nvim_win_get_cursor(0))
  end
  vim.fn.cursor(start_line, 0)
  pcall(function() vim.cmd('normal! zo') end)

  -- Handle the part above the selection
  if start_line > 1 then
    -- Move to the first line, select to the line before the start line, unfold and fold
    vim.fn.cursor(start_line - 1, 0)
    pcall(function() vim.cmd('normal! VggzDgvzf') end)
  end

  -- Handle the part below the selection
  local last_line = vim.fn.line('$')
  if end_line < last_line then
    -- Move to the line after the end line, select to the last line, unfold and fold
    vim.fn.cursor(end_line + 1, 0)
    pcall(function() vim.cmd('normal! VGzDgvzf') end)
  end
end

-- Bind the function to the shortcut key <leader>On in visual mode
lvim.keys.visual_mode['<leader>On'] = ':<C-u>lua narrow_except_selection(true)<CR>'
lvim.builtin.which_key.mappings['On'] = { '<cmd>lua narrow_except_selection()<CR>', 'Zoom-in Folding to split' }
