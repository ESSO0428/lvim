-- import the integrated WindowsTerminal module
local windows_terminal = require("user.integrated.WindowsTerminal")


lvim.keys.normal_mode["<a-q>"] = { "<cmd>copen<cr>" }
-- lvim core command <c-q>
--[[
vim.cmd [[
  function! QuickFixToggle()
    if empty(filter(getwininfo(), 'v:val.quickfix'))
      copen
    else
      cclose
    endif
  endfunction
]]

lvim.keys.normal_mode['<leader>rc'] = "<cmd>e $HOME/.config/lvim/config.lua<cr>"
lvim.keys.normal_mode['<leader>rb'] = "<cmd>e $HOME/.bashrc<cr>"

-- bind the function to the <leader>rw keybinding
lvim.keys.normal_mode['<leader>rw'] = windows_terminal.find_and_edit_terminal_settings


lvim.keys.normal_mode['<leader>rt']    = "<cmd>ToggleTermSendCurrentLine<cr>"
lvim.keys.visual_mode['<leader>rt']    = { ":ToggleTermSendVisualLines", silent = false }

lvim.keys.normal_mode["<leader>w"]     = "viw"
lvim.keys.normal_mode["<leader>y"]     = "yiw"

lvim.keys.normal_mode['<leader>i']     = "<cmd>wincmd k<cr>"
lvim.keys.normal_mode['<leader>k']     = "<cmd>wincmd j<cr>"
lvim.keys.normal_mode['<leader>j']     = "<cmd>wincmd h<cr>"
lvim.keys.normal_mode['<leader>l']     = "<cmd>wincmd l<cr>"
lvim.keys.normal_mode['<leader>J']     = "<cmd>wincmd t<cr>"
lvim.keys.normal_mode["<leader>L"]     = "<cmd>wincmd b<cr>"
-- lvim.keys.normal_mode['`']         = "~"
-- lvim.keys.normal_mode['Z']         = ":UndotreeToggle<cr>"

lvim.keys.normal_mode['<leader><cr>']  = "<cmd>nohlsearch<cr>"
-- lvim.keys.normal_mode['<leader>f']    = nil

-- require vim-peekaboo
lvim.keys.normal_mode['<c-f>']         = "<cmd>Telescope current_buffer_fuzzy_find<cr>"
lvim.keys.normal_mode['<leader><c-f>'] = "<cmd>lua require('telescope.builtin').live_grep({grep_open_files=true})<cr>"
lvim.keys.normal_mode['<c-h>']         = "<cmd>MurenToggle<cr>"
lvim.keys.normal_mode['<leader><c-h>'] = "<cmd>MurenUnique<cr>"
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

lvim.keys.normal_mode[']1'] = { "<cmd>lua vscode_like_foldLevel_enhance(1)<cr>" }
lvim.keys.normal_mode[']2'] = { "<cmd>lua vscode_like_foldLevel_enhance(2)<cr>" }
lvim.keys.normal_mode[']3'] = { "<cmd>lua vscode_like_foldLevel_enhance(3)<cr>" }
lvim.keys.normal_mode[']4'] = { "<cmd>lua vscode_like_foldLevel_enhance(4)<cr>" }
lvim.keys.normal_mode[']5'] = { "<cmd>lua vscode_like_foldLevel_enhance(5)<cr>" }
lvim.keys.normal_mode[']6'] = { "<cmd>lua vscode_like_foldLevel_enhance(6)<cr>" }
lvim.keys.normal_mode[']7'] = { "<cmd>lua vscode_like_foldLevel_enhance(7)<cr>" }
lvim.keys.normal_mode[']8'] = { "<cmd>lua vscode_like_foldLevel_enhance(8)<cr>" }
lvim.keys.normal_mode[']9'] = { "<cmd>lua vscode_like_foldLevel_enhance(9)<cr>" }


-- lvim.keys.visual_mode['<leader>Od'] = "zo"

lvim.keys.normal_mode["<leader>S"]     = { ":SessionManager save_current_session<cr>", silent = false }

lvim.keys.normal_mode["<a-'>"]         = "<cmd>tab split<cr>"
lvim.keys.normal_mode["<a-/>"]         = "<cmd>tabn 1<cr>"
lvim.keys.normal_mode["<a-,>"]         = "<cmd>tabprevious<cr>"
lvim.keys.normal_mode["<a-.>"]         = "<cmd>tabnext<cr>"

lvim.keys.normal_mode["<C-Left>"]      = "<cmd>tabmove -1<cr>"
lvim.keys.normal_mode["<C-Right>"]     = "<cmd>tabmove +1<cr>"
lvim.keys.normal_mode["<a-\\>"]        = "<cmd>tabclose<cr>"

lvim.keys.normal_mode["<leader>["]     = "<cmd>cprevious<cr>"
lvim.keys.normal_mode["<leader>]"]     = "<cmd>cnext<cr>"

lvim.keys.normal_mode["<C-j>"]         = "<cmd>BufferLineCyclePrev<cr>"
lvim.keys.normal_mode["<C-l>"]         = "<cmd>BufferLineCycleNext<cr>"
lvim.keys.normal_mode["<a-j>"]         = "<cmd>BufferLineMovePrev<cr>"
lvim.keys.normal_mode["<a-l>"]         = "<cmd>BufferLineMoveNext<cr>"
lvim.keys.normal_mode["<a-k>"]         = "<c-d>"
lvim.builtin.which_key.mappings.b.k    = { "<cmd>BufferLineSortByDirectory<cr>", "Sort By Directory" }
lvim.keys.normal_mode["<a-i>"]         = "<c-u>"
lvim.builtin.which_key.mappings.b.i    = { "<cmd>BufferLinePickClose<cr>", "Close Buffer" }
lvim.keys.normal_mode["<a-g>"]         = { ":BufferLineGroupToggle", silent = false }
lvim.keys.normal_mode["<leader><a-g>"] = { ":BufferLineGroupClose", silent = false }
lvim.keys.normal_mode["<leader><a-i>"] = "<cmd>BufferLineTogglePin<cr>"
-- lvim.keys.normal_mode["<c-w>"]         = "<cmd>BufferKill<cr>"
lvim.keys.normal_mode["<c-w>"]         = "<cmd>BufferLineKill<cr>"
-- NOTE: 利用 BufferKill 強制關閉緩衝區
function forceBufferKill(_)
  require("lvim.core.bufferline").buf_kill("bd", 0, true)
end

-- lvim.keys.normal_mode["<leader><c-w>"]  = "<cmd>lua forceBufferKill()<cr>"
lvim.keys.normal_mode["<leader><c-w>"]  = "<cmd>ForceBufferLineKill<cr>"
-- NOTE: 直接使用 bd! 強制關閉緩衝區
lvim.keys.normal_mode["<leader>d<c-w>"] = "<cmd>bd!<cr>"

-- lvim.keys.normal_mode["<a-1>"] = nil
-- lvim.keys.normal_mode["<a-2>"] = nil
-- lvim.keys.normal_mode["<a-3>"] = nil

lvim.keys.normal_mode["gy"]             = "<cmd>let @+ = expand('%:p')<cr>"
lvim.keys.normal_mode["<a-1>"]          = "<cmd>BufferLineGoToBuffer 1<cr>"
lvim.keys.normal_mode["<a-2>"]          = "<cmd>BufferLineGoToBuffer 2<cr>"
lvim.keys.normal_mode["<a-3>"]          = "<cmd>BufferLineGoToBuffer 3<cr>"
lvim.keys.normal_mode["<a-4>"]          = "<cmd>BufferLineGoToBuffer 4<cr>"
lvim.keys.normal_mode["<a-5>"]          = "<cmd>BufferLineGoTOBuffer 5<cr>"
lvim.keys.normal_mode["<a-6>"]          = "<cmd>BufferLineGoToBuffer 6<cr>"
lvim.keys.normal_mode["<a-7>"]          = "<cmd>BufferLineGoToBuffer 7<cr>"
lvim.keys.normal_mode["<a-8>"]          = "<cmd>BufferLineGoToBuffer 8<cr>"
lvim.keys.normal_mode["<a-9>"]          = "<cmd>BufferLineGoToBuffer 9<cr>"
lvim.keys.normal_mode["<a-0>"]          = "<cmd>BufferLineGoToBuffer -1<cr>"
lvim.keys.normal_mode["<a-->"]          = "<cmd>b#<cr>"
-- -- Use which-key to add extra bindings with the leader-key prefix
-- lvim.builtin.which_key.mappings["W"] = { "<cmd>noautocmd w<cr>", "Save without formatting" }
-- lvim.builtin.which_key.mappings["P"] = { "<cmd>Telescope projects<cr>", "Projects" }
-- nvim notebook (Andy6)
-- vim.keymap.set('n', '<leader>es', '<cmd>IronRepl<cr>')
-- vim.keymap.set('n', '<leader>er', '<cmd>IronRestart<cr>')
-- vim.keymap.set('n', '<leader>ef', '<cmd>IronFocus<cr>')
-- vim.keymap.set('n', '<leader>eh', '<cmd>IronHide<cr>')

-- lvim.keys.normal_mode["<S-l>"] = "<cmd>BufferLineCycleNext<cr>"
-- lvim.keys.normal_mode["<S-h>"] = "<cmd>BufferLineCyclePrev<cr>"

lvim.keys.normal_mode["<A-BS>"]         = "<cmd>cd ../<cr>"
lvim.keys.normal_mode["<leader><A-BS>"] = "<cmd>cd %:p:h <cr>"
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
lvim.builtin.which_key.mappings.d['\\'] = { "<cmd>lua require('persistent-breakpoints.api').clear_all_breakpoints()<cr>",
  'Clear All Breakpoint' }
-- lvim.builtin.which_key.mappings.d['lc'] = {
--   "<cmd>lua require('dap').set_breakpoint(vim.fn.input('Breakpoint condition: '), vim.fn.input('Hit condition: '), nil)<cr>",
--   'Breakpoint Condition' }
lvim.builtin.which_key.mappings.d['lc'] = {
  "<cmd>lua require('persistent-breakpoints.api').set_breakpoint(vim.fn.input('Breakpoint condition: '), vim.fn.input('Hit condition: '), nil)<cr>",
  'Breakpoint Condition' }
-- lvim.builtin.which_key.mappings.d['ll'] = {
--   "<cmd>lua require'dap'.set_breakpoint(vim.fn.input('Breakpoint condition: '), vim.fn.input('Hit condition: '), vim.fn.input('Log point message: '))<cr>",
--   'Condition Logponit Message' }
lvim.builtin.which_key.mappings.d['ll'] = {
  "<cmd>lua require('persistent-breakpoints.api').set_breakpoint(vim.fn.input('Breakpoint condition: '), vim.fn.input('Hit condition: '), vim.fn.input('Log point message: '))<cr>",
  'Condition Logponit Message' }
lvim.builtin.which_key.mappings.d.v     = { "<cmd>lua require('dapui').eval()<cr>", "Evaluate Expression" }
lvim.keys.visual_mode["<leader>dv"]     = { "<cmd>lua require('dapui').eval()<cr>" }
lvim.keys.normal_mode["<F5>"]           = { "<cmd>lua require('dap').continue()<cr>" }
lvim.keys.normal_mode["<F17>"]          = { "<cmd>lua require('dap').close()<cr>" }
lvim.keys.normal_mode["<F8>"]           = { "<cmd>lua require'dap'.step_into()<cr>" }
-- Shift + F8
lvim.keys.normal_mode["<F20>"]          = { "<cmd>lua require'dap'.step_over()<cr>" }
lvim.keys.normal_mode["<F6>"]           = { "<cmd>lua require'dap'.step_out()<cr>" }

vim.cmd('noremap <a-p> <Nop>')
vim.keymap.set('i', '<a-u>', "<Esc>:m .-2<cr>==gi")
vim.keymap.set('i', '<a-o>', "<Esc>:m .+1<cr>==gi")
function DAP_edit_breakpoint(LogMessage)
  local Breakpoint_Condition = function()
    local condition_input = vim.fn.input('Breakpoint condition: ')
    local hitCondition_input = vim.fn.input('Hit condition: ')
    local logMessage_input = nil
    if LogMessage then
      logMessage_input = vim.fn.input('Log point message: ')
    end
    require('persistent-breakpoints.api').set_breakpoint(
      condition_input,
      hitCondition_input,
      -- NOTE: Exclude LogMessage since it's incompatible with regular breakpoints
      logMessage_input
    )
  end
  -- Get all breakpoints
  local breakpoints = require('dap.breakpoints').get()

  -- Check if breakpoints is empty or nil, if so return
  if breakpoints == nil or vim.tbl_isempty(breakpoints) then
    Breakpoint_Condition()
    return
  end

  -- Get current line and current buffer
  local current_line = vim.fn.line('.')
  local current_buffer = vim.fn.bufnr()

  -- If there are breakpoints in the current buffer
  if breakpoints[current_buffer] then
    -- Traverse all breakpoints in the current buffer
    for _, bp in pairs(breakpoints[current_buffer]) do
      if bp.line then
        local bp_line = bp.line

        -- If the current line corresponds to the line of the breakpoint
        if bp_line == current_line then
          -- Check if there is condition, hitCondition or logMessage
          local condition_exists = bp.condition ~= nil
          local hitCondition_exists = bp.hitCondition ~= nil
          local logMessage_exists = bp.logMessage ~= nil

          -- If none exists, return
          if not (condition_exists or hitCondition_exists or logMessage_exists) then
            Breakpoint_Condition()
            return
          end

          -- Set input default value
          local condition_input = nil
          if condition_exists then
            condition_input = vim.fn.input('Breakpoint condition: ', bp.condition)
          end
          local hitCondition_input = nil
          if hitCondition_exists then
            hitCondition_input = vim.fn.input('Hit condition: ', bp.hitCondition)
          end
          local logMessage_input = nil
          if logMessage_exists and LogMessage ~= nil then
            logMessage_input = vim.fn.input('Log point message: ', bp.logMessage)
          elseif LogMessage then
            logMessage_input = vim.fn.input('Log point message: ')
          end
          -- Set breakpoint
          require('persistent-breakpoints.api').set_breakpoint(
            condition_input,
            hitCondition_input,
            logMessage_input
          )
          return
        end
      end
    end
  end
  -- If no matching breakpoint, create a new one
  Breakpoint_Condition()
end

lvim.builtin.which_key.mappings.d['le'] = {
  "<cmd>lua DAP_edit_breakpoint(false)<cr>",
  'Edit Breakpoint' }
lvim.builtin.which_key.mappings.d['lE'] = {
  "<cmd>lua DAP_edit_breakpoint(nil)<cr>",
  'Edit Breakpoint (Force Remove Log)' }
lvim.builtin.which_key.mappings.d['lL'] = {
  "<cmd>lua DAP_edit_breakpoint(true)<cr>",
  'Edit Breakpoint (Force Add Log)' }
