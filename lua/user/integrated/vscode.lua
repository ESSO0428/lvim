local M = {}
M.host = vim.g.host

function M.encodeHostname(jsonHost)
  local hexHostname = ""
  for i = 1, #jsonHost do
    local byte = string.byte(jsonHost, i)
    hexHostname = hexHostname .. string.format("%02x", byte)
  end
  return hexHostname
end

function M.is_match_exclude_hostname(hostname)
  local is_match_exclude_hostname_bool = vim.fn.index(
    { "YourVscodeReomoteServerName", "" }
    , hostname) ~= -1 and 1 or -1
  return is_match_exclude_hostname_bool
end

function _G.code(file)
  local buffers = vim.api.nvim_list_bufs()
  local fileNames = {}
  if file == '' or file == nil then
    for _, buffer in ipairs(buffers) do
      if (vim.api.nvim_buf_is_valid(buffer) and vim.bo[buffer].buflisted) then
        local fileName = vim.api.nvim_buf_get_name(buffer)

        if (vim.api.nvim_get_current_buf() == buffer) then
          local location = vim.api.nvim_win_get_cursor(0)
          fileName = fileName .. ":" .. location[1] .. ":" .. location[2] + 1
          table.insert(fileNames, 1, fileName)
        else
          table.insert(fileNames, fileName)
        end
      end
    end
  elseif file == "%" then
    local fileName = vim.fn.expand("%:p")
    local location = vim.api.nvim_win_get_cursor(0)
    fileName = fileName .. ":" .. location[1] .. ":" .. location[2] + 1

    table.insert(fileNames, fileName)
  else
    local fileName = file
    local location = vim.api.nvim_win_get_cursor(0)
    fileName = fileName .. ":" .. location[1] .. ":" .. location[2] + 1
    table.insert(fileNames, fileName)
  end

  local cwd = vim.fn.getcwd()
  if not cwd:find("/$") then
    cwd = cwd .. "/"
  end
  vim.cmd("!code -g " .. cwd .. " " .. table.concat(fileNames, " "))
end

function _G.rcode(file)
  local buffers = vim.api.nvim_list_bufs()
  local fileNames = {}
  if file == '' or file == nil then
    for _, buffer in ipairs(buffers) do
      if (vim.api.nvim_buf_is_valid(buffer) and vim.bo[buffer].buflisted) then
        local fileName = vim.api.nvim_buf_get_name(buffer)

        if (vim.api.nvim_get_current_buf() == buffer) then
          local location = vim.api.nvim_win_get_cursor(0)
          fileName = fileName .. ":" .. location[1] .. ":" .. location[2] + 1
          -- fileName = fileName
          table.insert(fileNames, 1, fileName)
        else
          table.insert(fileNames, fileName)
        end
      end
    end
  elseif file == "%" then
    local fileName = vim.fn.expand("%:p")
    local location = vim.api.nvim_win_get_cursor(0)
    fileName = fileName .. ":" .. location[1] .. ":" .. location[2] + 1
    table.insert(fileNames, fileName)
  else
    local fileName = file
    local location = vim.api.nvim_win_get_cursor(0)
    fileName = fileName .. ":" .. location[1] .. ":" .. location[2] + 1
    table.insert(fileNames, fileName)
  end
  local cwd = vim.fn.getcwd()
  if cwd:find("/$") then
    cwd = cwd:sub(1, -2)
  end
  local buf = vim.api.nvim_create_buf(false, true)
  -- local str = "code --remote ssh-remote+" .. host .. " -g " .. cwd .. " " .. table.concat(fileNames, " ")
  -- local lines = vim.split(str, "\n")
  -- vim.api.nvim_buf_set_lines(buf, 0, -1, true, lines)
  -- vim.cmd("edit! " .. vim.api.nvim_buf_get_name(buf))
  -- local str = "code --remote ssh-remote+" .. host .. " `\n" .. cwd .. " `\n" .. table.concat(fileNames, " `\n")

  -- local str = "code --remote ssh-remote+" ..
  --     host .. " `\n" .. cwd .. " `\n" .. "-g `\n" .. table.concat(fileNames, " `\n")

  local is_match_exclude_hostname_bool = M.is_match_exclude_hostname(host)
  local str
  if is_match_exclude_hostname_bool == 1 then
    GetServerHostName(M.host)
    M.host = vim.g.host
    is_match_exclude_hostname_bool = M.is_match_exclude_hostname(M.host)
    if is_match_exclude_hostname_bool == 1 then
      str = "Failed : Not found usefull hostname\n" ..
          "Use left command to Update hostname from Windows PC sshconfig to current Server :UpdateRegisterHostHameFromLocal\n" ..
          "P.S. : Check local open reverse ssh port to current remote server"
    end
  end

  -- 将字符串转换为十六进制编码
  if is_match_exclude_hostname_bool == -1 then
    local jsonHost = '{"hostName":"' .. M.host .. '"}' -- 将主机名转换为 JSON 格式
    local hexHost = M.encodeHostname(jsonHost)         -- 调用 encodeHostname 函数
    str = "code --remote ssh-remote+" ..
        hexHost .. " `\n" .. cwd
    str = str .. "; `\n" ..
        str ..
        " `\n" .. "-g `\n" .. table.concat(fileNames, " `\n")
    local command = "$command = \'" .. str .. "\'; Invoke-Expression $command"
    -- print(command)
  end
  -- 將指令字串寫入檔案
  local logFile = vim.fn.expand('~/.NeovimVscode.log')
  local f = io.open(logFile, 'w')
  f:write(str)
  f:close()

  -- 使用tabnew命令打開新標籤頁顯示檔案
  vim.cmd('tabnew ' .. logFile)

  -- print("code --remote ssh-remote+" .. M.host .. " -g " .. cwd .. " " .. table.concat(fileNames, " "))
end

return M
