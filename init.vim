" ==================== Auto load for first time uses ====================
let g:MYVIMRC="$HOME/.config/lvim/init.vim"
if empty(glob($HOME.'/.config/lvim/autoload/plug.vim'))
	silent !curl -fLo $HOME/.config/lvim/autoload/plug.vim --create-dirs
				\ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
	autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
endif

call plug#begin('$HOME/.config/lvim/plugged')
" ========= nvim notebook (Andy6) =========
" Plug 'SirVer/ultisnips'
" Plug 'theniceboy/vim-snippets'
if has('nvim')
  function! UpdateRemotePlugins(...)
    " Needed to refresh runtime files
    let &rtp=&rtp
    UpdateRemotePlugins
  endfunction

  Plug 'gelguy/wilder.nvim', { 'do': function('UpdateRemotePlugins') }
else
  Plug 'gelguy/wilder.nvim'

  " To use Python remote plugin features in Vim, can be skipped
  Plug 'roxma/nvim-yarp'
  Plug 'roxma/vim-hug-neovim-rpc'
endif
Plug 'ojroques/vim-oscyank', {'branch': 'main'}
" Plug 'RRethy/vim-hexokinase', { 'do': 'cd ~/.config/lvim/plugged/vim-hexokinase/; make hexokinase' }
Plug 'tpope/vim-surround'
Plug 'mbbill/undotree'
Plug 'ESSO0428/iron.nvim'
Plug 'kana/vim-textobj-user'
Plug 'kana/vim-textobj-line'
Plug 'GCBallesteros/vim-textobj-hydrogen'
Plug 'GCBallesteros/jupytext.vim'
"
" Plug 'bfredl/nvim-ipy'
Plug 'ESSO0428/nvim-ipy'
" command! -nargs=0 RunQtConsole
"   \ call jobstart("jupyter qtconsole --JupyterWidget.include_other_output=True --style monokai")
command! -nargs=0 RunQtConsole call OpenQtConsole()

function! OpenQtConsole()
  let current_file = expand('%:p:h')
  let command = "cd " . current_file . "; jupyter qtconsole --JupyterWidget.include_other_output=True --style monokai"
  call jobstart(command)
endfunction

" regex for cell start and end
let g:ipy_celldef = '^# %%'
" jupyter run shortscut
" nmap <silent>[q :RunQtConsole<Enter>
nmap <silent>'q :RunQtConsole<CR>gg
" nmap <slient>[e :IPython<Space>--existing<Space>--no-window<Enter>
" nmap <silent> <leader>jc <Plug>(IPy-RunCell)
" nmap <silent> <leader>ja <Plug>(IPy-RunAll)
" nmap <slient>]q <Plug>(IPy-RunCell)
" nmap <silent>]aq <Plug>(IPy-RunAll)

" nmap <silent>]q :ipython<Space>--existing<Space>--no-window<cr><plug>(IPy-Runcell)<cr>/^# %%<cr><leader><cr>
" nmap <silent>\x :IPython<Space>--existing<Space>--no-window<CR><Plug>(IPy-RunCell)<CR>/^# %%<CR><leader><CR>
nmap <silent> \E :IronRepl<CR>
nmap <silent>\x :IPython<Space>--existing<Space>--no-window<CR><Plug>(IPy-RunCell)
" nmap <silent>]e :IPython<Space>--existing<Space>--no-window<CR><Plug>(IPy-RunAll)
nmap <silent>\e :IPython<Space>--existing<Space>--no-window<CR><Plug>(IPy-RunAll)


" Snippets
" Plug 'SirVer/ultisnips'
"" Plug 'theniceboy/vim-snippets'


call plug#end()

set re=0
silent! exec ":UpdateRemotePlugins"

" ========= nvim notebook (Andy6) =========
" Jupytext
let g:jupytext_fmt = 'py'
let g:jupytext_style = 'hydrogen'
" Send cell to IronRepl and move to next cell.
" Depends on the text object defined in vim-textobj-hydrogen
" You first need to be connected to IronRepl
" nmap ]x ctrih/^# %%<CR><CR>
nmap [x strah<ESC>/^# %%<CR><space><CR>
nmap ]x strih<ESC>/^# %%<CR><space><CR>


