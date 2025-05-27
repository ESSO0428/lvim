--[[
 THESE ARE EXAMPLE CONFIGS FEEL FREE TO CHANGE TO WHATEVER YOU WANT
 `lvim` is the global options object
]]
-- vim options
vim.opt.shiftwidth = 2
vim.opt.tabstop = 2
-- vim.opt.relativenumber = true
vim.opt.number = true
vim.opt.equalalways = false
vim.opt.mousemoveevent = true
lvim.builtin.project.manual_mode = true
-- 摺疊代碼
vim.wo.foldlevel = 99
vim.wo.foldenable = true
vim.wo.foldmethod = "expr"
vim.wo.foldexpr = "nvim_treesitter#foldexpr()"
-- vim.g.conda_auto_activate_base = 0 -- 关闭 base 环境的自动激活
-- vim.g.conda_auto_env = 1 -- 开启自动激活环境
-- vim.g.conda_env = 'base' -- 设置自动激活的 conda 环境
-- add rtp $HOME/.cheetseet/ as help file
vim.opt.rtp:append { os.getenv("HOME") .. "/.cheatsheet" }

local function get_clipboard_content()
  local content = vim.fn.getreg('')
  local regtype = vim.fn.getregtype('')
  return { vim.fn.split(content, '\n'), regtype }
end
vim.g.clipboard = {
  name = 'OSC 52',
  copy = {
    ['+'] = require('vim.ui.clipboard.osc52').copy('+'),
    ['*'] = require('vim.ui.clipboard.osc52').copy('*'),
  },
  paste = {
    -- neovim official pasted method (will delay in windows terminal)
    -- ['+'] = require('vim.ui.clipboard.osc52').paste('+'),
    -- ['*'] = require('vim.ui.clipboard.osc52').paste('*')
    -- my custom pasted method (will not delay in windows terminal)
    ['+'] = get_clipboard_content,
    ['*'] = get_clipboard_content
  }
}
vim.opt.termguicolors = true

-- signcolumn
vim.wo.signcolumn = "auto:3-6"

-- 取消預覽取代結果
-- vim.o.fileformats = "unix"
-- vim.opt.inccommand = ""
vim.opt.inccommand = "split"
vim.opt.spell = true
-- spell options noplainbuffer (default) add camel
vim.opt.spelloptions:append "camel"

vim.opt.list = false
vim.opt.listchars:append "space:·"

-- Pmenu
vim.opt.completeopt = "menuone,noselect,popup"

vim.g.PythonEnv = os.getenv("CONDA_DEFAULT_ENV") or os.getenv("VIRTUAL_ENV")
vim.g.WorkDirectoryPath = vim.fn.getcwd()

-- 用於 nvim-navbuddy
-- 更新 core plug 的 nvim-navic
-- (到該目錄下先執行) git fetch; git pull

lvim.keys.normal_mode['s;'] = "<cmd>set relativenumber!<cr>"
lvim.keys.normal_mode["<leader>n"] = "<c-w><c-p>"
lvim.builtin.lir.active = true

