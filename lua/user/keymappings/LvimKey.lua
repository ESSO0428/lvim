lvim.keys.normal_mode['<leader>rc'] = ":e $HOME/.config/lvim/config.lua<cr>"
lvim.keys.normal_mode['<leader>rb'] = ":e $HOME/.bashrc<cr>"
lvim.keys.normal_mode['<leader>rw'] =
":e /mnt/c/Users/Andy6/AppData/Local/Packages/Microsoft.WindowsTerminal_8wekyb3d8bbwe/LocalState/settings.json<cr>"


lvim.keys.normal_mode['<leader>rt']    = "<Cmd>ToggleTermSendCurrentLine<cr>"
lvim.keys.visual_mode['<leader>rt']    = { ":ToggleTermSendVisualLines", silent = false }

lvim.keys.normal_mode["<leader>w"]     = "viw"
lvim.keys.normal_mode["<leader>y"]     = "yiw"

lvim.keys.normal_mode['<F9>']          = nil
lvim.keys.normal_mode['<F9>']          = ":LvimCacheReset<cr>"
lvim.keys.normal_mode['<leader>i']     = "<Cmd>wincmd k<cr>"
lvim.keys.normal_mode['<leader>k']     = "<Cmd>wincmd j<cr>"
lvim.keys.normal_mode['<leader>j']     = "<Cmd>wincmd h<cr>"
lvim.keys.normal_mode['<leader>l']     = "<Cmd>wincmd l<cr>"
lvim.keys.normal_mode['<leader>J']     = "<Cmd>wincmd t<cr>"
lvim.keys.normal_mode["<leader>L"]     = "<cmd>wincmd b<cr>"
-- lvim.keys.normal_mode['`']         = "~"
-- lvim.keys.normal_mode['Z']         = ":UndotreeToggle<cr>"

lvim.keys.normal_mode['<leader><cr>']  = ":nohlsearch<cr>"
-- lvim.keys.normal_mode['<leader>f']    = nil

-- require vim-peekaboo
lvim.keys.normal_mode['<c-f>']         = "<Cmd>Telescope current_buffer_fuzzy_find<cr>"
lvim.keys.normal_mode['<leader><c-f>'] = "<Cmd>lua require('telescope.builtin').live_grep({grep_open_files=true})<cr>"
lvim.keys.normal_mode['<c-h>']         = "<Cmd>MurenToggle<cr>"
lvim.keys.normal_mode['<leader><c-h>'] = "<Cmd>MurenUnique<cr>"
lvim.keys.normal_mode['<c-d>']         = "\"dyy\"dp"
lvim.keys.normal_mode['<a-L>']         = "<Plug>(VM-Select-All)"
lvim.keys.visual_mode['<a-L>']         = "<Plug>(VM-Visual-All)"
-- <leader>h
-- lvim.builtin.which_key.mappings['h'] = { '"fyiw:.,$s/<c-r>f//gc<Left><Left><Left>', "Repalce => empty (c)",
--   silent = false }

-- lvim.keys.normal_mode['<c-u>'] = "<Plug>MoveLineUp"
lvim.keys.normal_mode['<a-up>']        = "<Plug>MoveLineUp"
lvim.keys.normal_mode['<a-down>']      = "<Plug>MoveLineDown"
lvim.keys.normal_mode['<c-u>']         = "10<c-y>"
lvim.keys.normal_mode['<c-o>']         = "10<c-e>"

-- vim.keymap.set('v', '<c-u>', "<Plug>MoveBlockUp")
-- vim.keymap.set('v', '<c-o>', "<Plug>MoveBlockDown")
-- vim.keymap.set('v', '<a-up>', "<Plug>MoveBlockUp")
-- vim.keymap.set('v', '<a-down>', "<Plug>MoveBlockDown")
-- vim.keymap.set('v', '<a-left>', "<Plug>MoveBlockLeft")
-- vim.keymap.set('v', '<a-right>', "<Plug>MoveBlockRight")
vim.keymap.set('v', '<a-up>',
  function()
    if vim.fn.mode() == "v" then return "<Plug>MoveBlockUp" else return "<Plug>SchleppUp" end
  end, { expr = true, silent = true }
)
vim.keymap.set('v', '<a-down>',
  function()
    if vim.fn.mode() == "v" then return "<Plug>MoveBlockDown" else return "<Plug>SchleppDown" end
  end, { expr = true, silent = true }
)
vim.keymap.set('v', '<a-left>',
  function()
    if vim.fn.mode() == "v" then return "<Plug>MoveBlockLeft" else return "<Plug>SchleppLeft" end
  end, { expr = true, silent = true }
)
vim.keymap.set('v', '<a-right>',
  function()
    if vim.fn.mode() == "v" then return "<Plug>MoveBlockRight" else return "<Plug>SchleppRight" end
  end, { expr = true, silent = true }
)


