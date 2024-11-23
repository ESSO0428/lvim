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

Nvim.null_ls = {}

-- Create a function to generate CLI format action
function Nvim.null_ls.create_cli_format_action(opts)
  local command = opts.command
  local args = opts.args or {}
  local name = opts.name or command

  -- Replace $FILENAME in args with actual file path
  local function get_formatted_args(file_path)
    local final_args = {}
    for _, arg in ipairs(args) do
      if arg == "$FILENAME" then
        table.insert(final_args, file_path)
      else
        table.insert(final_args, arg)
      end
    end
    return final_args
  end

  -- Format file function
  local function format_file()
    -- current file path
    local file_path = vim.fn.expand("%:p")

    -- prepare command arguments
    local formatted_args = get_formatted_args(file_path)
    local full_command = command .. " " .. table.concat(formatted_args, " ")
    print(full_command)

    -- execute command
    local result = vim.fn.system(full_command)

    -- if format failed, print error message
    if vim.v.shell_error ~= 0 then
      print(name .. " format failed: " .. result)
      return
    end

    -- refresh buffer
    vim.api.nvim_command("e")
    print("File formatted and buffer refreshed.")
  end

  -- Return the action function
  return function()
    -- check if file is modified
    if vim.bo.modified then
      -- hint user to save file using vim.ui.select
      vim.ui.select(
        { "Yes", "No" },
        {
          prompt = "File is not saved. Save before formatting?",
          format_item = function(item) return item end,
        },
        function(choice)
          if choice == "Yes" then
            vim.api.nvim_command("w")
            format_file()
          else
            print("Formatting canceled.")
          end
        end
      )
      return
    end

    -- 直接執行格式化
    format_file()
  end
end