-- breadcrumb
-- lvim.builtin.breadcrumbs.active = false
lvim.builtin.breadcrumbs.winbar_filetype_exclude[#lvim.builtin.breadcrumbs.winbar_filetype_exclude + 1] = "quickfix"
lvim.builtin.breadcrumbs.winbar_filetype_exclude[#lvim.builtin.breadcrumbs.winbar_filetype_exclude + 1] = "dbui"
lvim.builtin.breadcrumbs.winbar_filetype_exclude[#lvim.builtin.breadcrumbs.winbar_filetype_exclude + 1] = "undotree"
lvim.builtin.breadcrumbs.winbar_filetype_exclude[#lvim.builtin.breadcrumbs.winbar_filetype_exclude + 1] = "Avante"
lvim.builtin.breadcrumbs.winbar_filetype_exclude[#lvim.builtin.breadcrumbs.winbar_filetype_exclude + 1] = "AvanteInput"
---@diagnostic disable-next-line: duplicate-set-field
require("lvim.core.breadcrumbs").create_winbar = function()
  vim.api.nvim_create_augroup("_winbar", {})
  vim.api.nvim_create_autocmd({
    "CursorHoldI",
    "CursorHold",
    "BufWinEnter",
    "BufFilePost",
    "InsertEnter",
    "BufWritePost",
    "TabClosed",
    "TabEnter",
  }, {
    group = "_winbar",
    callback = function()
      if lvim.builtin.breadcrumbs.active then
        local status_ok, _ = pcall(vim.api.nvim_buf_get_var, 0, "lsp_floating_window")
        if not status_ok then
          if vim.bo.buftype ~= "" then return end
          require("lvim.core.breadcrumbs").get_winbar()
        end
      end
    end,
  })
end


-- bufferline offset
lvim.builtin.bufferline.options.always_show_bufferline = true
lvim.builtin.bufferline.options.offsets[#lvim.builtin.bufferline.options.offsets + 1] = {
  filetype = "dbui",
  text = "DBUI",
  highlight = "PanelHeading",
  padding = 1
}
local dap_filetypes = { "dapui_scopes", "dapui_breakpoints", "dapui_stacks", "dapui_watches" }

for _, filetype in ipairs(dap_filetypes) do
  table.insert(lvim.builtin.bufferline.options.offsets, {
    filetype = filetype,
    text = "DAP",
    highlight = "PanelHeading",
    padding = 1
  })
end

-- 與 vscode 集成
-- ex: code --remote ssh-remote+LabServerDP
-- default hostname
vim.g.host = "YourVscodeReomoteServerName"
local host = vim.g.host

-- 與 `vscode remote ssh` 集成
-- 取得如範例的指令: `code --remote ssh-remote+LabServerDP`
-- 這裡用於取得 `hosname`, ex : `LabServerDP`
-- 通過讀取 `~/.ssh/host_names` 文件，來取得對上述 `hostname`
-- 如果 `~/.ssh/host_names` 文件不存在或格式有誤則使用預設的 `hostname`
-- 或是最後一次使用的 `hostname`，這些 `hostname` 將會寫入 `vim.g.host`
-- ---
-- 特別注意範例的 `YourVscodeReomoteServerName` 再後續與 `vscode` 集成的 function `rcode` 會被視為排除對象
---@param host string
function GetServerHostName(host)
  local ip = nil

  -- NOTE: 棄用 `hostname -I`，因為某些 Linux 發行版 (如 Arch) 未支援此參數
  -- 改用 ip -json 搭配 grep 抓取本機 IP，更具相容性
  -- local command = io.popen("hostname -I 2> /dev/null | awk '{print $1}'")
  local command = io.popen([[ip -json route get 8.8.8.8 | grep -oP '"prefsrc":\s*"\K[0-9.]+' 2> /dev/null]])
  ip = command:read("*line")
  command:close()

  -- 使用 Lua 读取 ~/.ssh/host_names 文件获取主机名和对应的 IP
  local hostnames_file = os.getenv("HOME") .. "/.ssh/host_names"
  if vim.fn.filereadable(hostnames_file) == 1 then
    local file = io.open(hostnames_file, "r")
    if file then
      for line in file:lines() do
        local hostname, hostname_ip = line:match("(%S+)%s+(%S+)")
        if hostname_ip and hostname_ip == ip then
          host = hostname
          vim.g.host = host
          break
        end
      end
      file:close()
    end
  end
end

GetServerHostName(host)

vim.cmd('source $HOME/.config/lvim/init.vim')
vim.cmd('source $HOME/.config/lvim/keymap.vim')



-- 排除當前使用者或 Andy6, andy6 使用者目錄下的 home 目錄，避免遞迴讀取 home 目錄底下的所有使用者目錄 (root 除外)
local username = vim.fn.system("whoami")
username = username:gsub("\n", "") -- 移除換行符號
if username == "root" then
  username = "_Andy6_"
end
lvim.builtin.nvimtree.setup.filters = {
  dotfiles = false,
  git_clean = false,
  no_buffer = false,
  -- 忽略 User 下的 home link (並建立例外清單，允許 research 底下的 home)
  -- custom = { "node_modules", "\\.cache", "^home$" },
  custom = { "node_modules", "\\.cache", "^home$" },
  exclude = {
    ".*/Andy6/.*/.*home",
    ".*/andy6/.*/.*home",
    string.format(".*/%s/.*/.*home", username),
  },
}
lvim.builtin.nvimtree.setup.actions.change_dir = {
  enable = false,
  global = true,
  restrict_above_cwd = false,
}
lvim.builtin.nvimtree.setup.actions.open_file.window_picker.exclude = {
  filetype = { "notify", "lazy", "qf", "diff", "fugitive", "fugitiveblame", "terminal", "Outline", "edgy" },
  buftype = { "nofile", "terminal", "help", "Outline", "quickfix" },
}
-- nvimtree tab sync default is false
lvim.builtin.nvimtree.setup.tab.sync.open = false

-- when nvimtree open weather disable auto resize all windows of current tab
lvim.builtin.nvimtree.setup.view.preserve_window_proportions = true

local function is_nfs_mount(path)
  local handle = io.popen("df -T " .. path .. " | tail -n 1")
  local result = handle:read("*a")
  handle:close()

  -- 检查文件系统类型是否为 nfs
  if result:find("nfs") then
    return true
  else
    return false
  end
end

-- NOTE: judge if current path is on
-- NFS file system will disable nvim-tree
-- will switch nvim-tree to neo-tree
if is_nfs_mount(vim.fn.getcwd()) then
  -- NOTE: using nvim-tree or neo-tree
  lvim.builtin.nvimtree.active = false
else
  lvim.builtin.nvimtree.active = true
end

-- general
lvim.log.level = "info"
lvim.format_on_save = {
  enabled = true,
  pattern = {
    "*.lua",
    "*.html",
    "*.css",
    "*.js",
    "*.tsx"
  },
  timeout = 10000, -- default 1000 ms
}


vim.g.move_auto_indent                              = 0
vim.g.move_normal_option                            = 1
vim.g.move_key_modifier                             = 'C'
-- vim.g.move_key_modifier_visualmode = 'S'

-- keymappings <https://www.lunarvim.org/docs/configuration/keybindings>
lvim.leader                                         = "space"
lvim.keys.normal_mode["S"]                          = "<cmd>w<cr>"

-- -- Change theme settings
-- lvim.colorscheme = "lunar"

lvim.builtin.alpha.active                           = true
lvim.builtin.alpha.mode                             = "dashboard"
lvim.builtin.terminal.active                        = true
lvim.builtin.nvimtree.setup.view.side               = "left"
lvim.builtin.nvimtree.setup.renderer.icons.show.git = false

-- git default false
lvim.builtin.gitsigns.opts.current_line_blame       = false

-- delete lvim auto resize
vim.api.nvim_del_augroup_by_name('_auto_resize')

-- relationship with gx
---@diagnostic disable-next-line: duplicate-set-field
vim.ui.open = function(url)
  local function is_url(text)
    local pattern = "^(https?://.+)$"
    return text:match(pattern) ~= nil
  end
  local function check_rssh_tunnel()
    local rssh_tunnel_path = os.getenv("HOME") .. "/.rssh_tunnel"
    local file = io.open(rssh_tunnel_path, "r")
    if file then
      -- read the first line as port
      local port = file:read("*l")
      file:close()
      return port
    end
    return nil
  end

  local function is_ssh_tunnel_alive(port)
    local command = string.format(
      [[netstat -tuln | grep -q -E '127\.0\.0\.1:%s\s' && echo success]],
      port, port
    )
    local result = io.popen(command):read("*a")
    return result:find("success") ~= nil
  end

  local function is_wsl()
    local wsl_check = io.popen("grep -i microsoft /proc/version")
    local result = wsl_check:read("*a")
    if wsl_check then wsl_check:close() end
    return result:find("microsoft") ~= nil
  end

  local open_cmd
  if is_wsl() and is_url(url) then
    open_cmd = string.format('cmd.exe /C start "%s" > /dev/null 2>&1', url)
  else
    open_cmd = string.format('xdg-open "%s"', url)
  end

  -- try to check if nc channel is available
  local port = check_rssh_tunnel()
  if is_url(url) and port and is_ssh_tunnel_alive(port) then
    local nc_command = string.format("echo 'cmd.exe /C start \"%s\" > /dev/null 2>&1' | nc -w 1 127.0.0.1 %s", url, port)
    -- use jobstart to run command non-blocking
    vim.fn.jobstart({ vim.o.shell, vim.o.shellcmdflag, nc_command }, { detach = true })
  else
    -- if nc channel is not available, run command directly
    vim.fn.jobstart({ vim.o.shell, vim.o.shellcmdflag, open_cmd }, { detach = true })
  end
end
