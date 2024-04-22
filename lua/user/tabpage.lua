function find_tabpage_index(tab_id)
  local tabpages = vim.api.nvim_list_tabpages()
  for index, tp in ipairs(tabpages) do
    if tp == tab_id then
      return index
    end
  end
  return nil -- 如果找不到相應的 index，返回 nil
end

function get_current_tab_name()
  local tab_id = vim.fn.tabpagenr()

  local status, TablineData = pcall(vim.fn.json_decode, vim.g.Tabline_session_data)
  if not status then
    return tab_id
  end

  if TablineData[tab_id] ~= nil then
    return TablineData[tab_id].name
  else
    return tab_id
  end
end

function CurrentTabRename()
  -- vim.keymap.set('n', '<leader>tn', ':TablineTabRename ' .. get_current_tab_name(), { silent = false })
  -- 获取当前选项卡的名称
  local tab_name = get_current_tab_name()

  -- 使用vim.ui.input获取用户输入的新选项卡名称
  vim.ui.input({
    -- prompt = "Enter new tab name: ",
    prompt = ":TablineTabRename ",
    default = tab_name,
  }, function(new_tab_name)
    -- 在用户输入后执行的回调函数
    if new_tab_name and new_tab_name ~= "" then
      -- 如果用户输入了新的选项卡名称，设置选项卡名称
      vim.fn.execute("TablineTabRename " .. new_tab_name)
    end
  end)
end

-- lvim.builtin.which_key.mappings["tn"] = { ":TablineTabRename ", "Rename Tab" }
lvim.builtin.which_key.mappings["tn"] = { function() CurrentTabRename() end, "Rename Tab" }
