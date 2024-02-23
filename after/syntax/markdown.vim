" highlight @unchecked_list_item guifg=#F8F8F2
" highlight @checked_list_item guifg=#375749 gui=strikethrough

" highlight @text.todo.unchecked guifg=#F8F8F2
" highlight @text.todo.checked guifg=#375749

" syntax match markdownHeader1 /^#\ze\s/ conceal cchar=◉
" syntax match markdownHeader2 /^##\ze\s/ conceal cchar=○
" syntax match markdownHeader3 /^###\ze\s/ conceal cchar=✸
" syntax match markdownHeader4 /^####\ze\s/ conceal cchar=✿
syntax match placeholder /<++>\ze/
syntax match quote_type_list /^\s\+\zs>\ze/ conceal nextgroup=@text.quote cchar=┃
syntax match mathematical_symbol /\(^\s\s\s\)\@<![^>\s]>\ze/
syntax match quote_type1 />\ze/ conceal nextgroup=@text.quote cchar=┃
highlight link markdownError Normal
highlight link placeholder Keyword
highlight link mathematical_symbol Normal

syntax match left_brackets /\\\[/ conceal cchar=[
syntax match right_brackets /\\\]/ conceal cchar=]

