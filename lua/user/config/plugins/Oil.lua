-- Read file content
local function read_file(file_path)
  local file = io.open(file_path, "r")
  if not file then
    return nil
  end

  local content = file:read("*a")
  file:close()
  return content
end

-- Parse aliases from the shell configuration files
local function parse_aliases(content)
  local aliases = {}
  for line in content:gmatch("[^\r\n]+") do
    local name, command = line:match("^alias%s+([%w_%-%.]+)%s*=%s*['\"](.-)['\"]")
    if name and command then
      aliases[name] = command
    end
  end
  return aliases
end

-- Parse SSH configuration from ~/.ssh/config
local function parse_ssh_config(content)
  local hosts = {}
  local current_host = nil

  for line in content:gmatch("[^\r\n]+") do
    local host = line:match("^%s*Host%s+(.+)")
    if host then
      current_host = host
      hosts[current_host] = {}
    elseif current_host then
      local key, value = line:match("^%s*(%S+)%s+(.*)")
      if key and value then
        hosts[current_host][key] = value
      end
    end
  end
  return hosts
end

-- Load aliases from .bashrc or .zshrc files
local function load_aliases()
  local bashrc_content = read_file(os.getenv("HOME") .. "/.bashrc")
  local zshrc_content = read_file(os.getenv("HOME") .. "/.zshrc")

  -- Parse aliases from both files
  local bashrc_aliases = bashrc_content and parse_aliases(bashrc_content) or {}
  local zshrc_aliases = zshrc_content and parse_aliases(zshrc_content) or {}

  -- Merge alias tables from both files
  local aliases = vim.tbl_extend("force", bashrc_aliases, zshrc_aliases)

  return aliases
end

-- Load SSH configuration from ~/.ssh/config and retrieve Hosts
local function load_ssh_config()
  local ssh_config_content = read_file(os.getenv("HOME") .. "/.ssh/config")

  -- Parse SSH Hosts from the configuration file
  local ssh_hosts = ssh_config_content and parse_ssh_config(ssh_config_content) or {}

  return ssh_hosts
end

-- Split command into key-value pairs, similar to awk in bash
local function split_command_to_table(command)
  local parts = {}
  for part in command:gmatch("%S+") do
    table.insert(parts, part)
  end
  return parts
end

-- Extract remote_ip, remote_path, and port from the alias command
local function extract_ssh_details(alias_command, arg)
  local parts = split_command_to_table(alias_command)
  local remote_ip, remote_path, port = nil, nil, nil

  -- Iterate over each part of the command
  for i, part in ipairs(parts) do
    if part == "-p" then
      port = parts[i + 1] -- Port number usually follows "-p"
    elseif part:find("@") then
      remote_ip = part    -- Find user@host part
    end
  end

  -- Extract remote_path from the provided argument
  remote_path = arg:match(":(.+)")

  return remote_ip, remote_path, port
end

-- Expand alias or SSH configuration Host
local function expand_alias_or_host(alias_or_host, arg)
  local aliases = load_aliases()
  local ssh_hosts = load_ssh_config()

  -- Check if it's an alias
  local alias_command = aliases[alias_or_host]
  if alias_command then
    -- Extract SSH details from the alias command
    local remote_ip, remote_path, port = extract_ssh_details(alias_command, arg)
    if remote_ip then
      return remote_ip, remote_path, port
    end
  end

  -- Check if it's a Host from SSH configuration
  if ssh_hosts[alias_or_host] then
    return alias_or_host, arg, nil
  end

  return nil, nil, nil
end

-- Retrieve all aliases and SSH configuration Hosts for completion
local function get_alias_completion()
  local aliases = load_aliases()
  local ssh_hosts = load_ssh_config()

  local alias_names = vim.tbl_keys(aliases)
  local host_names = vim.tbl_keys(ssh_hosts)

  -- Merge alias and Host names for completion
  local completions = vim.tbl_extend("force", alias_names, host_names)
  table.sort(completions)
  return completions
end

-- Handle SSH connections
local function oilssh(args)
  local alias_or_ssh = args.args
  local alias = alias_or_ssh:match("([^/]+)")
  local path = alias_or_ssh:match("/.*")

  -- Automatically append "/" if the path is missing
  if not path then
    path = "/"
    alias_or_ssh = alias_or_ssh .. "/"
  end

  local expanded_ip, expanded_path, port = expand_alias_or_host(alias, path or "")
  if not expanded_path then
    expanded_path = '/'
  end

  if expanded_ip then
    local ssh_ip_adress = expanded_ip .. (port and (":" .. port) or "") .. (expanded_path or "")
    vim.cmd("e oil-ssh://" .. ssh_ip_adress)
  else
    print("Error: Could not find a valid alias or SSH config host for '" .. alias_or_ssh .. "'.")
  end
end

-- Create Neovim command and set up completion
vim.api.nvim_create_user_command('Oilssh', oilssh, {
  nargs = 1,
  complete = function(ArgLead, CmdLine, CursorPos)
    return get_alias_completion()
  end,
})
