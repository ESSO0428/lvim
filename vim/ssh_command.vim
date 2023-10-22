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



function! UpdateRegisterHostHameFromLocal()
  let host_names_file = "~/.ssh/host_names"
  let return_info = CheckHostNames(host_names_file, 'checkHostNameFile')
  if return_info == 'user_stop_update'
    return
  endif
  if filereadable(expand("~/.rssh_tunnel"))
    " 讀取文件內容以獲取端口號
    let port = readfile(expand("~/.rssh_tunnel"))[0]
    let nc_connect_command = "nc -z 127.0.0.1 " . port . " && echo sucess"
    let nc_connect_results = substitute(system(nc_connect_command), '\n', '', '')
    if nc_connect_results == 'sucess'
      echo "Updating this server register hostname of ssh config from Windows PC"
      
      " 使用 whoami 命令获取当前用户
      let user = substitute(system('whoami'), '\n', '', '')
      " 使用 hostname -I 命令获取服务器IP（假设您的服务器只有一个IP）
      let server_ip = substitute(system("hostname -I | awk \'{print $1}\'"), '\n', '', '')
      
      " 檢查要下載的是文件還是目錄
      let local_ssh_config_file = '/mnt/c/Users/"$(wslvar USERNAME)"/.ssh/config'
      let search_regesiterHostNameRegex = "\"^Host \\w+|HostName \\d+\""
      let search_local_registerHostNameAndIp  = "grep -P " . search_regesiterHostNameRegex . " " . local_ssh_config_file .
            \ " | paste - - | awk '\\''{print $2, $4}'\\'' " . " | " . "grep " . server_ip
      let ssh_command = "ssh " . user . "@" . server_ip . ' "cat - > ~/.ssh/host_names" >/dev/null 2>&1'
      let ssh_command = search_local_registerHostNameAndIp . " | " . ssh_command
      let ssh_command = "echo" . " '" . ssh_command . "'" . " | nc -w 0.01 127.0.0.1 " . port . " &"
      call system(ssh_command)

      call timer_start(2000, {-> CheckHostNames(host_names_file, 'update')})
    else
      echo "Reverse SSH tunnel is not running\n"
    endif
  endif
endfunction

" 创建自定义命令，例如 :UpdateRegisterHostHameFromLocal 文件名或目錄名
command! -nargs=0 UpdateRegisterHostHameFromLocal :call UpdateRegisterHostHameFromLocal()

function! GetUserInput(message)
  let input = input(a:message)
  return input
endfunction
function! CheckHostNames(host_names_file="~/.ssh/host_names", mode='update')
  let status = 'success'
  let host_names_file = expand(a:host_names_file)
  let failed_message_1 = printf("%s is empty, not got any register hostname on this server !!\n", a:host_names_file)
  let failed_message_2 = printf("Failed: %s is empty, check Reverse SSH tunnel whether running !!\n", a:host_names_file)
  if filereadable(host_names_file)
    let first_line = system("head -n 1 " . host_names_file)
    if a:mode == 'checkHostNameFile'
      if empty(first_line)
        echo failed_message_1
      else
        let message = printf("[Current Register HostName File %s] : %s", a:host_names_file, first_line)
        echo message
        let user_input = GetUserInput("Will update HostName File, Do you want to continue? (Y/N): ")
        let user_input = substitute(user_input, '\n', '', '')
        echo "\n"
        if tolower(user_input) != 'y'
          let status = 'user_stop_update'
          return status
        endif
      endif
    else
      echo "Success: Get Register HostName\n"
      let first_line = printf("[HostName Save in %s] : %s", a:host_names_file,  first_line)
    endif
    echo first_line
  else
    echo failed_message_2
  endif
  return status
endfunction
