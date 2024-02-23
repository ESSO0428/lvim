local actions = require("lvim.utils.modules").require_on_exported_call "telescope.actions"
local action_layout = require("lvim.utils.modules").require_on_exported_call "telescope.actions.layout"
lvim.builtin.telescope.defaults.layout_config.scroll_speed = 1
lvim.builtin.telescope.defaults.path_display = { "truncate" }
lvim.builtin.telescope.on_config_done = function(telescope)
  pcall(telescope.load_extension, "notify")
  pcall(telescope.load_extension, "orgmode")
  pcall(telescope.load_extension, "command_palette")
  pcall(telescope.load_extension, "telescope-tabs")
  pcall(telescope.load_extension, "live_grep_args")
  pcall(telescope.load_extension, "file_browser")
  pcall(telescope.load_extension, "media_files")
  pcall(telescope.load_extension, "cder")
  pcall(telescope.load_extension, "dap")
  pcall(telescope.load_extension, "howdoi")
  pcall(telescope.load_extension, "neoclip")
  pcall(telescope.load_extension, "harpoon")
  pcall(telescope.load_extension, "bookmarks")
  -- any other extensions loading
end
lvim.builtin.which_key.mappings.s.n = { "<cmd>Telescope notify<cr>", "notify (Viewing History)" }
lvim.builtin.telescope.defaults.mappings.n = {
  ["k"] = actions.move_selection_next,
  ["i"] = actions.move_selection_previous,
  ["<C-q>"] = function(...)
    actions.smart_send_to_qflist(...)
    actions.open_qflist(...)
  end,
  ['<c-k>'] = function(...)
  end,
  ["<C-j>"] = function(...)
    actions.toggle_selection(...)
    actions.move_selection_better(...)
  end,
  ["<C-l>"] = function(...)
    actions.toggle_selection(...)
    actions.move_selection_worse(...)
  end,
  ['<a-t>'] = actions.select_tab,
  ['<a-m>'] = actions.select_tab,
  ['<a-l>'] = actions.select_vertical,
  ['<a-k>'] = actions.select_horizontal,
  ['<a-d>'] = action_layout.toggle_preview,
  ['<c-p>'] = action_layout.cycle_layout_next
}
-- NOTE: 自訂 Telescope 在 nvim-tree 中的 insert 模式下的 <CR> 行為。
--       由於 im-select 插件在退出插入模式時可能導致 Telescope 無法正確跳轉到指定窗口並產生錯誤，
--       這裡通過先發送 <Esc> 退出插入模式，然後經過 200~300 毫秒的延遲後再發送 <CR>，
--       以規避 im-select 的干擾，確保 Telescope 能夠正確處理文件跳轉。
lvim.builtin.telescope.defaults.mappings.i = {
  -- ['<CR>'] = function()
  --   vim.api.nvim_input('<Esc>')
  --   vim.defer_fn(function()
  --     vim.api.nvim_input('<CR>')
  --   end, 100)
  -- end,
  ['<C-q>'] = function(...)
    actions.smart_send_to_qflist(...)
    actions.open_qflist(...)
  end,
  ['<c-k>'] = function(...)
  end,
  ["<C-j>"] = function(...)
    actions.toggle_selection(...)
    actions.move_selection_better(...)
  end,
  ["<C-l>"] = function(...)
    actions.toggle_selection(...)
    actions.move_selection_worse(...)
  end,
  ['<a-t>'] = actions.select_tab,
  ['<a-m>'] = actions.select_tab,
  ['<a-l>'] = actions.select_vertical,
  ['<a-k>'] = actions.select_horizontal,
  ['<a-d>'] = action_layout.toggle_preview,
  ['<c-p>'] = action_layout.cycle_layout_next
}
-- lvim.builtin.telescope.pickers.buffers.mappings.i = {
--   ["<CR>"] = actions.select_default,
--   ["<C-d>"] = actions.delete_buffer
-- }

function telescope_find_files(_)
  require("lvim.core.nvimtree").start_telescope "find_files"
end

