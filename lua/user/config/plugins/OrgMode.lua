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



require('orgmode').setup_ts_grammar()
vim.opt.conceallevel = 2
vim.opt.concealcursor = 'nc'
local opt_org_agenda_files = { '~/Dropbox/org/*', '~/my-orgs/**/*', ('%s/Dropbox/org/*'):format(vim.fn.getcwd()) }

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
      target = ('%s/Dropbox/org/notes.org'):format(vim.fn.getcwd())
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
      target = ('%s/Dropbox/org/notes.org'):format(vim.fn.getcwd())
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
      target = ('%s/Dropbox/org/notes.org'):format(vim.fn.getcwd())
    },
    p = {
      description = 'Project',
      template = '* %?\n %u',
      target = '~/Dropbox/org/projects.org'
    },
    P = {
      description = 'Project (WorkSpace)',
      template = '* %?\n %u',
      target = ('%s/Dropbox/org/projects.org'):format(vim.fn.getcwd())
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

  local function setup_keymaps()
    -- unbind default keys
    vim.api.nvim_buf_del_keymap(0, "n", "j")
    vim.api.nvim_buf_del_keymap(0, "n", "k")
    vim.api.nvim_buf_del_keymap(0, "n", "h")
    vim.api.nvim_buf_del_keymap(0, "n", "l")

    -- bind new keys
    vim.api.nvim_buf_set_keymap(0, "n", "e", '<cmd>lua require("orgmode.objects.calendar").read_date()<CR>', {})
    vim.api.nvim_buf_set_keymap(0, "n", "i", '<cmd>lua require("orgmode.objects.calendar").cursor_up()<cr>', {})
    vim.api.nvim_buf_set_keymap(0, "n", "k", '<cmd>lua require("orgmode.objects.calendar").cursor_down()<cr>', {})
    vim.api.nvim_buf_set_keymap(0, "n", "j", '<cmd>lua require("orgmode.objects.calendar").cursor_left()<cr>', {})
    vim.api.nvim_buf_set_keymap(0, "n", "l", '<cmd>lua require("orgmode.objects.calendar").cursor_right()<cr>', {})
  end

  vim.defer_fn(function()
    while attempts < max_attempts do
      local success, err = pcall(setup_keymaps)

      if success then
        return
      else
        attempts = attempts + 1
        print("An error occurred:", err, "- Retrying in 0.5 seconds.")
        vim.defer_fn(setup_keymaps, 500)
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
  local link_pattern = '%[%[file:(.-)%]%[(.-)%]%]'
  local path, label = string.match(line, link_pattern)
  if not path then
    link_pattern = '%[%[file:(.-)%]%[(.-)%]%]'
    path = string.match(line, link_pattern)
  end
  if not path then
    link_pattern = '%[%[file:(.-)%]%]'
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