" ==================== Ultisnips ====================
" let g:tex_flavor = "latex"
" inoremap <c-n> <nop>
" let g:UltiSnipsExpandTrigger="<c-l>"
" let g:UltiSnipsJumpBackwardTrigger="<c-g>"
" let g:UltiSnipsJumpForwardTrigger="<c-h>"
" let g:UltiSnipsSnippetDirectories = [$HOME.'/.config/lvim/UltiSnips/']


noremap Z :UndotreeToggle<CR>

let g:undotree_DiffAutoOpen = 1
let g:undotree_SetFocusWhenToggle = 1
let g:undotree_ShortIndicators = 1
let g:undotree_WindowLayout = 2
let g:undotree_DiffpanelHeight = 8
let g:undotree_SplitWidth = 24
function g:Undotree_CustomMap()
	" colemak keyboard
	" nmap <buffer> u <plug>UndotreeNextState
	" nmap <buffer> e <plug>UndotreePreviousState
	" nmap <buffer> U 5<plug>UndotreeNextState
	" nmap <buffer> E 5<plug>UndotreePreviousState
	" normal keyboard
	nmap <buffer> i <plug>UndotreeNextState
	nmap <buffer> k <plug>UndotreePreviousState
	nmap <buffer> I 5<plug>UndotreeNextState
	nmap <buffer> K 5<plug>UndotreePreviousState
endfunc

" Use OSCYank to access the system clipboard
" tmux : set -s set-clipboard on
" if $DISPLAY == 'localhost:10.0'
" autocmd TextYankPost *
"     \ if v:event.operator is 'y' || v:event.operator is 'd' |
"     \ execute 'OSCYankRegister +' |
"     \ endif
" endif

function! SetOsc52Clipboard()
    let g:clipboard = {
        \   'name': 'osc52',
        \   'copy': {
        \     '+': {lines, regtype -> OSCYank(join(lines, "\n"))},
        \     '*': {lines, regtype -> OSCYank(join(lines, "\n"))},
        \   },
        \   'paste': {
        \     '+': {-> [split(getreg(''), '\n'), getregtype('')]},
        \     '*': {-> [split(getreg(''), '\n'), getregtype('')]},
        \   },
        \ }
endfunction

function! SetWslClipboard()
  let g:clipboard = {
    \   'name': 'WslClipboard',
    \   'copy': {
    \      '+': 'clip.exe',
    \      '*': 'clip.exe',
    \    },
    \   'paste': {
    \      '+': 'powershell.exe -c [Console]::Out.Write($(Get-Clipboard -Raw).tostring().replace("`r", ""))',
    \      '*': 'powershell.exe -c [Console]::Out.Write($(Get-Clipboard -Raw).tostring().replace("`r", ""))',
    \   },
    \   'cache_enabled': 0,
    \ }
endfunction

command! SetClipboardOsc52 call SetOsc52Clipboard() | checkhealth provider
command! SetClipboardWsl call SetWslClipboard() | checkhealth provider
call SetOsc52Clipboard()
" let g:clipboard = {
"         \   'name': 'osc52',
"         \   'copy': {
"         \     '+': {lines, regtype -> OSCYank(join(lines, "\n"))},
"         \     '*': {lines, regtype -> OSCYank(join(lines, "\n"))},
"         \   },
"         \   'paste': {
"         \     '+': {-> [split(getreg(''), '\n'), getregtype('')]},
"         \     '*': {-> [split(getreg(''), '\n'), getregtype('')]},
"         \   },
"         \ }


lua <<EOF
local iron = require("iron.core")
local view = require("iron.view")
iron.setup({
  config = {
    repl_open_cmd = view.split.vertical.botright(0.45),
    should_map_plug = false,
    execute_repl_with_workspace = true,
    scratch_repl = true,
    repl_definition = {
      python = {
        -- command = { "ipython" },
        -- command = { "ptpython" },
        -- command = { "ptpython", "--dark-bg" },
        -- command = { "ptipython", "--dark-bg" },
        command = { "jupyter", "console" },
        format = require("iron.fts.common").bracketed_paste,
      },
    },
  },
  keymaps = {
    send_motion = "str",
    visual_send = "str",
  },
})
EOF
let g:nvim_ipy_perform_mappings = 0

autocmd VimEnter * silent! execute '!chmod -R 755 ~/.config/lvim/jupyter_ascending/'
source ~/.config/lvim/jupyter_ascending/PythonInteractive_JupterNotebook.vim

" my custom vim plug
source ~/.config/lvim/vim/ssh_command.vim