function neotree_telescope_find_file(state)
  local node = state.tree:get_node()
  local abspath = node.link_to or node.path
  -- local abspath = node.path
  local is_folder = node.type == "directory"
  local basedir = is_folder and abspath or vim.fn.fnamemodify(abspath, ":h")
  -- local basedir = abspath
  require("telescope.builtin")['find_files'] {
    cwd = basedir,
  }
end

function telescope_live_grep(_)
  require("lvim.core.nvimtree").start_telescope "live_grep"
end

function neotree_telescope_live_grep(state)
  local node = state.tree:get_node()
  local abspath = node.link_to or node.path
  -- local abspath = node.path
  local is_folder = node.type == "directory"
  local basedir = is_folder and abspath or vim.fn.fnamemodify(abspath, ":h")
  -- local basedir = abspath
  require("telescope.builtin")['live_grep'] {
    cwd = basedir,
  }
end

local lvim_core_telescope = require("lvim.core.telescope")
function lvim_core_telescope.start_telescope_extension(telescope_mode, state)
  local abspath
  local is_folder
  local success, node = pcall(function()
    return state.tree:get_node()
  end)
  if success then
    abspath = node.link_to or node.path
    is_folder = node.type == "directory"
  else
    node = require("nvim-tree.lib").get_node_at_cursor()
    abspath = node.link_to or node.absolute_path
    is_folder = node.open ~= nil
  end
  local basedir = is_folder and abspath or vim.fn.fnamemodify(abspath, ":h")
  if telescope_mode == "file_browser" then
    vim.cmd("Telescope " .. telescope_mode .. " path=" .. basedir)
  elseif telescope_mode == "live_grep_args" then
    vim.cmd("Telescope " .. telescope_mode .. " search_dirs=" .. basedir)
  else
    vim.cmd("Telescope " .. telescope_mode .. " cwd=" .. basedir)
  end
end

function telescope_media_files(...)
  local args = { ... }
  local state = nil
  if select("#", ...) > 0 then
    state = args[1]
  end
  lvim_core_telescope.start_telescope_extension("media_files", state)
end

function telescope_file_browser(...)
  local args = { ... }
  local state = nil
  if select("#", ...) > 0 then
    state = args[1]
  end
  lvim_core_telescope.start_telescope_extension("file_browser", state)
end

function telescope_live_grep_args(...)
  local args = { ... }
  local state = nil
  if select("#", ...) > 0 then
    state = args[1]
  end
  lvim_core_telescope.start_telescope_extension("live_grep_args", state)
end

