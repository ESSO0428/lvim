nnoremap s; :set relativenumber!<CR>
let mapleader = " " " map leader to Space

tnoremap <C-N> <C-\><C-N>
tnoremap <C-O> <C-\><C-N><C-O>

autocmd FileType markdown inoremap <buffer> ,, <++>
                        \| noremap <buffer><LEADER><LEADER> <Esc>/<++><CR>:nohlsearch<CR>"_c4l
                        \| inoremap <buffer> ,c ```<++>```<CR><CR><++><Esc>2ki<CR><Esc>f>a<CR><Esc>2k$a
                        \| inoremap <buffer> ,f <Esc>/<++><CR>:nohlsearch<CR>"_c4l


nnoremap <c-w> :bd<CR>

" Find pair
nnoremap g{ %
nnoremap g} $%
vnoremap g{ %
vnoremap g} $%

" Search
" noremap <LEADER><CR> :nohlsearch<CR>
" Adjacent duplicate words
" noremap <LEADER>dw /\(\<\w\+\>\)\_s*\1


map u <Nop>
nnoremap o o<ESC>
nnoremap u O<ESC>
nnoremap O <Nop>
nnoremap O dd

nnoremap u O<ESC>
nnoremap U ddk
" noremap <c-y> yyp
nnoremap <c-d> "dyyp
" nmap < <<CR>
" nmap > ><CR>

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
" noremap <LEADER>w <C-w>w

" noremap ; :
" nnoremap Q :q<CR>
" nnoremap Q :CocCommand explorer --no-toggle --no-focus<CR>:q<CR>:q<CR>
nnoremap Q :qa<CR>

nnoremap S :w<CR>
" Open the vimrc file anytime
" nnoremap <LEADER>rc :e $HOME/.config/nvim/init.vim<CR>
" nnoremap <LEADER>rv :e .nvimrc<CR>
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
inoremap <c-p> <ESC><CR>

" Search
" noremap <LEADER><CR> :nohlsearch<CR>
" Adjacent duplicate words
nnoremap <LEADER>dw /\(\<\w\+\>\)\_s*\1


" Space to Tab
" nnoremap <LEADER>tt :%s/    /\t/g
" vnoremap <LEADER>tt :s/    /\t/g
" nnoremap <LEADER>st :%s/\t/    /g
" vnoremap <LEADER>st :s/\t/    /g

" Folding
nnoremap <silent> <LEADER>o za
nnoremap <silent> <LEADER>Oa zM
nnoremap <silent> <LEADER>Od zR

vnoremap <silent> <LEADER>o za
vnoremap <silent> <LEADER>Oa zC
vnoremap <silent> <LEADER>Od zO

nnoremap <silent> [{ zk
nnoremap <silent> ]} zj

" insert a pair of {} and go to the next line
" inoremap <c-y> <ESC>A {}<ESC>i<CR><ESC>ko
" inoremap <c-y>   <ESC>pA<ESC>i<CR><ESC>


nnoremap <a-v> <c-v>
" ==================== Cursor Movement ====================
" New cursor movement (the default arrow keys are used for resizing windows)
"     ^
"     u
" < n   i >
"     e
"     v
" colemak keyborad
" noremap <silent> u k
" noremap <silent> n h
" noremap <silent> e j
" noremap <silent> i l

" normal keyborad
nnoremap <silent> i k
nnoremap <silent> j h
nnoremap <silent> k j
" visual keyborad
vnoremap <silent> i k
vnoremap <silent> j h
vnoremap <silent> k j

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
" noremap <LEADER>w <C-w>w
" noremap <LEADER>u <C-w>k
" noremap <LEADER>e <C-w>j
" noremap <LEADER>n <C-w>h
" noremap <LEADER>i <C-w>l
nnoremap qf <C-w>o
" normal keyboard
" noremap <LEADER>i <C-w>k
" noremap <LEADER>k <C-w>j
" noremap <LEADER>j <C-w>h
" noremap <LEADER>l <C-w>l

