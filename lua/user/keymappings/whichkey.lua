lvim.builtin.which_key.setup.plugins.spelling.enabled = false
lvim.builtin.breadcrumbs.winbar_filetype_exclude[#lvim.builtin.breadcrumbs.winbar_filetype_exclude + 1] = "NvimTreeRight"

function FileTreeToggleCore(current_side, new_side)
  if current_side ~= new_side then
    if lvim.builtin.nvimtree.active then
      lvim.builtin.nvimtree.setup.view.side = new_side
      require("nvim-tree").setup(lvim.builtin.nvimtree.setup)
    end
  end
  if lvim.builtin.nvimtree.active then
    vim.cmd("NvimTreeFindFileToggle")
  else
    vim.cmd("Neotree toggle reveal_force_cwd")
  end
end

function CustomFileTreeToggle()
  local wrapped_fn = Nvim.DAPUI.with_layout_handling_when_dapui_open(FileTreeToggleCore)
  wrapped_fn()
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
  lvim.builtin.which_key.mappings['e'] = { "<cmd>lua CustomFileTreeToggle()<cr>", "Neotree" }
  lvim.builtin.which_key.mappings.b['e'] = { "<cmd>Neotree buffers toggle reveal_force_cwd<cr>", "Neotree buffers" }
  lvim.keys.normal_mode["<c-k>"] = "<cmd>Neotree reveal_force_cwd<CR>"
else
  -- lvim.builtin.which_key.mappings['e'] = { "<cmd>lua require('nvim-tree.api').tree.toggle(false, false)<cr>", "NvimTree" }
  -- lvim.builtin.which_key.mappings['e'] = { "<cmd>NvimTreeToggle<cr>", "NvimTree" }
  lvim.builtin.which_key.mappings["e"] = { "<cmd>lua CustomFileTreeToggle()<cr>", "NvimTree" }
  lvim.keys.normal_mode["<c-k>"] = "<cmd>NvimTreeFocus<CR>"
end
lvim.builtin.which_key.mappings['c'] = nil
lvim.builtin.which_key.mappings['c'] = { '"_c', '"_c' }

lvim.builtin.which_key.mappings.u = lvim.builtin.which_key.mappings.l
lvim.builtin.which_key.mappings.l = nil
lvim.builtin.which_key.mappings.u.o = lvim.builtin.which_key.mappings.u.j
lvim.builtin.which_key.mappings.u.j = nil
lvim.builtin.which_key.mappings.u.k = lvim.builtin.which_key.mappings.u.u
lvim.builtin.which_key.mappings.u.u = nil
-- lvim.builtin.which_key.mappings.u.a = { "<cmd>Lspsaga code_action<cr>", "Code Action" }
lvim.builtin.which_key.mappings.u.a = { "<cmd>lua require('actions-preview').code_actions()<cr>", "Code Action" }

lvim.builtin.which_key.mappings.u.A = { "<cmd>lua require('inlayhint-filler').fill()<cr>", "Inlayhint Filler" }
lvim.builtin.which_key.mappings.u.h = { "<cmd>lua vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled())<cr>",
  "LSP Inlay Hint" }
lvim.builtin.which_key.mappings.u.t = { "<cmd>TSContextToggle<cr>", "Toggle Treesitter Context" }

lvim.builtin.which_key.vmappings.u = lvim.builtin.which_key.vmappings.l
lvim.builtin.which_key.vmappings.l = nil
-- lvim.builtin.which_key.vmappings.u.a = { "<cmd>Lspsaga code_action<cr>", "Code Action" }
lvim.builtin.which_key.vmappings.u.a = { "<cmd>lua require('actions-preview').code_actions()<cr>", "Code Action" }
lvim.builtin.which_key.vmappings.u.A = { "<cmd>lua require('inlayhint-filler').fill()<cr>", "Inlayhint Filler" }

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
lvim.builtin.which_key.mappings.s["."] = {
  "<cmd>lua require('lvim.core.telescope.custom-finders').find_project_files { previewer = true }<cr>",
  "Find File (Project)",
}

-- NOTE: DAP or Unit Test
lvim.builtin.which_key.mappings.d['s'] = { "<cmd>Telescope dap configurations<cr>", "Start" }


lvim.builtin.which_key.mappings["dm"] = {
  name = "neotest",
  r = { "<cmd>lua require('neotest').run.run(vim.fn.expand('%'))<cr>", "Test Run File" },
  R = { "<cmd>lua require('neotest').run.run({vim.fn.expand('%'), strategy = 'dap'})<cr>", "Test Run File DAP" },
  m = { "<cmd>lua require('neotest').run.run()<cr>", "Test Method" },
  M = { "<cmd>lua require('neotest').run.run({strategy = 'dap'})<cr>", "Test Method DAP" },
  c = { "<cmd>lua require('neotest').run.run({vim.fn.expand('%')})<cr>", "Test Class" },
  C = { "<cmd>lua require('neotest').run.run({vim.fn.expand('%'), strategy = 'dap'})<cr>", "Test Class DAP" },
  n = { "<cmd>lua require('neotest').run.run()<cr>", "Test Run Nearest" },
  N = { "<cmd>lua require('neotest').run.run({strategy = 'dap'})<cr>", "Test Nearest DAP" },
  l = { "<cmd>lua require('neotest').run.run_last()<cr>", "Test Run Last" },
  L = { "<cmd>lua require('neotest').run.run_last({ strategy = 'dap' })<cr>", "Test Run Last DAP" },
  o = { "<cmd>lua require('neotest').output.open({ enter = true })<cr>", "Test Output" },
  S = { "<cmd>lua require('neotest').run.stop()<cr>", "Test Stop" },
  s = { "<cmd>lua require('neotest').summary.toggle()<cr>", "Test Summary" },
}
-- lvim.builtin.which_key.mappings["dm"] = { "<cmd>lua require('neotest').run.run()<cr>",
--   "Test Method" }
lvim.builtin.which_key.mappings["dM"] = { "<cmd>lua require('neotest').run.run({strategy = 'dap'})<cr>",
  "Test Method DAP" }
-- lvim.builtin.which_key.mappings["d,"] = {
--   "<cmd>lua require('neotest').run.run({vim.fn.expand('%')})<cr>", "Test Class" }
-- lvim.builtin.which_key.mappings["d."] = {
--   "<cmd>lua require('neotest').run.run({vim.fn.expand('%'), strategy = 'dap'})<cr>", "Test Class DAP" }
-- lvim.builtin.which_key.mappings["dS"] = { "<cmd>lua require('neotest').summary.toggle()<cr>", "Test Summary" }

lvim.builtin.which_key.mappings.T['T'] = { "<cmd>TodoTelescope theme=get_ivy<cr>", "ToDo Telescope" }
lvim.builtin.which_key.mappings.T['w'] = { "<cmd>TodoTrouble<cr>", "ToDo TodoTrouble (all buffers)" }

lvim.builtin.which_key.mappings.T['d'] = { "<cmd>Trouble todo filter.buf=0<cr>", "ToDo TodoTrouble (current buffer)" }

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
lvim.builtin.which_key.mappings['t\\'] = { "<cmd>tabclose<CR>", "tabclose" }

lvim.builtin.which_key.mappings.s['d'] = { "<cmd>Telescope cder theme=get_ivy<cr>", "Chage Folder" }
lvim.builtin.which_key.mappings.s['a'] = { "<cmd>lua require('swenv.api').pick_venv()<cr>", "Chage Python Env" }
lvim.builtin.which_key.mappings.s['y'] = { "<cmd>Telescope neoclip theme=get_ivy<cr>", "Yank History" }
lvim.builtin.which_key.mappings.s['O'] = { "<cmd>Telescope orgmode search_headings<cr>",
  "orgmode search_headings" }


lvim.builtin.which_key.mappings.d['ft'] = { "<cmd>diffthis<cr>", "diffthis" }
lvim.builtin.which_key.mappings.d['fw'] = { "<cmd>diffoff<cr>", "diffoff" }
lvim.builtin.which_key.mappings.d['fW'] = { "<cmd>diffoff!<cr>", "diffoff!" }
lvim.builtin.which_key.mappings.d['fs'] = { "<cmd>set scrollbind!<cr>", "wind_scrollsync (set scrollbind!)" }
lvim.builtin.which_key.mappings.d['fe'] = { "<cmd>windo set noscrollbind<cr>",
  "wind_scrollsync_all_not (windo set noscrollbind)" }


-- lvim.builtin.which_key.mappings['B'] = { "<cmd>Telescope bookmarks<cr>", "Bookmarks" }


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

-- NOTE: This function optimizes which-key <leader>gg to open LazyGit
-- It will open the repository based on the current file's directory.
require 'lvim.core.terminal'.lazygit_toggle = function()
  local function get_git_toplevel(file_dir)
    local handle = io.popen('git -C ' .. file_dir .. ' rev-parse --show-toplevel 2>/dev/null')
    local result = handle:read("*a")
    handle:close()
    return result:gsub("%s+", "")
  end

  local file_path = vim.api.nvim_buf_get_name(0)
  local file_dir = vim.fn.fnamemodify(file_path, ':h')
  local repo_path = get_git_toplevel(file_dir)
  local repo_path_arg = repo_path == "" and "" or " -p " .. repo_path

  local Terminal = require("toggleterm.terminal").Terminal
  local lazygit = Terminal:new {
    cmd = "lazygit" .. repo_path_arg,
    hidden = true,
    direction = "float",
    float_opts = {
      border = "none",
      width = 100000,
      height = 100000,
    },
    on_open = function(_)
      vim.cmd "startinsert!"
    end,
    on_close = function(_) end,
    count = 99,
  }
  lazygit:toggle()
end
lvim.builtin.which_key.mappings.g.i = { "<cmd>lua require 'gitsigns'.nav_hunk('prev', {navigation_message = false})<cr>",
  "Prev Hunk" }
lvim.builtin.which_key.mappings.g.k = { "<cmd>lua require 'gitsigns'.nav_hunk('next', {navigation_message = false})<cr>",
  "Next Hunk" }
lvim.builtin.which_key.mappings.g.I = { "<cmd>Gitsigns toggle_current_line_blame<cr>", "Toggle Current Line Blame" }
lvim.builtin.which_key.mappings.g.j = { "<cmd>Floggit blame<cr>", "Floggit blame" }
lvim.builtin.which_key.mappings.g.D = { "<cmd>DiffviewFileHistory %<cr>", "DiffviewFileHistory (current file)" }
lvim.builtin.which_key.mappings.g.v = { "<cmd>DiffviewFileHistory<cr>", "DiffviewFileHistory (current branch)" }
lvim.builtin.which_key.mappings.g.m = { "<cmd>Flogsplit<cr>", "Flogsplit(preview all commit)" }


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

-- NOTE: telescope custom finders
lvim.builtin.which_key.mappings.U.F = {
  "<cmd>lua require('lvim.core.telescope.custom-finders').find_Lazy_pack_files()<cr>",
  "Find Lazy pack files",
}
lvim.builtin.which_key.mappings.U.G = {
  "<cmd>lua require('lvim.core.telescope.custom-finders').grep_Lazy_pack_files()<cr>",
  "Grep Lazy pack files",
}
