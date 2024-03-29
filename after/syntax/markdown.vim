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

let s:concealends = ''
if has('conceal') && get(g:, 'markdown_syntax_conceal', 1) == 1
  let s:concealends = ' concealends'
endif
syn clear markdownCode
syn clear markdownCodeBlock
syn clear markdownBlockquote
syn clear markdownItalic
syn clear markdownBoldItalic
syn clear markdownBold
exe 'syn region markdownItalic matchgroup=markdownItalicDelimiter start="^\s*>\@!\*\S\@=" end="\S\@<=\*\|^$" skip="\\\*" contains=markdownLineStart,@Spell' . s:concealends
exe 'syn region markdownItalic matchgroup=markdownItalicDelimiter start="^\s*>\@!\w\@<!_\S\@=" end="\S\@<=_\w\@!\|^$" skip="\\_" contains=markdownLineStart,@Spell' . s:concealends
exe 'syn region markdownBoldItalic matchgroup=markdownBoldItalicDelimiter start="^\s*>\@!\*\*\*\S\@=" end="\S\@<=\*\*\*\|^$" skip="\\\*" contains=markdownLineStart,@Spell' . s:concealends
exe 'syn region markdownBoldItalic matchgroup=markdownBoldItalicDelimiter start="^\s*>\@!\w\@<!___\S\@=" end="\S\@<=___\w\@!\|^$" skip="\\_" contains=markdownLineStart,@Spell' . s:concealends
exe 'syn region markdownBold matchgroup=markdownBoldDelimiter start="^\s*>\@!\*\*\S\@=" end="\S\@<=\*\*\|^$" skip="\\\*" contains=markdownLineStart,markdownItalic,@Spell' . s:concealends
exe 'syn region markdownBold matchgroup=markdownBoldDelimiter start="^\s*>\@!\w\@<!__\S\@=" end="\S\@<=__\w\@!\|^$" skip="\\_" contains=markdownLineStart,markdownItalic,@Spell' . s:concealends
