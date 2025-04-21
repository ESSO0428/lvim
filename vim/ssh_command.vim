function! DownloadToLocal(file)
  " 去除參數左右的空白
  let file = substitute(a:file, '^\s*\|\s*$', '', 'g')

  let current_file = empty(file) || file ==# '%' ? expand('%:p') : file

  if filereadable(expand("~/.rssh_tunnel"))
    let port = readfile(expand("~/.rssh_tunnel"))[0]
    let netstat_cmd = "netstat -tuln | grep -q '127.0.0.1:" . port . "' && echo success"
    let tunnel_status = substitute(system(netstat_cmd), '\n', '', '')

    if tunnel_status ==# 'success'
      echo "Downloading this file or directory to your Windows local download folder..."

      " 準備在遠端執行的完整 bash 指令
      let awk_main_script_start = "'{"
      let awk_main_script_end = "}'"
      let scp_prepare_command = join([
      \ "ps -x | grep localhost:" . port . " | grep ssh | grep -v grep", 
      \ " | awk '{for (i=5; i<=NF; i++) printf \\\"%s \\\", \\\$i; print \\\"\\\"}'",
      \ " | awk " . awk_main_script_start,
      \ "port=\\\"\\\"; jump=\\\"\\\"; userhost=\\\"\\\"; ",
      \ "for (i=1;i<=NF;i++) ", 
      \ "{ ",
      \ "if (\\\$i==\\\"-p\\\") port=\\\$i\\\" \\\"\\\$(i+1); sub(/^-p/, \\\"-P\\\", port); ",
      \ "if (\\\$i==\\\"-J\\\") jump=\\\$i\\\" \\\"\\\$(i+1); ", 
      \ "if (\\\$i ~ /@/) userhost=\\\" \\\"\\\$i;",
      \ "} "
      \ ], "")
       

      let windows_path = "/mnt/c/Users/\\\$(wslvar USERNAME)/Downloads/"

      " 根據是目錄還是檔案決定加不加 -r
      let scp_dir_arg = isdirectory(current_file) ? "-r" : ""
      
      let open_download_explorer_command = "explorer.exe \\\$(wslpath -w '/mnt/c/Users/'\\\$(wslvar USERNAME)'/Downloads/') >/dev/null 2>&1"
      let full_remote_command = scp_prepare_command .
            \ " printf \\\"scp %s %s %s %s:%s %s >/dev/null 2>&1 && %s \\\"," . "\\\"" . scp_dir_arg  . "\\\", " . "port, jump, userhost, \\\"" . current_file . "\\\", \\\"" . windows_path . "\\\", " . "\\\"" . open_download_explorer_command . "\\\""
            \ . awk_main_script_end

      " 最重要：用雙引號包住 echo !!
      let final_send_command = "echo \"" . full_remote_command . " | sh" . "\" | nc -w 1 127.0.0.1 " . port . " &"

      " scp and open explorer
      call system(final_send_command)
    else
      echo "Reverse SSH tunnel is not active"
    endif
  else
    echo "Tunnel config not found!"
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
    let netstat_connect_command = "netstat -tuln | grep -q '127.0.0.1:" . port . "' && echo success"
    let nc_connect_results = substitute(system(netstat_connect_command), '\n', '', '')
    if nc_connect_results == 'success'
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
