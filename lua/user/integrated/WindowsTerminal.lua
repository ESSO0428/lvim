-- WindowsTerminal.lua
local M = {}

-- Define a function to find the path to the settings.json file of Windows Terminal and open it
function M.find_and_edit_terminal_settings()
  -- Use `io.popen` to call `which wt.exe` to get the path
  local wt_path_handle = io.popen("which wt.exe")

  if not wt_path_handle then
    print("Failed to execute command to find wt.exe.")
    return
  end

  local wt_path = wt_path_handle:read("*a"):gsub("\\", "/"):gsub("^/mnt/c/", "C:/"):gsub("\n", "")
  wt_path_handle:close()

  -- Extract the user directory
  local user_dir = wt_path:match("C:/Users/([^/]+)/")

  if user_dir then
    -- Determine the location of the Microsoft.WindowsTerminalPreview directory
    local base_dir = string.format("/mnt/c/Users/%s/AppData/Local/Packages/", user_dir)
    local terminal_dir_handle = io.popen("ls -d " .. base_dir .. "Microsoft.WindowsTerminalPreview*/LocalState")

    if not terminal_dir_handle then
      print("Failed to locate the Windows Terminal directory.")
      return
    end

    local terminal_dir = terminal_dir_handle:read("*a"):gsub("\n", "")
    terminal_dir_handle:close()

    -- Construct the full path to the settings.json file
    local settings_path = terminal_dir .. "/settings.json"

    -- Check if the file exists
    local file = io.open(settings_path, "r")
    if file then
      file:close()
      -- Edit the found settings.json file
      vim.cmd("e " .. settings_path)
    else
      print("settings.json not found.")
    end
  else
    print("Could not determine user directory.")
  end
end

return M