lvim.builtin.telescope.extensions.command_palette = {
  { "File",
    { "entire selection (C-a)",  ':call feedkeys("GVgg")' },
    { "save current file (C-s)", ':w' },
    { "save all files (C-A-s)",  ':wa' },
    { "quit (C-q)",              ':qa' },
    { "file browser (C-i)",      ":lua require'telescope'.extensions.file_browser.file_browser()", 1 },
    { "search word (A-w)",       ":lua require('telescope.builtin').live_grep()",                  1 },
    { "git files (A-f)",         ":lua require('telescope.builtin').git_files()",                  1 },
    { "files (C-f)",             ":lua require('telescope.builtin').find_files()",                 1 },
  },
  { "Help",
    { "tips",            ":help tips" },
    { "cheatsheet",      ":help index" },
    { "tutorial",        ":help tutor" },
    { "summary",         ":help summary" },
    { "quick reference", ":help quickref" },
    { "search help(F1)", ":lua require('telescope.builtin').help_tags()", 1 },
  },
  { "Vim",
    { "reload vimrc",              ":source $MYVIMRC" },
    { 'check health',              ":checkhealth" },
    { "jumps (Alt-j)",             ":lua require('telescope.builtin').jumplist()" },
    { "commands",                  ":lua require('telescope.builtin').commands()" },
    { "command history",           ":lua require('telescope.builtin').command_history()" },
    { "registers (A-e)",           ":lua require('telescope.builtin').registers()" },
    { "colorshceme",               ":lua require('telescope.builtin').colorscheme()",    1 },
    { "vim options",               ":lua require('telescope.builtin').vim_options()" },
    { "keymaps",                   ":lua require('telescope.builtin').keymaps()" },
    { "buffers",                   ":Telescope buffers" },
    { "search history (C-h)",      ":lua require('telescope.builtin').search_history()" },
    { "paste mode",                ':set paste!' },
    { 'cursor line',               ':set cursorline!' },
    { 'cursor column',             ':set cursorcolumn!' },
    { "spell checker",             ':set spell!' },
    { "relative number",           ':set relativenumber!' },
    { "search highlighting (F12)", ':set hlsearch!' },
  },
  { "Session",
    { "Save Session (Current Directory)", ":SessionManager save_current_session" },
    { "Load Session",                     ":SessionManager load_session" },
    { "Load_Session (Current Directory)", ":SessionManager load_current_dir_session" },
    { "Delete Session",                   ":SessionManager delete_session" },
  },
  { "Buffer",
    { "Buffer All Complete (Toggle)",          ":lua BufferAllCompleteToggle()" },
    { "Current Tab Windows Complete (Toggle)", ":lua CurrentTabCompleteToggle()" },
    { "Clear All Buffers",                     ":silent! bufdo BufferKill" }
  },
  { "OrgMode",
    { "go to OrgWorkSpace", ":e /root/Dropbox/org/" }
  },
  { "REPL",
    { "Open QtConsole", ":RunQtConsole" }
  },
  {
    "Clipboard",
    { "Change Clipboard (Osc52)",        ":SetClipboardOsc52" },
    { "Change Clipboard (WslClipboard)", ":SetClipboardWsl" }
  }
}
if lvim.builtin.bufferline.options.groups then
  local function get_group_names()
    local group_names = {}
    for _, group in ipairs(lvim.builtin.bufferline.options.groups.items) do
      if group.name then
        local name = group.name
        if string.find(name, "/") then
          name = string.gsub(name, "/", "_")
        end
        local group_toggle = string.format(":BufferLineGroupToggle %s", name)
        local group_name = string.format("BufferLineGroupToggle (%s)", group.name)
        table.insert(group_names, { group_name, group_toggle })
      end
    end
    return group_names
  end

  local group_names = get_group_names()
  local buffer_option = nil
  for _, option in ipairs(lvim.builtin.telescope.extensions.command_palette) do
    if option[1] == "Buffer" then
      buffer_option = option
      break
    end
  end

  -- 附加 table_plus 到 Buffer 選項的最後
  for _, item in ipairs(group_names) do
    table.insert(buffer_option, item)
  end
end

lvim.keys.normal_mode['<c-p>'] = "<cmd>Telescope command_palette<cr>"

local lga_actions = require("telescope-live-grep-args.actions")
lvim.builtin.telescope.extensions.live_grep_args = {
  auto_quoting = true, -- enable/disable auto-quoting
  -- define mappings, e.g.
  mappings = {         -- extend mappings
    ["i"] = {
      ["<M-u>"] = lga_actions.quote_prompt({ postfix = ' -t' }),
      ["<M-o>"] = lga_actions.quote_prompt({ postfix = " --iglob " }),
    },
  },
  -- ... also accepts theme settings, for example:
  -- theme = "dropdown", -- use dropdown theme
  -- theme = { }, -- use own theme spec
  -- layout_config = { mirror=true }, -- mirror preview pane
}


local fb_actions                               = require "telescope".extensions.file_browser.actions
lvim.builtin.telescope.extensions.file_browser = {
  mappings = {
    ["i"] = {
      -- remap to going to home directory
      ["<C-w>"] = actions.move_selection_previous,
      ["<C-s>"] = actions.move_selection_next,
      ["<a-a>"] = fb_actions.create,
      ["<a-r>"] = false,
      ["<c-j>"] = fb_actions.goto_cwd,
      ["<c-l>"] = fb_actions.change_cwd,
      ["<c-r>"] = fb_actions.toggle_all,
      ["<c-x>"] = fb_actions.move,
      ["<a-c>"] = fb_actions.rename
    }
  }
}
lvim.builtin.telescope.extensions.cder         = {
  dir_command = { 'fd', '--type=d', '.', os.getenv('HOME') },
  previewer_command =
      'exa ' ..
      '-a ' ..
      '--color=always ' ..
      '-T ' ..
      '--level=3 ' ..
      '--icons ' ..
      '--git-ignore ' ..
      '--long ' ..
      '--no-permissions ' ..
      '--no-user ' ..
      '--no-filesize ' ..
      '--git ' ..
      '--ignore-glob=.git',
}
lvim.builtin.telescope.extensions.howdoi       = vim.tbl_deep_extend(
  'force',
  { num_answers = 5 },
  require('telescope.themes').get_ivy()
)
vim.cmd('cnoreabbrev howdo Telescope howdoi')

