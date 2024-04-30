lvim.builtin.which_key.setup.plugins.spelling.enabled = false
last_nvimtree_side = 'left'
lvim.builtin.breadcrumbs.winbar_filetype_exclude[#lvim.builtin.breadcrumbs.winbar_filetype_exclude + 1] = "NvimTreeRight"

function CustomNvimTreeToggle()
  local dapui_scope_found = false
  local current_side = lvim.builtin.nvimtree.setup.view.side

  for _, win_nr in ipairs({ 1, 2 }) do
    local buf_nr = vim.fn.winbufnr(win_nr)
    if buf_nr ~= -1 then
      local ft = vim.api.nvim_buf_get_option(buf_nr, "filetype")
      if ft == "dapui_scopes" or ft == "dbui" then
        dapui_scope_found = true
        break
      end
    end
  end

  local new_side = dapui_scope_found and "right" or "left"
  if current_side ~= new_side then
    lvim.builtin.nvimtree.setup.view.side = new_side
    require("nvim-tree").setup(lvim.builtin.nvimtree.setup)
    last_nvimtree_side = new_side
  end

  vim.cmd('NvimTreeToggle')
  -- 延迟执行，确保 NvimTree 完全加载
  vim.defer_fn(function()
    -- 获取当前窗口的 Buffer 编号
    local bufnr = vim.api.nvim_get_current_buf()
    -- 获取当前 Buffer 的文件类型
    local filetype = vim.api.nvim_buf_get_option(bufnr, "filetype")

    -- 检查是否为 NvimTree，如果是且在右侧，则尝试更改为 NvimTreeRight
    if filetype == "NvimTree" and lvim.builtin.nvimtree.setup.view.side == "right" then
      -- 这里尝试设置文件类型为 NvimTreeRight
      -- 请注意，直接更改 filetype 可能不是一个安全的操作，这里仅作示例
      vim.api.nvim_buf_set_option(bufnr, "filetype", "NvimTreeRight")
    end
  end, 100) -- 100毫秒的延迟，这个值可能需要根据实际情况调整
end

local keys_to_remove
if lvim.builtin.nvimtree.active == false then
  keys_to_remove = { "w", "f", "h", "e" }
else
  keys_to_remove = { "w", "f", "h" }
end
for _, key in ipairs(keys_to_remove) do
  for k, mapping in pairs(lvim.builtin.which_key.mappings) do
    if k == key then
      lvim.builtin.which_key.mappings[k] = nil
    end
  end
end
if lvim.builtin.nvimtree.active == false then
  lvim.builtin.which_key.mappings['e'] = { "<Cmd>Neotree toggle=true dir=/<cr>", "Neotree" }
  lvim.builtin.which_key.mappings.b['e'] = { "<Cmd>Neotree buffers toggle=true dir=/<cr>", "Neotree buffers" }
else
  -- lvim.builtin.which_key.mappings['e'] = { "<Cmd>lua require('nvim-tree.api').tree.toggle(false, false)<cr>", "NvimTree" }
  -- lvim.builtin.which_key.mappings['e'] = { "<Cmd>NvimTreeToggle<cr>", "NvimTree" }
  lvim.builtin.which_key.mappings["e"] = { "<cmd>lua CustomNvimTreeToggle()<cr>", "NvimTree" }
  lvim.keys.normal_mode["<c-k>"] = "<Cmd>NvimTreeFocus<CR>"
end
lvim.builtin.which_key.mappings.u = lvim.builtin.which_key.mappings.l
lvim.builtin.which_key.mappings.l = nil
lvim.builtin.which_key.mappings.u.o = lvim.builtin.which_key.mappings.u.j
lvim.builtin.which_key.mappings.u.j = nil
lvim.builtin.which_key.mappings.u.k = lvim.builtin.which_key.mappings.u.u
lvim.builtin.which_key.mappings.u.u = nil
lvim.builtin.which_key.mappings.u.a = { "<cmd>Lspsaga code_action<cr>", "Code Action" }
lvim.builtin.which_key.mappings.u.A = { "<cmd>lua require('lspimport').import()<cr>", "LSP Import Action" }

lvim.builtin.which_key.vmappings.u = lvim.builtin.which_key.vmappings.l
lvim.builtin.which_key.vmappings.l = nil
lvim.builtin.which_key.vmappings.u.a = { "<cmd>Lspsaga code_action<cr>", "Code Action" }

function CopilotChatQuickchat()
  local input = vim.fn.input("Quick Chat: ")
  if input ~= "" then
    require("CopilotChat").ask(input, { selection = require("CopilotChat.select").buffer })
  end
end

function CopilotChatPromptAction()
  local actions = require("CopilotChat.actions")
  require("CopilotChat.integrations.telescope").pick(actions.prompt_actions())
end

lvim.builtin.which_key.mappings.u['ki'] = { "<cmd>lua CopilotChatQuickchat()<cr>", "CopilotChat - Quick chat" }
lvim.builtin.which_key.mappings.u['kk'] = { "<cmd>lua CopilotChatPromptAction()<cr>", "CopilotChat Prompt Action" }
lvim.builtin.which_key.vmappings.u['kk'] = { "<cmd>lua CopilotChatPromptAction()<cr>", "CopilotChat Prompt Action" }

lvim.builtin.which_key.mappings.U = lvim.builtin.which_key.mappings.L
lvim.builtin.which_key.mappings.L = nil

lvim.builtin.which_key.mappings.s.o = lvim.builtin.which_key.mappings.s.r
lvim.builtin.which_key.mappings.s.r = nil
-- lvim.builtin.which_key.mappings.s.r = { "<cmd>RnvimrToggle<cr>", "Ranger" }
lvim.builtin.which_key.mappings.s.r = { "<cmd>Telescope file_browser path=%:p:h initial_mode=normal grouped=true<cr>",
  "file_browser (%:p:h)" }

lvim.builtin.which_key.mappings.s.g = lvim.builtin.which_key.mappings.s.t
lvim.builtin.which_key.mappings.s.t = nil

lvim.builtin.which_key.mappings.s.F = { "<cmd>Telescope file_browser<cr>", "File Browser" }
lvim.builtin.which_key.mappings.d['s'] = { "<cmd>Telescope dap configurations<cr>", "Start" }

lvim.builtin.which_key.mappings["dm"] = { "<cmd>lua require('neotest').run.run()<cr>",
  "Test Method" }
lvim.builtin.which_key.mappings["dM"] = { "<cmd>lua require('neotest').run.run({strategy = 'dap'})<cr>",
  "Test Method DAP" }
lvim.builtin.which_key.mappings["d,"] = {
  "<cmd>lua require('neotest').run.run({vim.fn.expand('%')})<cr>", "Test Class" }
lvim.builtin.which_key.mappings["d."] = {
  "<cmd>lua require('neotest').run.run({vim.fn.expand('%'), strategy = 'dap'})<cr>", "Test Class DAP" }
lvim.builtin.which_key.mappings["dS"] = { "<cmd>lua require('neotest').summary.toggle()<cr>", "Test Summary" }

lvim.builtin.which_key.mappings.T['T'] = { "<Cmd>TodoTelescope theme=get_ivy<cr>", "ToDo Telescope" }
lvim.builtin.which_key.mappings.T['w'] = { "<Cmd>TodoTrouble<cr>", "ToDo TodoTrouble (all buffers)" }

lvim.builtin.which_key.mappings['tgh'] = { "<Cmd>lua require('hoversplit').split_remain_focused()<cr>",
  "split_remain_focused" }

function TodoTrubleCurrentFile()
  local command = "TodoTrouble cwd=" .. vim.fn.expand("%:p")
  vim.api.nvim_command(command)
end

lvim.builtin.which_key.mappings.T['d'] = { "<Cmd>lua TodoTrubleCurrentFile()<cr>", "ToDo TodoTrouble (current buffers)" }

lvim.builtin.which_key.mappings['t1'] = { "<cmd>tabn 1<CR>", "tabn 1" }
lvim.builtin.which_key.mappings['t2'] = { "<cmd>tabn 2<CR>", "tabn 2" }
lvim.builtin.which_key.mappings['t3'] = { "<cmd>tabn 3<CR>", "tabn 3" }
lvim.builtin.which_key.mappings['t4'] = { "<cmd>tabn 4<CR>", "tabn 4" }
lvim.builtin.which_key.mappings['t5'] = { "<cmd>tabn 5<CR>", "tabn 5" }
lvim.builtin.which_key.mappings['t6'] = { "<cmd>tabn 6<CR>", "tabn 6" }
lvim.builtin.which_key.mappings['t7'] = { "<cmd>tabn 7<CR>", "tabn 7" }
lvim.builtin.which_key.mappings['t8'] = { "<cmd>tabn 8<CR>", "tabn 8" }
lvim.builtin.which_key.mappings['t9'] = { "<cmd>tabn 9<CR>", "tabn 9" }
lvim.builtin.which_key.mappings['t0'] = { "<cmd>tablast<CR>", "tablast" }
lvim.builtin.which_key.mappings['t-'] = { "g<tab>", "back last tab" }

lvim.builtin.which_key.mappings["t'"] = { "<cmd>tab split<CR>", "tabn split" }
lvim.builtin.which_key.mappings['t/'] = { "<cmd>tabn 1<CR>", "tabn 1" }
lvim.builtin.which_key.mappings['t,'] = { "<cmd>tabprevious<CR>", "tabprevious" }
lvim.builtin.which_key.mappings['t.'] = { "<cmd>tabnext<CR>", "tabnext" }
lvim.builtin.which_key.mappings['t\\'] = { "<cmd>tabclose<CR>", "tabblose" }

lvim.builtin.which_key.mappings.s['d'] = { "<Cmd>Telescope cder theme=get_ivy<cr>", "Chage Folder" }
lvim.builtin.which_key.mappings.s['a'] = { "<Cmd>lua require('swenv.api').pick_venv()<cr>", "Chage Python Env" }
lvim.builtin.which_key.mappings.s['y'] = { "<Cmd>Telescope neoclip theme=get_ivy<cr>", "Yank History" }
lvim.builtin.which_key.mappings.s['O'] = { "<Cmd>Telescope orgmode search_headings<cr>",
  "orgmode search_headings" }


lvim.builtin.which_key.mappings.d['ft'] = { "<cmd>diffthis<cr>", "diffthis" }
lvim.builtin.which_key.mappings.d['fw'] = { "<cmd>diffoff<cr>", "diffoff" }
lvim.builtin.which_key.mappings.d['fW'] = { "<cmd>diffoff!<cr>", "diffoff!" }
lvim.builtin.which_key.mappings.d['fs'] = { "<cmd>set scrollbind!<cr>", "wind_scrollsync (set scrollbind!)" }
lvim.builtin.which_key.mappings.d['fe'] = { "<cmd>windo set noscrollbind<cr>",
  "wind_scrollsync_all_not (windo set noscrollbind)" }


-- lvim.builtin.which_key.mappings['B'] = { "<Cmd>Telescope bookmarks<cr>", "Bookmarks" }


-- <leader>o
lvim.builtin.which_key.mappings['o'] = { "za", "Folding Code (Toggle)" }
lvim.keys.visual_mode['<leader>o'] = "zA<ESC>"
lvim.keys.visual_mode['<leader>Oa'] = "zC"
lvim.keys.visual_mode['<leader>Od'] = "zO"
-- lvim.builtin.which_key.mappings['O'] = { "zR", "Folding Code (Open All)" }
-- lvim.builtin.which_key.mappings['Oa'] = { "zM", "Folding Code (Close All)" }
-- lvim.builtin.which_key.mappings['Od'] = { "zR", "Folding Code (Open All)" }
lvim.builtin.which_key.mappings['Oa'] = { '<cmd>lua require("ufo").closeAllFolds()<cr>', "Folding Code (Close All)" }
lvim.builtin.which_key.mappings['Od'] = { '<cmd>lua require("ufo").openAllFolds()<cr>', "Folding Code (Open All)" }
lvim.builtin.which_key.mappings['Ox'] = { 'zx', "Update All Folds" }

-- lvim.keys.visual_mode['<leader>o'] = "za"
-- lvim.keys.visual_mode['<leader>Oa'] = "zc"
-- lvim.keys.visual_mode['<leader>Od'] = "zo"

-- vim.g.move_auto_indent   = 0
-- vim.g.move_normal_option = 1
-- vim.g.move_key_modifier  = 'C'
-- -- vim.g.move_key_modifier_visualmode = 'S'

vim.cmd([[
augroup netrw_mapping
    autocmd!
    autocmd filetype netrw call NetrwMapping()
augroup END
function! NetrwMapping()
    noremap <buffer> i k
    noremap <buffer> I 5k
    noremap <buffer> l <Plug>NetrwLocalBrowseCheck
endfunction
]])

-- lvim.builtin.which_key.mappings['E'] = { "<cmd>Explore<cr>", "Explore" }
lvim.builtin.which_key.mappings['E'] = { "<cmd>Neotree toggle remote<cr>", "Neotree remote" }

-- buffer clear (clear not in windows buffer)
lvim.builtin.which_key.mappings.b['c'] = { "<cmd>BDelete hidden<cr>", "close hidden buffer (not in windws)" }

-- NOTE: neogen for write program document
lvim.builtin.which_key.mappings.u.o = { "<cmd>Neogen<cr>", "Document Generate" }
