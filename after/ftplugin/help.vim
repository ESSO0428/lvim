" Force modify this help file
nnoremap <buffer> sm :e! %<CR>

augroup HelpAutoHelptags
  autocmd!
  autocmd BufWritePost *.txt call s:MaybeRunHelptags()
augroup END

function! s:MaybeRunHelptags() abort
  " Only proceed if filetype is 'help'
  if &filetype !=# 'help'
    return
  endif

  " Get full file path and doc directory
  let l:filepath = expand('%:p')
  let l:docdir = fnamemodify(l:filepath, ':h')

  " Check if file is in a doc directory
  if l:docdir =~# '/doc\(/\|$\)'
    let l:answer = input("Run helptags for: " . l:docdir . " ? (yes/[no]): ")
    if l:answer ==? 'yes' || l:answer ==? 'y'
      silent! execute 'helptags' fnameescape(l:docdir)
      echo "\nhelptags updated for " . l:docdir
    endif
  endif
endfunction
