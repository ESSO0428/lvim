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
vnoremap <silent> o :<C-U>call <SID>MdCodeBlockTextObj('i')<cr>
onoremap <silent> hc :<C-U>call <SID>MdCodeBlockTextObj('i')<cr>
onoremap <silent> ,c :<C-U>call <SID>MdCodeBlockTextObj('i')<cr>
" onoremap <silent> o :<C-U>call <SID>MdCodeBlockTextObj('i')<cr>
nnoremap <silent> yo :<C-U>call <SID>MdCodeBlockTextObj('i')<cr>y

vnoremap <silent> ac :<C-U>call <SID>MdCodeBlockTextObj('a')<cr>
vnoremap <silent> O :<C-U>call <SID>MdCodeBlockTextObj('a')<cr>
onoremap <silent> ac :<C-U>call <SID>MdCodeBlockTextObj('a')<cr>
" onoremap <silent> O :<C-U>call <SID>MdCodeBlockTextObj('a')<cr>
nnoremap <silent> yO :<C-U>call <SID>MdCodeBlockTextObj('a')<cr>y

function! s:MdCodeBlockTextObj(type) abort
  " the parameter type specify whether it is inner text objects or arround
  " text objects.
  let start_row = searchpos('\s*```', 'bn')[0]
  let end_row = searchpos('\s*```', 'n')[0]

  " Check if valid positions are found
  if start_row == 0 || end_row == 0 || start_row >= end_row
    return
  endif

  if a:type ==# 'i'
    let start_row += 1
    let end_row -= 1
  endif
  " echo a:type start_row end_row

  call setpos("'<", [0, start_row, 1, 0])
  call setpos("'>", [0, end_row, 1, 0])
  execute 'normal! `<V`>'
endfunction


nnoremap <c-w> :bd<cr>

" Find pair
nnoremap g{ %
nnoremap g} $%
vnoremap g{ %
vnoremap g} $%

" Search
" noremap <leader><cr> :nohlsearch<cr>
" Adjacent duplicate words
" noremap <leader>dw /\(\<\w\+\>\)\_s*\1


map u <Nop>
nnoremap o o<ESC>
nnoremap u O<ESC>
nnoremap O <Nop>
nnoremap O "_dd

nnoremap u O<ESC>
nnoremap U "_ddk
" noremap <c-y> yyp
nnoremap <c-d> "dyyp
nnoremap <a-i> <c-u>
nnoremap <a-k> <c-d>
" nmap < <<cr>
" nmap > ><cr>
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

" cw is delete + insert (now add <>)
" nmap <silent> cw cw<ESC>
" dw is just delete


" nmap <a-y> yaw
" nmap <a-w> vaw
" nmap <leader>y yaw
" nmap <leader>w vaw

" comment below code
" ==================== Window management ====================
" Use <space> + new arrow keys for moving the cursor around windows
" colemak keyboard
" noremap <leader>w <C-w>w

" noremap ; :
" nnoremap Q :q<cr>
" nnoremap Q :CocCommand explorer --no-toggle --no-focus<cr>:q<cr>:q<cr>
nnoremap Q :qa<cr>

nnoremap S :w<cr>
" Open the vimrc file anytime
" nnoremap <leader>rc :e $HOME/.config/nvim/init.vim<cr>
" nnoremap <leader>rv :e .nvimrc<cr>
" Undo operations
" colemak keyboard
" noremap l u
" normal keyboard
nnoremap z u
" Insert Key
" noremap m a
" noremap M A
" noremap h a
" noremap H A
noremap h i
noremap H I


" noremap <a-[> i
" noremap <a-{> I
" noremap <a-]> a
" noremap <a-}> A


" noremap <a-a> i
" noremap <a-A> I
" noremap <a-d> a
" noremap <a-D}> A

" noremap <a-a> a
" noremap <a-A> A
inoremap <a-c> <ESC>

snoremap <BS> <C-O>s
snoremap <a-c> <C-O>s

" noremap a i
" noremap A I
" Copy to system clipboard
vnoremap Y "+y
vnoremap <leader><c-c> "+y
vnoremap <leader><c-x> "+d
imap <c-p> <c-r>"p
inoremap <c-p> <ESC><cr>

" Search
" noremap <leader><cr> :nohlsearch<cr>
" Adjacent duplicate words
nnoremap <leader>dw /\(\<\w\+\>\)\_s*\1


" Space to Tab
" nnoremap <leader>tt :%s/    /\t/g
" vnoremap <leader>tt :s/    /\t/g
" nnoremap <leader>st :%s/\t/    /g
" vnoremap <leader>st :s/\t/    /g

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

" insert a pair of {} and go to the next line
" inoremap <c-y> <ESC>A {}<ESC>i<cr><ESC>ko
" inoremap <c-y>   <ESC>pA<ESC>i<cr><ESC>


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
" vnoremap <silent> i k
" vnoremap <silent> j h
" vnoremap <silent> k j
" nowait (solution for the delay problem when plugin conflict)
vnoremap <silent><nowait> i k
vnoremap <silent><nowait> j h
vnoremap <silent><nowait> k j

" noremap <silent> l l

" colemak keyborad
" noremap <silent> gu gk
" noremap <silent> ge gj
nnoremap <silent> \v v$h

" normal keyborad
noremap <silent> gi gk
noremap <silent> gk gj
" visual keyborad
vnoremap <silent> gi gk
vnoremap <silent> gk gj

" 覆蓋 i, k 成 gk, gj 
" noremap <silent> i gk
" noremap <silent> k gj

" U/E keys for 5 times u/e (faster navigation)
" colemak keyborad
" noremap <silent> U 5k
" noremap <silent> E 5j

" normal keyborad
noremap <silent> I 5k
noremap <silent> K 5j
" visual keyborad
vnoremap <silent> I 5k
vnoremap <silent> K 5j