nnoremap <LEADER>i <C-w>k
nnoremap <LEADER>k <C-w>j
nnoremap <LEADER>j <C-w>h
nnoremap <LEADER>l <C-w>l

nnoremap <LEADER>J <C-w>t
nnoremap <LEADER>n <C-w><C-p>


" Disable the default s key
nnoremap s <nop>
" split the screens to up (horizontal), down (horizontal), left (vertical), right (vertical)
" colemak keyboard
" noremap su :set nosplitbelow<CR>:split<CR>:set splitbelow<CR>
" noremap se :set splitbelow<CR>:split<CR>
" noremap sn :set nosplitright<CR>:vsplit<CR>:set splitright<CR>
" noremap si :set splitright<CR>:vsplit<CR>

" normal keyboard
nnoremap si :set nosplitbelow<CR>:split<CR>:set splitbelow<CR>
nnoremap sk :set splitbelow<CR>:split<CR>
nnoremap sj :set nosplitright<CR>:vsplit<CR>:set splitright<CR>
nnoremap sl :set splitright<CR>:vsplit<CR>



" Resize splits with arrow keys
" noremap <up> :res +5<CR>
" noremap <down> :res -5<CR>
nnoremap <up> :res -5<CR>
nnoremap <down> :res +5<CR>


nnoremap <left> :vertical resize-5<CR>
nnoremap <right> :vertical resize+5<CR>
" Place the two screens up and down
nnoremap sh <C-w>t<C-w>K
" Place the two screens side by side
nnoremap sv <C-w>t<C-w>H
" Rotate screens
nnoremap srh <C-w>b<C-w>K
nnoremap srv <C-w>b<C-w>H

" Press <SPACE> + q to close the window below the current window
" noremap <LEADER>q <C-w>j:q<CR>
" close current window only
nnoremap <LEADER>q :q<CR>
 

