lvim.builtin.which_key.setup.plugins.spelling.enabled = false
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
  lvim.builtin.which_key.mappings['e'] = { "<Cmd>NvimTreeToggle<cr>", "NvimTree" }
  lvim.keys.normal_mode["<c-k>"] = "<Cmd>NvimTreeFocus<CR>"
end
lvim.builtin.which_key.mappings.u = lvim.builtin.which_key.mappings.l
lvim.builtin.which_key.mappings.l = nil
lvim.builtin.which_key.mappings.u.o = lvim.builtin.which_key.mappings.u.j
lvim.builtin.which_key.mappings.u.j = nil
lvim.builtin.which_key.mappings.u.k = lvim.builtin.which_key.mappings.u.u
lvim.builtin.which_key.mappings.u.u = nil
lvim.builtin.which_key.mappings.u.a = { "<cmd>Lspsaga code_action<cr>", "Code Action" }


lvim.builtin.which_key.mappings.s.o = lvim.builtin.which_key.mappings.s.r
lvim.builtin.which_key.mappings.s.r = nil
lvim.builtin.which_key.mappings.s.r = { "<cmd>RnvimrToggle<cr>", "Ranger" }

lvim.builtin.which_key.mappings.s.g = lvim.builtin.which_key.mappings.s.t
lvim.builtin.which_key.mappings.s.t = nil

lvim.builtin.which_key.mappings.s.F = { "<cmd>Telescope file_browser<cr>", "File Browser" }
lvim.builtin.which_key.mappings.d['s'] = { "<cmd>Telescope dap configurations<cr>", "Start" }

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
lvim.builtin.which_key.mappings.s['a'] = { "<Cmd>Telescope conda theme=get_ivy<cr>", "Chage Conda Env" }
lvim.builtin.which_key.mappings.s['y'] = { "<Cmd>Telescope yank_history theme=get_ivy<cr>", "Yank History" }
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
lvim.keys.visual_mode['<leader>Oa'] = "zO"
lvim.keys.visual_mode['<leader>Od'] = "zC"
-- lvim.builtin.which_key.mappings['O'] = { "zR", "Folding Code (Open All)" }
-- lvim.builtin.which_key.mappings['Oa'] = { "zM", "Folding Code (Close All)" }
-- lvim.builtin.which_key.mappings['Od'] = { "zR", "Folding Code (Open All)" }
lvim.builtin.which_key.mappings['Oa'] = { '<cmd>lua require("ufo").closeAllFolds()<cr>', "Folding Code (Close All)" }
lvim.builtin.which_key.mappings['Od'] = { '<cmd>lua require("ufo").openAllFolds()<cr>', "Folding Code (Open All)" }
lvim.builtin.which_key.mappings['OX'] = { 'zX', "Clear All Folds" }

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
