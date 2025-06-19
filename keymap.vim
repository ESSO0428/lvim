nnoremap s; :set relativenumber!<cr>
let mapleader = " " " map leader to Space

tnoremap <C-N> <C-\><C-N>
tnoremap <C-O> <C-\><C-N><C-O>

autocmd FileType markdown inoremap <buffer> ,, <++>
                        \| noremap <buffer><leader><leader> <Esc>/<++><cr>:nohlsearch<cr>"_c4l
                        \| inoremap <buffer> ,c ```<++>```<cr><cr><++><Esc>2ki<cr><Esc>f>a<cr><Esc>2k$a
                        \| inoremap <buffer> ,f <Esc>/<++><cr>:nohlsearch<cr>"_c4l

let g:SetWrapKeymapExcludeArray = ['minifiles']

" Markdown code block text object
vnoremap <silent> hc :<C-U>call <SID>MdCodeBlockTextObj('i')<cr>
vnoremap <silent> ,c :<C-U>call <SID>MdCodeBlockTextObj('i')<cr>
" vnoremap <silent> o :<C-U>call <SID>MdCodeBlockTextObj('i')<cr>
onoremap <silent> hc :<C-U>call <SID>MdCodeBlockTextObj('i')<cr>
onoremap <silent> ,c :<C-U>call <SID>MdCodeBlockTextObj('i')<cr>
"" onoremap <silent> o :<C-U>call <SID>MdCodeBlockTextObj('i')<cr>
nnoremap <silent> yo :<C-U>call <SID>YankMarkdownCodeBlockOuter('i')<cr>

vnoremap <silent> ac :<C-U>call <SID>MdCodeBlockTextObj('a')<cr>
" vnoremap <silent> O :<C-U>call <SID>MdCodeBlockTextObj('a')<cr>
onoremap <silent> ac :<C-U>call <SID>MdCodeBlockTextObj('a')<cr>
"" onoremap <silent> O :<C-U>call <SID>MdCodeBlockTextObj('a')<cr>
nnoremap <silent> yO :<C-U>call <SID>YankMarkdownCodeBlockOuter('a')<cr>

function! s:MdCodeBlockTextObj(type) abort
  " the parameter type specify whether it is inner text objects or arround
  " text objects.
  let start_pos = searchpos('\s*\zs```', 'bn')
  let end_pos = searchpos('\s*\zs```', 'n')
  let start_row = start_pos[0]
  let start_col = start_pos[1]
  let end_row = end_pos[0]
  let end_col = end_pos[1]

  " Check if valid positions are found
  if start_row == 0 || end_row == 0 || start_row >= end_row
    return
  endif

  let code_block_upper_left = start_col
  let code_block_lower_right = end_col
  if a:type ==# 'i'
    let start_row += 1
    let end_row -= 1
    let code_block_lower_right = len(getline(end_row)) + 1
  endif
  " echo a:type start_row end_row

  call setpos("'<", [0, start_row, code_block_upper_left, 0])
  call setpos("'>", [0, end_row, code_block_lower_right, 0])
  execute "normal! `<\<C-v>`>$"
endfunction

