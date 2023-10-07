function! DownloadToLocal(file)
  " 去除外部參數左右的空白
  let file = substitute(a:file, '^\s*\|\s*$', '', 'g')

  if empty(file)
    " 如果外部參數為空或只包含空白，使用當前文件的路徑
    let current_file = expand("%:p")
  else
    " 如果外部參數不為空，使用外部參數作為文件名
    let current_file = file
  endif

  if filereadable(expand("~/.rssh_tunnel"))
    " 讀取文件內容以獲取端口號
    let port = readfile(expand("~/.rssh_tunnel"))[0]
    let nc_connect_command = "nc -z 127.0.0.1 " . port . " && echo sucess"
    let nc_connect_results = substitute(system(nc_connect_command), '\n', '', '')
    if nc_connect_results == 'sucess'
      echo "Downloading this file or directory to your Windows local download folder of Windows PC"
      
      " 使用 whoami 命令获取当前用户
      let user = substitute(system('whoami'), '\n', '', '')
      " 使用 hostname -I 命令获取服务器IP（假设您的服务器只有一个IP）
      let server_ip = substitute(system("hostname -I | awk \'{print $1}\'"), '\n', '', '')
      
      " 檢查要下載的是文件還是目錄
      if isdirectory(current_file)
        let scp_command = "scp -r " . user . "@" . server_ip . ":" . current_file . " /mnt/c/Users/\"$(wslvar USERNAME)\"/Downloads/ >/dev/null 2>&1"
      else
        let scp_command = "scp " . user . "@" . server_ip . ":" . current_file . " /mnt/c/Users/\"$(wslvar USERNAME)\"/Downloads/ >/dev/null 2>&1"
      endif

      let scp_and_open_command = scp_command . " && " . "explorer.exe $(wslpath -w '/mnt/c/Users/'$(wslvar USERNAME)'/Downloads/') >/dev/null 2>&1"
      let scp_and_open_command = "echo" . " '" . scp_and_open_command . "'" . " | nc -w 0.01 127.0.0.1 " . port . " &"
      call system(scp_and_open_command)
    else
      echo "Reverse SSH tunnel is not running"
    endif
  endif
endfunction

" 创建自定义命令，例如 :DownloadToLocal 文件名或目錄名
command! -nargs=? DownloadToLocal :call DownloadToLocal(<q-args>)
