function Nvim.nvim_create_user_commands(command_names, command_function)
  for _, cmd_name in ipairs(command_names) do
    vim.api.nvim_create_user_command(cmd_name, command_function, {})
  end
end

-- 比较两个表的内容
function Nvim.tables_equal(table1, table2)
  for key, value in pairs(table1) do
    if table2[key] ~= value then
      return false
    end
  end
  for key, value in pairs(table2) do
    if table1[key] ~= value then
      return false
    end
  end
  return true
end