function! s:YankMarkdownCodeBlockOuter(type) abort
  call <SID>MdCodeBlockTextObj(a:type)
  
  " Yank the visually selected code block (visual-block mode) into both:
  " - the system clipboard (used for external Ctrl-V pasting),
  " - and Vim's unnamed register (used for internal `p` pasting).
  "
  " The system clipboard does not preserve block selection structure, so Ctrl-V pastes
  " the text as plain lines with line breaks — which is acceptable.
  "
  " However, Vim’s unnamed register (`"`) *does* preserve block structure (blockwise-mode),
  " meaning `p` would paste the block to the right of the cursor instead of on its own lines.
  "
  " To correct this, we later extract the selected lines via marks `<` and `>`, apply
  " linewise cleanup (e.g., trim indentation), and overwrite only Vim’s unnamed register
  " using `setreg()`. The system clipboard remains untouched, which is desirable.
  noautocmd normal! y
  
  let winid = win_getid()
  let [_, start_lnum, start_col, _] = getpos("'<")
  let [_, end_lnum, end_col, _] = getpos("'>")

  call feedkeys("\<Esc>", 'n')

  let lines = getline(start_lnum, end_lnum)

  for i in range(len(lines))
    let lines[i] = lines[i][start_col - 1 :]
  endfor

  call setreg('"', lines, 'l')
  doautocmd TextYankPost

  " highlight the yank code block 
  try
    let pattern = '\%>' . (start_lnum - 1) . 'l\%>' . (start_col - 1) . 'c' .
              \ '\%<' . (end_lnum + 1) . 'l\%<' . (end_col + 1) . 'c'

    let id = matchadd('IncSearch', pattern)

    call timer_start(200, { -> win_execute(winid, 'call matchdelete(' . id . ')') })
  catch
  endtry
endfunction

nnoremap <c-w> :bd<cr>

" Find pair
nnoremap g{ %
nnoremap g} $%
vnoremap g{ %
vnoremap g} $%

" Search
" nnoremap <leader><cr> :nohlsearch<cr>

map u <Nop>
nnoremap o o<ESC>
nnoremap u O<ESC>
nnoremap O <Nop>
nnoremap O "_dd

nnoremap u O<ESC>
nnoremap U "_ddk

nnoremap <c-d> "dyyp
nnoremap <a-i> <c-u>
nnoremap <a-k> <c-d>

nnoremap x "_x
nnoremap <leader>d "_d
nnoremap <leader>dD "_dd
nnoremap <leader>D "_D
nnoremap <leader>c "_c
nnoremap <leader>C "_C
vnoremap <leader>d "_d
vnoremap <leader>D "_D
vnoremap <leader>c "_c
vnoremap <leader>C "_C

" nnoremap <c-n> <tab>
nnoremap <Tab> >>_
nnoremap <S-Tab> <<_
inoremap <S-Tab> <C-D>
" inoremap <S-Tab> <CD>
vnoremap <Tab> >gv
vnoremap <S-Tab> <gv

" nnoremap <leader>y yaw
" nnoremap <leader>w vaw
" ==================== Window management ====================
nnoremap Q :qa<cr>

nnoremap S :w<cr>
nnoremap sa :wa<cr>
" Open the vimrc file anytime
" nnoremap <leader>rc :e $HOME/.config/nvim/init.vim<cr>
" Undo operations
" normal keyboard
nnoremap z u
" Append Key
noremap h i
noremap H I

" remap z relationship keymaps
nnoremap <leader>z z

" Search
" nnoremap <leader><cr> :nohlsearch<cr>

" Folding
nnoremap <silent> <leader>o za
nnoremap <silent> <leader>Oa zM
nnoremap <silent> <leader>Od zR

vnoremap <silent> <leader>o za
vnoremap <silent> <leader>Oa zC
vnoremap <silent> <leader>Od zO

nnoremap <silent> [{ zk
nnoremap <silent> ]} zj
nnoremap <silent> <c-HOME> zk
nnoremap <silent> <c-END> zj
nnoremap <silent> <a-[> zk
nnoremap <silent> <a-]> zj

nnoremap <a-v> <c-v>
" ==================== Cursor Movement ====================
" New cursor movement (the default arrow keys are used for resizing windows)
"     ^
"     i
" < j   l >
"     k
"     v
" normal keyborad
nnoremap <silent> i k
nnoremap <silent> j h
nnoremap <silent> k j
" visual keyborad
" nowait (solution for the delay problem when plugin conflict)
vnoremap <silent><nowait> i k
vnoremap <silent><nowait> j h
vnoremap <silent><nowait> k j

noremap <silent> gi gk
noremap <silent> gk gj
vnoremap <silent> gi gk
vnoremap <silent> gk gj

" remap gi (go to last insert position)
noremap <silent> ss gi

" 覆蓋 i, k 成 gk, gj 
" nnoremap <silent> i gk
" nnoremap <silent> k gj

" U/E keys for 5 times u/e (faster navigation)
noremap <silent> I 5k
noremap <silent> K 5j
vnoremap <silent> I 5k
vnoremap <silent> K 5j

" 覆蓋 I, K 成 5gk, 5gj 
" nnoremap <silent> I 5gk
" nnoremap <silent> K 5gj

" N key: go to the start of the line
nnoremap <silent> J 0
vnoremap <silent> J 0

nnoremap <silent> L $
vnoremap <silent> L $

" noremap <silent> J g0
" noremap <silent> L g$

" Faster insert to normal mode
" inoremap <a-j> <esc>
inoremap <a-J> <esc>
nnoremap <a-J> <nop>
" ==================== Insert Mode Cursor Movement ====================
inoremap <a-n> <Up>
inoremap <a-m> <Down>
inoremap <a-,> <Left>
inoremap <a-.> <Right>
" ==================== Window management ====================
" Use <space> + new arrow keys for moving the cursor around windows
nnoremap qf <C-w>o
" NOTE: feat: fixed buffer to windows of neovim-0.10
nnoremap qw :setlocal winfixbuf!<cr>
nnoremap <leader>i <C-w>k
nnoremap <leader>k <C-w>j
nnoremap <leader>j <C-w>h
nnoremap <leader>l <C-w>l

nnoremap <leader>J <C-w>t
nnoremap <leader>n <C-w><C-p>


" Disable the default s key
nnoremap s <nop>
" split the screens to up (horizontal), down (horizontal), left (vertical), right (vertical)
nnoremap si :above split<cr>
nnoremap sk :below split<cr>
nnoremap sj :leftabove vsplit<cr>
nnoremap sl :rightbelow vsplit<cr>

nnoremap sI :wincmd K<cr>
nnoremap sK :wincmd J<cr>
nnoremap sJ :wincmd H<cr>
nnoremap sL :wincmd L<cr>
nnoremap sT :wincmd T<cr>



" Resize splits with arrow keys
nnoremap <up> :res -5<cr>
nnoremap <down> :res +5<cr>
nnoremap <left> :vertical resize-5<cr>
nnoremap <right> :vertical resize+5<cr>

" close current window only
nnoremap <leader>q :q<cr>
" ==================== Tab management ====================
" Create a new tab with tu
" colemak keyboard
" noremap tu :tabe<cr>
" noremap tU :tab split<cr>
" normal keyboard
"
" noremap ti :tabe<cr>
" noremap tI :tab split<cr>
""""" noremap <a-'> :tab split<cr>


" Move around tabs with tn and ti
" colemak keyboard
" noremap tn :-tabnext<cr>
" noremap ti :+tabnext<cr>
" normal keyboard

" noremap tj :-tabnext<cr>
" noremap tl :+tabnext<cr>
""""" noremap <a-,> :-tabnext<cr>
""""" noremap <a-.> :+tabnext<cr>

" Move the tabs with tmn and tmi
" colemak keyboard
" noremap tmn :-tabmove<cr>
" noremap tmi :+tabmove<cr>
" normal keyboard

" noremap tmj :-tabmove<cr>
" noremap tml :+tabmove<cr>
" ==================== tabular ====================
vmap ga   :Tabularize /
" vmap g= :Tabularize /^[^=]*\zs=
" vmap g= :Tabularize /\zs[=<>/!]\@<!=[=<>/!]\@!.*/
" vmap g; :Tabularize /^[^:]*\zs:
vmap g=   :GTabularize /\zs[=<>/!]\@<!=[=<>/!]\@!.*/l1
vmap g;   :GTabularize /^[^:]*\zs:/l1
vmap gr;  :GTabularize /:\zs/l0l1
vmap g:   :GTabularize /^[^:]*\zs:$/l0
vmap gt   :GTabularize / <c-r>0 /l0
" ==================== other ====================
vnoremap Y "+y
vnoremap <leader><c-c> "+y
vnoremap <leader><c-x> "+d
nnoremap gj J
vnoremap gj J
nnoremap <a-a> <c-x>
nnoremap <a-d> <c-a>
" ==================== spell ====================
nnoremap s,G zG
nnoremap s,g zg
nnoremap s,w zw
nnoremap s,W zW
nnoremap s,uw zuw
nnoremap s,ug zug
nnoremap s,uW zuW
nnoremap s,uG zuG
nnoremap s,= z=
vnoremap s,G zG
vnoremap s,g zg
vnoremap s,w zw
vnoremap s,W zW
vnoremap s,uw zuw
vnoremap s,ug zug
vnoremap s,uW zuW
vnoremap s,uG zuG
vnoremap s,= z=
" ===
nnoremap <silent> <a-m> :set list!<cr>
" indent
nnoremap <silent> se :set expandtab!<cr>:echo "tab indent: " . (!&expandtab ? "on" : "off")<cr>
" === gf control ===
autocmd BufEnter * if expand('%') != '' | set path=.,%:h | endif
nnoremap sF <c-w>F
nnoremap sf <c-w>f
nnoremap sgk <c-w>f
nnoremap sgl <c-w>vgf
nnoremap sgF <c-w>gF
nnoremap sgf <c-w>gf

function! OpenFileUnderCursor(window_command)
  if a:window_command == 'v'
    let cfile = getreg('f')
  else
    let cfile = expand('<cfile>')
  endif
  execute 'edit ' . cfile
endfunction

nnoremap <silent> <leader>gf :call OpenFileUnderCursor("n")<cr>
vnoremap <silent> <leader>gf "fy:call OpenFileUnderCursor("v")<cr>

nnoremap <silent> <leader>t1 :tabn 1<cr>
nnoremap <silent> <leader>t2 :tabn 2<cr>
nnoremap <silent> <leader>t3 :tabn 3<cr>
nnoremap <silent> <leader>t4 :tabn 4<cr>
nnoremap <silent> <leader>t5 :tabn 5<cr>
nnoremap <silent> <leader>t6 :tabn 6<cr>
nnoremap <silent> <leader>t7 :tabn 7<cr>
nnoremap <silent> <leader>t8 :tabn 8<cr>
nnoremap <silent> <leader>t9 :tabn 9<cr>
nnoremap <silent> <leader>t0 :tablast<cr>
nnoremap <silent> <leader>t- g<tab> 

nnoremap <silent> <leader>t' :tab split<cr>
nnoremap <silent> <leader>t/ :tabn 1<cr>
nnoremap <silent> <leader>t, :tabprevious<cr>
nnoremap <silent> <leader>t. :tabnext<cr>
nnoremap <silent> <leader>t\\ :tabclose<cr>

" set isfname+=32
function! XOpenFileOrFold(mode)
  let cfile = ''
  if a:mode == 'v'
    let cfile = getreg('f')
  else
    let cfile = expand('<cfile>')
  endif

  let path = trim(cfile)
  if path[0] == '~'
    let path = expand('~') . path[1:]
  endif
  if path[:3] == 'http'
    let command = printf("silent !xdg-open '%s'", path)
    execute command
  else
    if executable('explorer.exe') == 1
      let command = printf("silent !explorer.exe `wslpath -w '%s'`", path)
      execute command
    else
      let command = printf("silent !xdg-open '%s'", path)
      execute command
    endif
  endif
endfunction

nnoremap <silent> <a-h> :call XOpenFileOrFold('n')<cr>
vnoremap <silent> <a-h> "fy:call XOpenFileOrFold('v')<cr>

function! SetWrapKeymaps()
  if index(g:SetWrapKeymapExcludeArray, &ft) >= 0
    return
  endif
  if exists('b:venn_enabled') && b:venn_enabled
    return
  endif
  if &wrap
    " 如果 wrap 為 true
    nnoremap <buffer><silent> i gk
    nnoremap <buffer><silent> k gj
    nnoremap <buffer><silent> I 5gk
    nnoremap <buffer><silent> K 5gj
    nnoremap <buffer><silent> J g0
    nnoremap <buffer><silent> L g$

    " vnoremap <buffer><silent> i gk
    " vnoremap <buffer><silent> i gk
    " vnoremap <buffer><silent> k gj
    " vnoremap <buffer><silent> I 5gk
    " vnoremap <buffer><silent> K 5gj
    " vnoremap <buffer><silent> J g0
    " vnoremap <buffer><silent> L g$
    " nowait (solution for the delay problem when plugin conflict)
    vnoremap <buffer><silent><nowait> i gk
    vnoremap <buffer><silent><nowait> k gj
    vnoremap <buffer><silent><nowait> I 5gk
    vnoremap <buffer><silent><nowait> K 5gj
    vnoremap <buffer><silent><nowait> J g0
    vnoremap <buffer><silent><nowait> L g$
  else
    " 如果 wrap 為 false
    nnoremap <buffer><silent> i k
    nnoremap <buffer><silent> k j
    nnoremap <buffer><silent> I 5k
    nnoremap <buffer><silent> K 5j
    nnoremap <buffer><silent> J 0
    nnoremap <buffer><silent> L $

    " vnoremap <buffer><silent> i k
    " vnoremap <buffer><silent> k j
    " vnoremap <buffer><silent> I 5k
    " vnoremap <buffer><silent> K 5j
    " vnoremap <buffer><silent> J 0
    " vnoremap <buffer><silent> L $
    " nowait (solution for the delay problem when plugin conflict)
    vnoremap <buffer><silent><nowait> i k
    vnoremap <buffer><silent><nowait> k j
    vnoremap <buffer><silent><nowait> I 5k
    vnoremap <buffer><silent><nowait> K 5j
    vnoremap <buffer><silent><nowait> J 0
    vnoremap <buffer><silent><nowait> L $
  endif
endfunction

" 每次切換緩衝區或打開新文件時執行 SetWrapKeymaps 函數
autocmd BufEnter * call SetWrapKeymaps()
autocmd OptionSet wrap call SetWrapKeymaps()

function! SendInputMethodCommandToLocal(mode)
  " NOTE: 這裡引入 exclude filetpe 排除 im-select 在 nvimtree 和 telescope 交互時的會造成的 window-picker 的開檔錯誤
  if &ft == 'TelescopePrompt'
    return
  endif
  " 檢查~/.rssh_tunnel文件是否存在
  if filereadable(expand("~/.rssh_tunnel"))
    " 讀取文件內容以獲取端口號
    let file_content = readfile(expand("~/.rssh_tunnel"))
    if len(file_content) > 0
      let port = file_content[0]
      let netstat_connect_command = "netstat -tuln | grep -q '127.0.0.1:" . port . "' && echo success"
      let nc_connect_results = substitute(system(netstat_connect_command), '\n', '', '')
      if nc_connect_results == 'success'
        " 根據模式構建命令
        if a:mode == "insert"
          " NOTE: 修改原先的 -w 0.01 版本為 -w 1，最多等待一秒
          let command = "echo im-select.exe com.apple.keylayout.ABC | nc -w 1 127.0.0.1 " . port
        else
          let command = "echo im-select.exe 1033 | nc -w 1 127.0.0.1 " . port
        endif
        let command = command . " &> /dev/null"
        " 執行命令
        " NOTE: 修改原先的 system 成 jobstart，以避免阻塞 vim (這樣即使是 1 秒的 nc 也不會影響 vim 的使用體驗
        call jobstart([&shell, &shellcmdflag, command . " &> /dev/null &"])
      endif
    endif
  endif
endfunction

autocmd InsertEnter * call SendInputMethodCommandToLocal("insert")
autocmd InsertLeave * call SendInputMethodCommandToLocal("normal")