" ==================== Tab management ====================
" Create a new tab with tu
" colemak keyboard
" noremap tu :tabe<CR>
" noremap tU :tab split<CR>
" normal keyboard
"
" noremap ti :tabe<CR>
" noremap tI :tab split<CR>
""""" noremap <a-'> :tab split<CR>


" Move around tabs with tn and ti
" colemak keyboard
" noremap tn :-tabnext<CR>
" noremap ti :+tabnext<CR>
" normal keyboard

" noremap tj :-tabnext<CR>
" noremap tl :+tabnext<CR>
""""" noremap <a-,> :-tabnext<CR>
""""" noremap <a-.> :+tabnext<CR>

" Move the tabs with tmn and tmi
" colemak keyboard
" noremap tmn :-tabmove<CR>
" noremap tmi :+tabmove<CR>
" normal keyboard

" noremap tmj :-tabmove<CR>
" noremap tml :+tabmove<CR>
""""" noremap <F6> :-tabmove<CR>
""""" noremap <F7> :+tabmove<CR>

" nmap <LEADER>f "fyaw/<c-r>f<CR>
" nmap <LEADER>F "fyaw/<c-r>f\C<CR>
" nmap <LEADER>h "fyaw:.,$s/<c-r>f//gc<Left><Left><Left>
" nmap <LEADER>H "fyaw:.,$s/<c-r>f\C//gc<Left><Left><Left>

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
nnoremap ,G zG
nnoremap ,g zg
nnoremap ,w zw
nnoremap ,W zW
nnoremap ,uw zuw
nnoremap ,ug zug
nnoremap ,uW zuW
nnoremap ,uG zuG
nnoremap ,= z=
vnoremap ,G zG
vnoremap ,g zg
vnoremap ,w zw
vnoremap ,W zW
vnoremap ,uw zuw
vnoremap ,ug zug
vnoremap ,uW zuW
vnoremap ,uG zuG
vnoremap ,= z=


function! NotNeg(number)
  let min_current_line=1
  let start_line = a:number-30
  if start_line <= 1
     return min_current_line 
  else
     return start_line
  endif
endfunction
" nnoremap <a-m> :let min_cur_line=NotNeg(line('.')) \| exe "!bat -r" min_cur_line.":+60" "%"<CR>
"
" nnoremap <a-m> :let min_cur_line=NotNeg(line('.')) \| exe ":w !tee \| bat -r" min_cur_line.":+60"<CR>
" nnoremap <leader><a-m> :let min_cur_line=NotNeg(line('.')) \| exe ":w !tee \| bat"<CR>
nnoremap <silent> <a-m> :set list!<CR>

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

nnoremap <silent> <leader>gf :call OpenFileUnderCursor("n")<CR>
vnoremap <silent> <leader>gf "fy:call OpenFileUnderCursor("v")<CR>

nnoremap <silent> <Leader>t1 :tabn 1<CR>
nnoremap <silent> <Leader>t2 :tabn 2<CR>
nnoremap <silent> <Leader>t3 :tabn 3<CR>
nnoremap <silent> <Leader>t4 :tabn 4<CR>
nnoremap <silent> <Leader>t5 :tabn 5<CR>
nnoremap <silent> <Leader>t6 :tabn 6<CR>
nnoremap <silent> <Leader>t7 :tabn 7<CR>
nnoremap <silent> <Leader>t8 :tabn 8<CR>
nnoremap <silent> <Leader>t9 :tabn 9<CR>
nnoremap <silent> <Leader>t0 :tablast<CR>
nnoremap <silent> <Leader>t- g<tab> 

nnoremap <silent> <Leader>t' :tab split<CR>
nnoremap <silent> <Leader>t/ :tabn 1<CR>
nnoremap <silent> <Leader>t, :tabprevious<CR>
nnoremap <silent> <Leader>t. :tabnext<CR>
nnoremap <silent> <Leader>t\\ :tabclose<CR>

set isfname+=32
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

nnoremap <silent> <a-h> :call XOpenFileOrFold('n')<CR>
vnoremap <silent> <a-h> "fy:call XOpenFileOrFold('v')<CR>

function! SetWrapKeymaps()
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

    vnoremap <buffer><silent> i gk
    vnoremap <buffer><silent> k gj
    vnoremap <buffer><silent> I 5gk
    vnoremap <buffer><silent> K 5gj
    vnoremap <buffer><silent> J g0
    vnoremap <buffer><silent> L g$
  else
    " 如果 wrap 為 false
    nnoremap <buffer><silent> i k
    nnoremap <buffer><silent> k j
    nnoremap <buffer><silent> I 5k
    nnoremap <buffer><silent> K 5j
    nnoremap <buffer><silent> J 0
    nnoremap <buffer><silent> L $

    vnoremap <buffer><silent> i k
    vnoremap <buffer><silent> k j
    vnoremap <buffer><silent> I 5k
    vnoremap <buffer><silent> K 5j
    vnoremap <buffer><silent> J 0
    vnoremap <buffer><silent> L $
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
    let port = readfile(expand("~/.rssh_tunnel"))[0]
    let nc_connect_command = "nc -z 127.0.0.1 " . port . " && echo sucess"
    let nc_connect_results = substitute(system(nc_connect_command), '\n', '', '')
    if nc_connect_results == 'sucess'
      " 根據模式構建命令
      if a:mode == "insert"
        let command = "echo im-select.exe com.apple.keylayout.ABC | nc -w 0.01 127.0.0.1 " . port
      else
        let command = "echo im-select.exe 1033 | nc -w 0.01 127.0.0.1 " . port
      endif
      let command = command . " &> /dev/null"
      " 執行命令
      call system(command)
    endif
  endif
endfunction

autocmd InsertEnter * call SendInputMethodCommandToLocal("insert")
autocmd InsertLeave * call SendInputMethodCommandToLocal("normal")