-- <leader>o
-- lvim.builtin.which_key.mappings['o'] = { "za", "Folding Code (Toggle)" }
--
-- -- lvim.builtin.which_key.mappings['O'] = { "zR", "Folding Code (Open All)" }
-- lvim.builtin.which_key.mappings['Oa'] = { "zM", "Folding Code (Close All)" }
-- lvim.builtin.which_key.mappings['Od'] = { "zR", "Folding Code (Open All)" }
lvim.keys.visual_mode['<leader>o'] = "za"

function peekFoldedLinesUnderCursor()
  require('ufo').peekFoldedLinesUnderCursor()
  local winid = require('ufo.preview.floatwin').winid

  if winid ~= nil then
    vim.api.nvim_win_set_option(winid, 'list', vim.opt.list:get())
  end
end

lvim.keys.normal_mode['<leader>uu'] = { "<cmd>lua peekFoldedLinesUnderCursor()<cr>" }


function vscode_like_foldLevel_enhance(n)
  require('fold-cycle').close_all()
  n = n - 1
  if n >= 1 then
    for i = 1, n do
      require('fold-cycle').open()
    end
  end
end

lvim.keys.normal_mode[']1'] = { '<cmd>lua vscode_like_foldLevel_enhance(1)<cr>' }
lvim.keys.normal_mode[']2'] = { '<cmd>lua vscode_like_foldLevel_enhance(2)<cr>' }
lvim.keys.normal_mode[']3'] = { '<cmd>lua vscode_like_foldLevel_enhance(3)<cr>' }
lvim.keys.normal_mode[']4'] = { '<cmd>lua vscode_like_foldLevel_enhance(4)<cr>' }
lvim.keys.normal_mode[']5'] = { '<cmd>lua vscode_like_foldLevel_enhance(5)<cr>' }
lvim.keys.normal_mode[']6'] = { '<cmd>lua vscode_like_foldLevel_enhance(6)<cr>' }
lvim.keys.normal_mode[']7'] = { '<cmd>lua vscode_like_foldLevel_enhance(7)<cr>' }
lvim.keys.normal_mode[']8'] = { '<cmd>lua vscode_like_foldLevel_enhance(8)<cr>' }
lvim.keys.normal_mode[']9'] = { '<cmd>lua vscode_like_foldLevel_enhance(9)<cr>' }


-- lvim.keys.visual_mode['<leader>Od'] = "zo"

lvim.keys.normal_mode["<F10>"]         = { ":SessionManager save_current_session<CR>", silent = false }
lvim.keys.normal_mode["<leader>S"]     = { ":SessionManager save_current_session<CR>", silent = false }

lvim.keys.normal_mode["<a-'>"]         = "<Cmd>tab split<CR>"
lvim.keys.normal_mode["<a-/>"]         = "<Cmd>tabn 1<CR>"
lvim.keys.normal_mode["<a-,>"]         = "<Cmd>tabprevious<CR>"
lvim.keys.normal_mode["<a-.>"]         = "<Cmd>tabnext<CR>"
-- lvim.keys.normal_mode["<F6>"]          = "<Cmd>tabmove -1<CR>"
-- lvim.keys.normal_mode["<F7>"]          = "<Cmd>tabmove +1<CR>"
lvim.keys.normal_mode["<C-Left>"]      = "<Cmd>tabmove -1<CR>"
lvim.keys.normal_mode["<C-Right>"]     = "<Cmd>tabmove +1<CR>"
lvim.keys.normal_mode["<a-\\>"]        = "<Cmd>tabclose<CR>"

