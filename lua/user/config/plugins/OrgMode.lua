-- Load custom treesitter grammar for org filetype
local function check_org_notes()
  local home_dir = os.getenv("HOME")
  local current_dir = vim.fn.getcwd()

  local notes_file = ('%s/Dropbox/org/notes.org'):format(vim.fn.getcwd())
  local org_dir = ('%s/Dropbox/org'):format(vim.fn.getcwd())

  -- 检查当前目录是否从第一个字符开始与主目录匹配
  if not (current_dir:sub(1, #home_dir) == home_dir) then
    return
  end
  -- 检查当前目录是否为 Dropbox 或 org 的后缀
  if current_dir:match('.*/Dropbox$') or current_dir:match('.*/org$') then
    return
  end

  -- 使用 command -v 检查 git 命令是否可用
  local git_available = vim.fn.system("command -v git")
  if git_available == "" then
    -- git 不可用，检查当前目录是否有 .git 目录
    if vim.fn.isdirectory(current_dir .. "/.git") == 0 then
      -- 没有 .git 目录，直接返回
      return
    end
    return
  else
    -- 检查当前目录是否为 Git 仓库
    local is_git_repo = vim.fn.system("git rev-parse --is-inside-work-tree"):match("true")
    if is_git_repo then
      return
    end
    -- 非 Git 仓库，卻有 .gitignore 文件，且 Dropbox 被作為排除對象
    -- 檢查 .gitignore 文件是否存在且包含 Dropbox/
    local gitignore_file = current_dir .. "/.gitignore"
    if vim.fn.filereadable(gitignore_file) == 1 then
      local gitignore_content = vim.fn.readfile(gitignore_file)
      for _, line in ipairs(gitignore_content) do
        if line:match("Dropbox/") then
          return
        end
      end
    end
  end

  -- 檢查 notes.org 檔案是否存在
  local notes_exist = vim.fn.filereadable(notes_file) == 1

  if not notes_exist then
    -- 檢查 org 目錄是否存在
    local org_dir_exist = vim.fn.isdirectory(org_dir) == 1

    if not org_dir_exist then
      -- 創建 org 目錄及 notes.org 檔案
      vim.fn.system('mkdir -p ' .. org_dir)
      vim.fn.system('touch ' .. notes_file)
    else
      -- 只創建 notes.org 檔案
      vim.fn.system('touch ' .. notes_file)
    end
  end
end
if next(vim.fn.argv()) == nil then
  vim.api.nvim_create_augroup("check_org_dir_and_note", {})
  vim.api.nvim_create_autocmd({
    "VimEnter"
  }, {
    group = "check_org_dir_and_note",
    callback = function()
      check_org_notes()
    end
  })
end


vim.opt.conceallevel = 2
vim.opt.concealcursor = 'nc'
local opt_org_agenda_files = { '~/Dropbox/org/**/*', '~/my-orgs/**/*', ('%s/orgmode/**/*'):format(vim.fn.getcwd()) }

-- 將 ~ 轉成絕對路徑
local home = os.getenv("HOME") or ""

for i, item in ipairs(opt_org_agenda_files) do
  opt_org_agenda_files[i] = item:gsub("^~", home)
end

-- 将 Lua 表转换为集合，去除重复项
local unique_opt_org_agenda_files = {}
for _, item in ipairs(opt_org_agenda_files) do
  unique_opt_org_agenda_files[item] = true
end
-- 将去重后的集合转换回 Lua 表
opt_org_agenda_files = {}
for item, _ in pairs(unique_opt_org_agenda_files) do
  table.insert(opt_org_agenda_files, item)
end

local utils = require('orgmode.utils')
local link_utils = require('orgmode.org.links.utils')
local original_open_file_and_search = link_utils.open_file_and_search
local external_filetypes = {
  -- pdf is considered a valid filetype even though it cannot be correctly read
  'pdf',
  -- Add common image file types
  'png', 'jpg', 'jpeg', 'gif', 'bmp', 'webp', 'tiff',
}

link_utils.open_file_and_search = function(file_path, search_text)
  if not file_path or file_path == '' then
    return true
  end
  local filetype = vim.filetype.match({ filename = file_path })
  if filetype ~= "org" then
    local editable = true
    if file_path:match("^https?://") or vim.tbl_contains(external_filetypes, filetype) then
      vim.ui.open(file_path)
      editable = false
    end
    -- Return without attempt to find text. File is not editable.
    if not editable then
      return true
    end

    vim.cmd(('edit %s'):format(file_path))
    return true
  end
  return original_open_file_and_search(file_path, search_text)
end

require('orgmode').setup({
  -- org_agenda_files = { '~/Dropbox/org/*', '~/my-orgs/**/*', ('%s/Dropbox/org/*'):format(vim.fn.getcwd()) },
  org_agenda_files = opt_org_agenda_files,
  org_default_notes_file = '~/Dropbox/org/notes.org',
  -- org_default_notes_file = ('%s/Dropbox/org/notes.org'):format(vim.fn.getcwd()),
  -- org_indent_mode = 'noindent',
  org_capture_templates = {
    t = {
      description = 'Task',
      template = '* TODO %?\n %u',
      -- target = '~/Dropbox/org/task.org'
      target = '~/Dropbox/org/notes.org'
    },
    T = {
      description = 'Task (WorkSpace)',
      template = '* TODO %?\n %u',
      -- target = '~/Dropbox/org/task.org'
      target = ('%s/orgmode/notes.org'):format(vim.fn.getcwd())
    },
    j = {
      description = 'Journal',
      template = '\n*** %<%Y-%m-%d> %<%A>\n**** %U\n\n%?',
      -- target = '~/Dropbox/org/journal.org'
      target = '~/Dropbox/org/notes.org'
    },
    J = {
      description = 'Journal (WorkSpace)',
      template = '\n*** %<%Y-%m-%d> %<%A>\n**** %U\n\n%?',
      -- target = '~/Dropbox/org/journal.org'
      target = ('%s/orgmode/notes.org'):format(vim.fn.getcwd())
    },
    n = {
      description = 'Catch',
      template = '* %?\n %u',
      -- target = '~/Dropbox/org/catch.org'
      target = '~/Dropbox/org/notes.org'
    },
    N = {
      description = 'Catch (WorkSpace)',
      template = '* %?\n %u',
      -- target = '~/Dropbox/org/catch.org'
      target = ('%s/orgmode/notes.org'):format(vim.fn.getcwd())
    },
    p = {
      description = 'Project',
      template = '* %?\n %u',
      target = '~/Dropbox/org/projects.org'
    },
    P = {
      description = 'Project (WorkSpace)',
      template = '* %?\n %u',
      target = ('%s/orgmode/projects.org'):format(vim.fn.getcwd())
    }
  },
  org_tags_column = -80,
  mappings = {
    prefix = '<Leader>o',
    global = {
      org_agenda = '<leader>toa',
      org_capture = '<leader>toc'
    },
    org = {
      org_toggle_checkbox = 'gS',
      org_timestamp_up = '<a-d>',        -- Increase date part under cursor (year/month/day/hour/minute/repeater/active|inactive)
      org_timestamp_down = '<a-a>',      -- Decrease date part under cursor (year/month/day/hour/minute/repeater/active|inactive)
      org_timestamp_up_day = '<S-DOWN>', -- Increase date under cursor by 1 day
      org_timestamp_down_day = '<S-UP>', -- Decrease date under cursor by 1 day
      org_move_subtree_up = '<prefix><Up>',
      org_move_subtree_down = '<prefix><Down>',
      org_meta_return = '<prefix>h',
      org_deadline = '<prefix>id',
      org_schedule = '<prefix>is',
      org_insert_link = '<prefix>il',
      org_open_at_point = '<a-o>',
      org_cycle = '<TAB>',
      org_global_cycle = '<S-TAB>',
      -- org_demote_subtree = '>s',
      org_demote_subtree = '<a-}>',
      -- org_promote_subtree = '<s',
      org_promote_subtree = '<a-{>',
      -- org_do_demote = '>>',
      org_do_demote = '<a->>',
      -- org_do_promote = "<<",
      org_do_promote = "<a-<>",
    },
    capture = {
      org_capture_finalize = 'S',
    },
    agenda = {
      -- org_agenda_earlier = 'a',
      org_agenda_earlier = '<',
      -- org_agenda_later = 'd',
      org_agenda_later = '>',
      org_agenda_quit = '<leader>q',
      org_agenda_goto_date = 'cid',
      org_agenda_clock_in = 'U',
      org_agenda_clock_out = 'O',
      org_agenda_clock_cancel = 'C',
    }
  }
})
function modify_calendar_keymaps()
  local max_attempts = 3
  local attempts = 0

  -- Check if all keys are mapped
  local is_all_keys_mapped = true
  local function are_keys_mapped()
    local keys_to_check = { "h", "j", "k", "l", "i" }

    for _, key in ipairs(keys_to_check) do
      local mappings = vim.tbl_filter(function(map)
        return map.lhs == key and map.callback
      end, vim.api.nvim_buf_get_keymap(0, "n"))

      if not mappings then
        is_all_keys_mapped = false
      end
    end

    return is_all_keys_mapped
  end
  local function get_key_mappings()
    local keys = { "h", "j", "k", "l", "i" }
    local mappings = {}

    for _, key in ipairs(keys) do
      -- Use vim.api.nvim_buf_get_keymap to get key mappings for the current buffer
      -- For extracting only mappings with a callback
      local key_mapping = vim.tbl_filter(function(map)
        return map.lhs == key and map.callback
      end, vim.api.nvim_buf_get_keymap(0, "n"))

      -- Extract the first callback, or nil if no mappings or no callback
      if #key_mapping > 0 then
        mappings[key] = key_mapping[1].callback
      else
        mappings[key] = nil
      end
    end

    return mappings
  end

  -- 設置鍵位映射
  local function setup_keymaps()
    -- Get function of default key mappings for calendar
    local mappings = get_key_mappings()
    -- unbind default keys
    -- for calendar read_data (i), cursor_up (k), ..._down (j), ..._left (h) and ..._right (l)
    --     ^
    --     k
    -- < h   l >
    --     j
    --     v
    vim.api.nvim_buf_del_keymap(0, "n", "h")
    vim.api.nvim_buf_del_keymap(0, "n", "j")
    vim.api.nvim_buf_del_keymap(0, "n", "k")
    vim.api.nvim_buf_del_keymap(0, "n", "l")
    vim.api.nvim_buf_del_keymap(0, "n", "i")

    -- bind new keys for calendar read_data (e), cursor_up (i), ..._down (k), ..._left (j) and ..._right (l)
    --     ^
    --     i
    -- < j   l >
    --     k
    --     v
    vim.api.nvim_buf_set_keymap(0, "n", "e", "", { callback = mappings["i"], noremap = true, silent = true })
    vim.api.nvim_buf_set_keymap(0, 'n', 'i', "", { callback = mappings["k"], noremap = true, silent = true })
    vim.api.nvim_buf_set_keymap(0, 'n', 'k', "", { callback = mappings["j"], noremap = true, silent = true })
    vim.api.nvim_buf_set_keymap(0, 'n', 'j', "", { callback = mappings["h"], noremap = true, silent = true })
    vim.api.nvim_buf_set_keymap(0, 'n', 'l', "", { callback = mappings["l"], noremap = true, silent = true })
    print("Keymaps successfully set up!")
  end

  vim.defer_fn(function()
    -- 1. Try to extract function of key mappings for the current buffer of calendar
    --  - Will retry 500ms later if not all keys are mapped
    -- 2. And then set up new key mappings, unbinding the default keys
    while attempts < max_attempts do
      if are_keys_mapped() then
        print("All calendar default keymaps are mapped, setting up custom keymaps...")
        setup_keymaps()
        return
      else
        print("Some Calendar keymaps are not set up. Retrying... (Attempt " ..
          (attempts + 1) .. " of " .. max_attempts .. ")")
        attempts = attempts + 1
        vim.defer_fn(function() end, 500)
      end
    end
    print("Failed to modify keymaps after " .. max_attempts .. " attempts.")
  end, 0)
end

vim.api.nvim_create_augroup("org_calendar_custom", {})
vim.api.nvim_create_autocmd({
  "BufWinEnter"
}, {
  pattern = { "orgcalendar" },
  group = "org_calendar_custom",
  callback = function()
    modify_calendar_keymaps()
  end
})
function create_directory(path)
  -- 检查目录是否存在，如果不存在则创建它
  if vim.fn.isdirectory(path) == 0 then
    vim.fn.mkdir(path, "p")
  end
end

function goto_OrgFile(filename)
  local org_dir = vim.fn.expand("~/Dropbox/org/")
  create_directory(org_dir)
  local file_full_path = org_dir .. filename
  local buf_nr = vim.fn.bufnr(file_full_path)
  if buf_nr ~= -1 and vim.api.nvim_buf_is_loaded(buf_nr) then
    -- if buffer is already loaded, go to the end of the file
    vim.cmd("silent! e " .. file_full_path)
  else
    -- otherwise, open the file and go to the end of the file
    vim.cmd("silent! e " .. file_full_path .. " | $")
    -- vim.cmd("normal! G")
  end
end

function goto_WorkSpaceOrgFile(filename)
  local org_dir = ('%s/Dropbox/org/'):format(vim.fn.getcwd())
  create_directory(org_dir)
  local file_full_path = org_dir .. filename
  local buf_nr = vim.fn.bufnr(file_full_path)
  if buf_nr ~= -1 and vim.api.nvim_buf_is_loaded(buf_nr) then
    -- if buffer is already loaded, go to the end of the file
    vim.cmd("silent! e " .. file_full_path)
  else
    -- otherwise, open the file and go to the end of the file
    vim.cmd("silent! e " .. file_full_path .. " | $")
    -- vim.cmd("normal! G")
  end
end

lvim.keys.normal_mode['<leader>ro'] = "<cmd>lua goto_OrgFile 'notes.org'<cr>"
lvim.keys.normal_mode['<leader>rO'] = "<cmd>lua goto_WorkSpaceOrgFile 'notes.org'<cr>"
lvim.keys.normal_mode['<leader>rp'] = "<cmd>lua goto_OrgFile 'projects.org'<cr>"
lvim.keys.normal_mode['<leader>rP'] = "<cmd>lua goto_WorkSpaceOrgFile 'projects.org'<cr>"

function OpenFileLink()
  local line = vim.fn.getline('.')
  local link_pattern = '%[%[file:%s*(.-)%]%[(.-)%]%]'
  local path, label = string.match(line, link_pattern)
  if not path then
    link_pattern = '%[%[file:%s*(.-)%]%[(.-)%]%]'
    path = string.match(line, link_pattern)
  end
  if not path then
    link_pattern = '%[%[file:%s*(.-)%]%]'
    path = string.match(line, link_pattern)
  end
  if not path then
    return
  end
  if vim.fn.executable("explorer.exe") == 1 then
    local command = string.format("silent !explorer.exe `wslpath -w '%s'`", path)
    vim.api.nvim_command(command)
  else
    local command = string.format("silent !xdg-open '%s'", path)
    vim.api.nvim_command(command)
  end
end

vim.api.nvim_create_augroup("org_file_custom", {})
vim.api.nvim_create_autocmd({
  "BufWinEnter"
}, {
  pattern = "*.org",
  group = "org_file_custom",
  callback = function()
    vim.keymap.set('n', '<leader><a-o>', '<cmd>lua OpenFileLink()<cr>', { silent = true, buffer = true })
    vim.cmd('noremap <silent> <buffer> <leader>o <Nop>')
    vim.keymap.set('n', '<leader>oo', '<cmd>silent! norm!za<cr>', { silent = true, buffer = true })
  end
})
vim.api.nvim_create_augroup("orgagenda_custom", {})
vim.api.nvim_create_autocmd({
  "FileType"
}, {
  pattern = { "orgagenda" },
  group = "orgagenda_custom",
  callback = function()
    vim.cmd('noremap <silent> <buffer> <leader>o <Nop>')
  end
})
