vim.cmd([[
  command! Free silent! exec "!killall fd rg"
  command! Bro silent! exec "!/mnt/c/Program\\ Files\\ \\(x86\\)/Google/Chrome/Application/chrome.exe http://localhost:8000  --incognito"
  " command! Rcode exec "lua rcode()"
  " command! Code silent! exec "lua code()"
  command! ColorPicker silent! exec "Pickachu"
  " command! -nargs=1 Open call OpenExplorer(<q-args>)
  command! -nargs=* -complete=customlist,OpenComplete Open call OpenExplorer(<q-args>)
  " command! Code silent! exec "lua require('export-to-vscode').launch()"
]])
vim.cmd([[
function! OpenExplorer(path)
  if executable("explorer.exe")
    let command = "silent !explorer.exe `wslpath -w '".a:path."'`"
  else
    let command = "silent !xdg-open '".a:path."'"
  endif
  execute command
endfunction

" 定義完成函數
function! OpenComplete(ArgLead, CmdLine, CursorPos)
  " 根據光標位置判斷是否需要目錄或檔案完成
  if a:CursorPos == 1 || getline('.')[a:CursorPos-2] =~# '\s'
    return glob(a:ArgLead.'*', 1, 1)
  else
    return glob(a:ArgLead.'*', 0, 1)
  endif
endfunction
]])

vim.api.nvim_create_user_command('Code', 'silent! lua code(<q-args>)', { nargs = "*" })
vim.api.nvim_create_user_command('Rcode', 'silent! lua rcode(<q-args>)', { nargs = "*" })