lvim.keys.normal_mode["<leader>["]     = "<Cmd>cprevious<CR>"
lvim.keys.normal_mode["<leader>]"]     = "<Cmd>cnext<CR>"

lvim.keys.normal_mode["<C-j>"]         = "<Cmd>BufferLineCyclePrev<CR>"
lvim.keys.normal_mode["<C-l>"]         = "<Cmd>BufferLineCycleNext<CR>"
lvim.keys.normal_mode["<a-j>"]         = "<Cmd>BufferLineMovePrev<CR>"
lvim.keys.normal_mode["<a-l>"]         = "<Cmd>BufferLineMoveNext<CR>"
lvim.keys.normal_mode["<a-k>"]         = "<c-d>"
lvim.builtin.which_key.mappings.b.k    = { "<cmd>BufferLineSortByDirectory<CR>", "Sort By Directory" }
lvim.keys.normal_mode["<a-i>"]         = "<c-u>"
lvim.builtin.which_key.mappings.b.i    = { "<cmd>BufferLinePickClose<CR>", "Close Buffer" }
lvim.keys.normal_mode["<a-g>"]         = { ":BufferLineGroupToggle", silent = false }
lvim.keys.normal_mode["<leader><a-g>"] = { ":BufferLineGroupClose", silent = false }
lvim.keys.normal_mode["<leader><a-i>"] = "<cmd>BufferLineTogglePin<CR>"
-- lvim.keys.normal_mode["<c-w>"]         = "<cmd>BufferKill<CR>"
lvim.keys.normal_mode["<c-w>"]         = "<cmd>BufferLineKill<CR>"
-- NOTE: 利用 BufferKill 強制關閉緩衝區
function forceBufferKill(_)
  require("lvim.core.bufferline").buf_kill("bd", 0, true)
end

-- lvim.keys.normal_mode["<leader><c-w>"]  = "<cmd>lua forceBufferKill()<CR>"
lvim.keys.normal_mode["<leader><c-w>"]  = "<cmd>ForceBufferLineKill<CR>"
-- NOTE: 直接使用 bd! 強制關閉緩衝區
lvim.keys.normal_mode["<leader>d<c-w>"] = "<cmd>bd!<CR>"

-- lvim.keys.normal_mode["<a-1>"] = nil
-- lvim.keys.normal_mode["<a-2>"] = nil
-- lvim.keys.normal_mode["<a-3>"] = nil

lvim.keys.normal_mode["gy"]             = "<cmd>let @+ = expand('%:p')<CR>"
lvim.keys.normal_mode["<a-1>"]          = "<Cmd>BufferLineGoToBuffer 1<CR>"
lvim.keys.normal_mode["<a-2>"]          = "<Cmd>BufferLineGoToBuffer 2<CR>"
lvim.keys.normal_mode["<a-3>"]          = "<Cmd>BufferLineGoToBuffer 3<CR>"
lvim.keys.normal_mode["<a-4>"]          = "<Cmd>BufferLineGoToBuffer 4<CR>"
lvim.keys.normal_mode["<a-5>"]          = "<Cmd>BufferLineGoTOBuffer 5<CR>"
lvim.keys.normal_mode["<a-6>"]          = "<Cmd>BufferLineGoToBuffer 6<CR>"
lvim.keys.normal_mode["<a-7>"]          = "<Cmd>BufferLineGoToBuffer 7<CR>"
lvim.keys.normal_mode["<a-8>"]          = "<Cmd>BufferLineGoToBuffer 8<CR>"
lvim.keys.normal_mode["<a-9>"]          = "<Cmd>BufferLineGoToBuffer 9<CR>"
lvim.keys.normal_mode["<a-0>"]          = "<Cmd>BufferLineGoToBuffer -1<CR>"
lvim.keys.normal_mode["<a-->"]          = "<Cmd>b#<CR>"
-- -- Use which-key to add extra bindings with the leader-key prefix
-- lvim.builtin.which_key.mappings["W"] = { "<cmd>noautocmd w<cr>", "Save without formatting" }
-- lvim.builtin.which_key.mappings["P"] = { "<cmd>Telescope projects<CR>", "Projects" }
-- nvim notebook (Andy6)
-- vim.keymap.set('n', '<leader>es', '<cmd>IronRepl<cr>')
-- vim.keymap.set('n', '<leader>er', '<cmd>IronRestart<cr>')
-- vim.keymap.set('n', '<leader>ef', '<cmd>IronFocus<cr>')
-- vim.keymap.set('n', '<leader>eh', '<cmd>IronHide<cr>')

