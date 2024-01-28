local neotree = require("neo-tree")
lvim.builtin.bufferline.options.offsets[#lvim.builtin.bufferline.options.offsets + 1] = {
  filetype = "neo-tree",
  text = "Explorer",
  highlight = "PanelHeading",
  padding = 1,
}
local username = vim.fn.system("whoami")
username = username:gsub("\n", "") -- 移除換行符號
if username == "root" then
  username = "_Andy6_"
end
local custom_mappings = {
  -- ["/"] = "telescope",
  -- navigate_up == dir_up
  ["-"] = "navigate_up",
  ["."] = "set_root",
  -- ["g/"] = "fuzzy_finder",
  ["<2-leftmouse>"] = "open",
  ["<a-o>"] = "system_open_dir",
  ["<leader><a-o>"] = "system_open",
  ["<c-x>"] = "clear_filter",
  ["<cr>"] = "open",
  ["l"] = "open",
  ["<tab>"] = { "toggle_preview", config = { use_float = true } },
  ["<leader><tab>"] = "focus_preview",
  -- ["h"] = "toggle_node",
  ["g?"] = "show_help",
  ["A"] = "add_directory",
  ["h"] = "close_node",
  ["zh"] = "toggle_hidden",
  ["`"] = "refresh",
  ["<a-k>"] = "open_split",
  ["[g"] = "prev_git_modified",
  ["]g"] = "next_git_modified",
  ["a"] = "add",
  ["c"] = "copy",
  ["d"] = "delete",
  ["<leader>/"] = "filter_on_submit",
  ["<c-r>"] = "move",
  ["p"] = "paste_from_clipboard",
  ["q"] = "close_window",
  ["r"] = "rename",
  ["<a-l>"] = "open_vsplit",
  -- ["t"] = "open_tabnew",
  -- ["w"] = "open_with_window_picker",
  ["x"] = "cut_to_clipboard",
  ["y"] = "copy_name",
  ["Y"] = "copy_path",
  ["gy"] = "copy_absolute_path",
  ["W"] = "close_all_nodes",
  ["E"] = "expand_all_nodes",
  -- ["<"] = "prev_source",
  -- [">"] = "next_source",
}
local custom_mappings_plus = {
  ['<leader>sf'] = "neotree_telescope_find_file",
  ['<leader>sF'] = "telescope_file_browser",
  ['<leader>sg'] = "neotree_telescope_live_grep",
  ['<leader>sm'] = "telescope_media_files",
  ['<leader>sd'] = "CderOpen",
  ['<leader>TT'] = "ToDoOpen",
  ['<leader><M-1>'] = "horizontal_term",
  ['<leader><M-2>'] = "vertical_term",
  ['<leader><M-3>'] = "float_term",
  ['<leader><M-f>'] = "horizontal_termFzfRg",
  ['<c-\\>'] = "float_term",
}
local custom_commands = {
  copy_name = function(state)
    -- copy path of current node to unnamed register
    -- vim.fn.setreg("", state.tree:get_node().path)
    local node = state.tree:get_node()
    vim.fn.setreg('*', node.name, 'c')
    print("[NeoTree] \"Copied " .. node.name .. " to system clipboard!\"")
  end,
  copy_path = function(state)
    local node = state.tree:get_node()
    local full_path = node.path
    local relative_path = full_path:sub(#state.path + 2)
    vim.fn.setreg('*', relative_path, 'c')
    print("[NeoTree] \"Copied " .. relative_path .. " to system clipboard!\"")
  end,
  copy_absolute_path = function(state)
    local node = state.tree:get_node()
    local full_path = node.path
    vim.fn.setreg('*', full_path, 'c')
    print("[NeoTree] \"Copied " .. full_path .. " to system clipboard!\"")
  end,
  system_open_dir = function(state)
    local node = state.tree:get_node()
    local path = node:get_id()
    -- macOs: open file in default application in the background.
    -- Probably you need to adapt the Linux recipe for manage path with spaces. I don't have a mac to try.
    vim.api.nvim_command("silent !open -g " .. path)
    -- Linux: open file in default application
    -- vim.api.nvim_command(string.format("silent !xdg-open '%s'", path))
    local abspath = node.link_to or node.path
    local full_path = node.path
    local is_folder = node.type == "directory"
    local basedir = is_folder and abspath or vim.fn.fnamemodify(abspath, ":h")
    -- 檢查是否可以找到 explorer.exe
    local explorer_exists = vim.fn.executable('explorer.exe') == 1
    if explorer_exists then
      -- vim.api.nvim_command(string.format("silent !explorer.exe `wslpath -w '%s'`", path))
      vim.api.nvim_command(string.format("silent !explorer.exe `wslpath -w '%s'`", basedir))
    else
      -- 否則，使用 xdg-open 打開文件夾
      vim.api.nvim_command(string.format("silent !xdg-open '%s'", basedir))
    end
  end,
  system_open = function(state)
    local node = state.tree:get_node()
    local path = node:get_id()
    -- macOs: open file in default application in the background.
    -- Probably you need to adapt the Linux recipe for manage path with spaces. I don't have a mac to try.
    vim.api.nvim_command("silent !open -g " .. path)
    -- Linux: open file in default application
    -- vim.api.nvim_command(string.format("silent !xdg-open '%s'", path))
    local explorer_exists = vim.fn.executable('explorer.exe') == 1
    -- 檢查是否可以找到 explorer.exe
    if explorer_exists then
      -- vim.api.nvim_command(string.format("silent !explorer.exe `wslpath -w '%s'`", path))
      vim.api.nvim_command(string.format("silent !explorer.exe `wslpath -w '%s'`", path))
    else
      -- 否則，使用 xdg-open 打開文件夾
      vim.api.nvim_command(string.format("silent !xdg-open '%s'", path))
    end
  end,
}
for k, v in pairs(custom_mappings_plus) do
  if _G[v] ~= nil then
    custom_commands[v] = function(state)
      _G[v](state)
    end
  end
end
for k, v in pairs(custom_mappings_plus) do
  custom_mappings[k] = v
end
local neotree_source = {}
-- 检查 Docker 是否可用的函数
local function is_docker_available()
  -- 使用 'command -v' 来检查 Docker 是否安装
  local handle = io.popen("command -v docker")
  local result = handle:read("*a")
  handle:close()

  return result ~= ""
end

-- 自定义的 netman.providers 版本
local function custom_netman_providers()
  local providers = { "netman.providers.ssh" }

  -- 如果 Docker 可用，添加 Docker 提供者
  if is_docker_available() then
    table.insert(providers, "netman.providers.docker")
  end

  return providers
end

-- 覆盖原始的 netman.providers
package.preload["netman.providers"] = custom_netman_providers

-- 现在，任何后续的 require("netman.providers") 调用都将返回你自定义的内容

neotree_source = {
  "filesystem", -- Neotree filesystem source
  "buffers",
  "git_status",
  "netman.ui.neo-tree", -- The one you really care about 😉
}
neotree.setup({
  sources = neotree_source,
  use_default_mappings = false,
  window = {
    width = 30,
    mappings = custom_mappings,
  },
  commands = custom_commands,
  close_if_last_window = false,
  buffers = {
    follow_current_file = { enable = true },
  },
  filesystem = {
    follow_current_file = { enable = true },
    bind_to_cwd = false,
    hijack_netrw_behavior = "open_current",
    filtered_items = {
      hide_dotfiles = false,
      hide_gitignored = false,
      hide_by_name = {
        ".DS_Store",
        "thumbs.db",
        "node_modules"
      },
      hide_by_pattern = {
        ".*/Andy6/.*/.*home",
        ".*/andy6/.*/.*home",
        string.format(".*/%s/.*/.*home", username),
        -- "*.meta",
        --"*/src/*/tsconfig.json",
      },

      never_show = {
        ".DS_Store",
        "thumbs.db"
      },
    },
  },
})
function open_neo_tree()
  -- open the tree
  -- if vim.g.SessionLoad then return end
  if vim.bo.filetype ~= "alpha" and vim.bo.filetype ~= "lir" and next(vim.fn.argv()) ~= nil then
    vim.cmd('Neotree toggle=true action=show dir=/')
    -- vim.cmd('wincmd w')
  end
end

function session_open_neo_tree()
  vim.cmd('Neotree toggle=true action=show dir=/')
  -- vim.cmd('wincmd w')
end
