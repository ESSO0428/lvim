" highlight @unchecked_list_item guifg=#F8F8F2
" highlight @checked_list_item guifg=#375749 gui=strikethrough

" highlight @text.todo.unchecked guifg=#F8F8F2
" highlight @text.todo.checked guifg=#375749

" syntax match markdownHeader1 /^#\ze\s/ conceal cchar=◉
" syntax match markdownHeader2 /^##\ze\s/ conceal cchar=○
" syntax match markdownHeader3 /^###\ze\s/ conceal cchar=✸
" syntax match markdownHeader4 /^####\ze\s/ conceal cchar=✿
syntax match qut />\ze/ conceal nextgroup=@text.quote cchar=|