-- lvim.keys.normal_mode["<S-l>"] = ":BufferLineCycleNext<CR>"
-- lvim.keys.normal_mode["<S-h>"] = ":BufferLineCyclePrev<CR>"

lvim.keys.normal_mode["<A-BS>"]         = ":cd ../<cr>"
lvim.keys.normal_mode["<leader><A-BS>"] = ":cd %:p:h <cr>"
lvim.keys.normal_mode['<leader>se']     = { '<cmd>SessionManager load_session<cr>' }
-- lvim.keys.normal_mode['<leader>f']      = { '<Plug>(leap-forward)' }
-- lvim.keys.normal_mode['<leader>F']      = { '<Plug>(leap-backward)' }
lvim.keys.normal_mode["<M-n>"]          = { "<cmd>lua require('illuminate').goto_next_reference(wrap)<cr>" }
lvim.keys.normal_mode["<M-N>"]          = { "<cmd>lua require('illuminate').goto_prev_reference(wrap)<cr>" }

-- debug
lvim.keys.normal_mode["]d"]             = { "<cmd>lua require('goto-breakpoints').next()<cr>" }
lvim.keys.normal_mode["[d"]             = { "<cmd>lua require('goto-breakpoints').prev()<cr>" }
lvim.keys.normal_mode["]S"]             = { "<cmd>lua require('goto-breakpoints').stopped()<cr>" }
-- lvim.keys.normal_mode['<leader>\\']     = { "<cmd>lua require('dap').toggle_breakpoint()<cr>" }
lvim.keys.normal_mode['<leader>\\']     = { "<cmd>lua require('persistent-breakpoints.api').toggle_breakpoint()<cr>" }
-- lvim.builtin.which_key.mappings.d['\\'] = { "<cmd>lua require('dap').clear_breakpoints()<cr>", 'Clear All Breakpoint' }
lvim.builtin.which_key.mappings.d['\\'] = { "<cmd>lua require('persistent-breakpoints.api').clear_breakpoints()<cr>",
  'Clear All Breakpoint' }
-- lvim.builtin.which_key.mappings.d['lc'] = {
--   "<cmd>lua require('dap').set_breakpoint(vim.fn.input('Breakpoint condition: '), vim.fn.input('Hit condition: '), nil)<CR>",
--   'Breakpoint Condition' }
lvim.builtin.which_key.mappings.d['lc'] = {
  "<cmd>lua require('persistent-breakpoints.api').set_breakpoint(vim.fn.input('Breakpoint condition: '), vim.fn.input('Hit condition: '), nil)<CR>",
  'Breakpoint Condition' }
-- lvim.builtin.which_key.mappings.d['ll'] = {
--   "<cmd>lua require'dap'.set_breakpoint(vim.fn.input('Breakpoint condition: '), vim.fn.input('Hit condition: '), vim.fn.input('Log point message: '))<CR>",
--   'Condition Logponit Message' }
lvim.builtin.which_key.mappings.d['ll'] = {
  "<cmd>lua require('persistent-breakpoints.api').set_breakpoint(vim.fn.input('Breakpoint condition: '), vim.fn.input('Hit condition: '), vim.fn.input('Log point message: '))<CR>",
  'Condition Logponit Message' }
lvim.keys.normal_mode["<M-s>"]          = { '<cmd>lua require("dapui").eval()<cr>' }
lvim.keys.normal_mode["<F5>"]           = { "<cmd>lua require('dap').continue()<cr>" }
lvim.keys.normal_mode["<F17>"]          = { "<cmd>lua require('dap').close()<cr>" }

vim.cmd('noremap <a-p> <Nop>')
vim.keymap.set('i', '<a-u>', "<Esc>:m .-2<CR>==gi")
vim.keymap.set('i', '<a-o>', "<Esc>:m .+1<CR>==gi")