" 覆蓋 I, K 成 5gk, 5gj 
" noremap <silent> I 5gk
" noremap <silent> K 5gj

" N key: go to the start of the line
" colemak keyborad
" noremap <silent> N 0

" normal keyborad
nnoremap <silent> J 0
" visual keyborad
vnoremap <silent> J 0

" I key: go to the end of the line
" colemak keyborad
" noremap <silent> I $

" normal keyborad
nnoremap <silent> L $
" visual keyborad
vnoremap <silent> L $

" noremap <silent> J g0
" noremap <silent> L g$

" Faster in-line navigation
nnoremap W 5w
nnoremap E 5e
nnoremap B 5b
vnoremap W 5w
vnoremap E 5e
vnoremap B 5b

" set h (same as n, cursor left) to 'end of word'
" noremap h e
" noremap h e
" Ctrl + U or E will move up/down the view port without moving the cursor
" colemak keyborad
" noremap <C-U> 5<C-y>
" noremap <C-E> 5<C-e>
" normal Keyborad

nmap <C-i> <Nop> 
noremap <C-I> 5<C-y>
noremap <C-K> 5<C-e>

" colemak keyborad
" Custom cursor movement
" source $HOME/.config/nvim/cursor.vim
" normal Keyborad
" If you use Qwerty keyboard, uncomment the next line.



" ==================== Insert Mode Cursor Movement ====================
inoremap <C-a> <ESC>A

inoremap <a-n> <Up>
inoremap <a-m> <Down>
inoremap <a-,> <Left>
inoremap <a-.> <Right>

" ==================== Command Mode Cursor Movement ====================
cnoremap <C-a> <Home>
cnoremap <C-e> <End>
cnoremap <C-p> <Up>
cnoremap <C-n> <Down>
cnoremap <C-b> <Left>
cnoremap <C-f> <Right>
cnoremap <M-b> <S-Left>
cnoremap <M-w> <S-Right>

" ==================== Window management ====================
" Use <space> + new arrow keys for moving the cursor around windows
" colemak keyboard
" noremap <leader>w <C-w>w
" noremap <leader>u <C-w>k
" noremap <leader>e <C-w>j
" noremap <leader>n <C-w>h
" noremap <leader>i <C-w>l
nnoremap qf <C-w>o
" NOTE: feat: fixed buffer to windows of neovim-0.10
nnoremap qw :setlocal winfixbuf!<cr>
" normal keyboard
" noremap <leader>i <C-w>k
" noremap <leader>k <C-w>j
" noremap <leader>j <C-w>h
" noremap <leader>l <C-w>l

nnoremap <leader>i <C-w>k
nnoremap <leader>k <C-w>j
nnoremap <leader>j <C-w>h
nnoremap <leader>l <C-w>l

nnoremap <leader>J <C-w>t
nnoremap <leader>n <C-w><C-p>


" Disable the default s key
nnoremap s <nop>
" split the screens to up (horizontal), down (horizontal), left (vertical), right (vertical)
" colemak keyboard
" noremap su :set nosplitbelow<cr>:split<cr>:set splitbelow<cr>
" noremap se :set splitbelow<cr>:split<cr>
" noremap sn :set nosplitright<cr>:vsplit<cr>:set splitright<cr>
" noremap si :set splitright<cr>:vsplit<cr>

" normal keyboard
nnoremap si :set nosplitbelow<cr>:split<cr>:set splitbelow<cr>
nnoremap sk :set splitbelow<cr>:split<cr>
nnoremap sj :set nosplitright<cr>:vsplit<cr>:set splitright<cr>
nnoremap sl :set splitright<cr>:vsplit<cr>



" Resize splits with arrow keys
" noremap <up> :res +5<cr>
" noremap <down> :res -5<cr>
nnoremap <up> :res -5<cr>
nnoremap <down> :res +5<cr>


nnoremap <left> :vertical resize-5<cr>
nnoremap <right> :vertical resize+5<cr>
" Place the two screens up and down
nnoremap sh <C-w>t<C-w>K
" Place the two screens side by side
nnoremap sv <C-w>t<C-w>H
" Rotate screens
nnoremap srh <C-w>b<C-w>K
nnoremap srv <C-w>b<C-w>H

" Press <SPACE> + q to close the window below the current window
" noremap <leader>q <C-w>j:q<cr>
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
""""" noremap <F6> :-tabmove<cr>
""""" noremap <F7> :+tabmove<cr>

" nmap <leader>f "fyaw/<c-r>f<cr>
" nmap <leader>F "fyaw/<c-r>f\C<cr>
" nmap <leader>h "fyaw:.,$s/<c-r>f//gc<Left><Left><Left>
" nmap <leader>H "fyaw:.,$s/<c-r>f\C//gc<Left><Left><Left>

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


function! NotNeg(number)
  let min_current_line=1
  let start_line = a:number-30
  if start_line <= 1
     return min_current_line 
  else
     return start_line
  endif
endfunction
" nnoremap <a-m> :let min_cur_line=NotNeg(line('.')) \| exe "!bat -r" min_cur_line.":+60" "%"<cr>
"
" nnoremap <a-m> :let min_cur_line=NotNeg(line('.')) \| exe ":w !tee \| bat -r" min_cur_line.":+60"<cr>
" nnoremap <leader><a-m> :let min_cur_line=NotNeg(line('.')) \| exe ":w !tee \| bat"<cr>
nnoremap <silent> <a-m> :set list!<cr>

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
      let nc_connect_command = "nc -z 127.0.0.1 " . port . " && echo sucess"
      let nc_connect_results = substitute(system(nc_connect_command), '\n', '', '')
      if nc_connect_results == 'sucess'
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