-- lvim.keys.normal_mode['<a-b>'] = { "<Cmd>Telescope buffers<cr>" }
lvim.builtin.which_key.mappings.s.s    = { "<cmd>Telescope buffers<cr>", "Find" }
lvim.builtin.which_key.mappings.s['`'] = { "<cmd>Telescope marks<cr>", "Marks" }
lvim.builtin.which_key.mappings.s.j    = { "<cmd>Telescope jumplist<cr>", "jumplist" }
lvim.builtin.which_key.mappings.s.G    = { "<cmd>Telescope live_grep_args<cr>", "Live_grep_args" }
lvim.builtin.which_key.mappings.s.u    = { "<cmd>Telescope telescope-tabs list_tabs<cr>", "Search Tabs" }

lvim.builtin.which_key.mappings.s.l    = { "<cmd>Telescope harpoon marks<cr>", "Search harpoon marks" }
lvim.keys.normal_mode["="]             = "<cmd>Telescope harpoon marks<cr>"
lvim.keys.normal_mode["mf"]            = "<cmd>lua require('harpoon.mark').add_file()<cr>"
lvim.keys.normal_mode["mw"]            = "<cmd>lua require('harpoon.ui').toggle_quick_menu()<cr>"
lvim.keys.normal_mode["_"]             = "<cmd>lua require('harpoon.ui').nav_prev()<cr>"
lvim.keys.normal_mode["+"]             = "<cmd>lua require('harpoon.ui').nav_next()<cr>"


lvim.builtin.which_key.mappings.b["["]              = { "<cmd>BufferLineCloseLeft<cr>", "Close all to the left" }
lvim.builtin.which_key.mappings.b["]"]              = { "<cmd>BufferLineCloseRight<cr>", "Close all to the Right" }
-- lvim.keys.normal_mode["<c-p>"] = ':lua require("lvim.core.telescope.custom-finders").find_project_files { previewer = true }<CR>'

-- install chafa for img preview
lvim.builtin.which_key.mappings.s["m"]              = {
  "<cmd>lua require('telescope').extensions.media_files.media_files()<cr>",
  "Find Image" }
lvim.builtin.telescope.defaults.mappings.i["<c-u>"] = actions.preview_scrolling_up
lvim.builtin.telescope.defaults.mappings.i["<c-o>"] = actions.preview_scrolling_down
lvim.builtin.telescope.defaults.mappings.n["<c-u>"] = actions.preview_scrolling_up
lvim.builtin.telescope.defaults.mappings.n["<c-o>"] = actions.preview_scrolling_down
lvim.builtin.telescope.defaults.mappings.i["<c-s>"] = actions.move_selection_next
lvim.builtin.telescope.defaults.mappings.i["<c-w>"] = actions.move_selection_previous
lvim.builtin.telescope.defaults.mappings.n["<c-s>"] = actions.move_selection_next
lvim.builtin.telescope.defaults.mappings.n["<c-w>"] = actions.move_selection_previous


-- source : https://github.com/nvim-telescope/telescope.nvim/issues/623#issuecomment-792233601
local previewers = require('telescope.previewers')
local previewers_utils = require('telescope.previewers.utils')

local max_size = 500000
local truncate_large_files = function(filepath, bufnr, opts)
  opts = opts or {}

  filepath = vim.fn.expand(filepath)
  vim.loop.fs_stat(filepath, function(_, stat)
    if not stat then return end
    if stat.size > max_size then
      local cmd = { "head", "-c", max_size, filepath }
      previewers_utils.job_maker(cmd, bufnr, opts)
    else
      previewers.buffer_previewer_maker(filepath, bufnr, opts)
    end
  end)
end
lvim.builtin.telescope.defaults.buffer_previewer_maker = truncate_large_files
