let s:current_folder = expand('<sfile>:p:h')
silent exe 'source '.s:current_folder.'/markdown.vim'

nnoremap <buffer> <c-c> :CopilotChatStop<CR>
