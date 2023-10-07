let g:runing_remote_server = 0
if filereadable(expand('~') . '/sent_from_local_ssh_L_port.log') && getfsize(expand('~') . '/sent_from_local_ssh_L_port.log') > 0
  let g:runing_remote_server = 1
endif

function! GetServerIP()
    let ifconfig_output = system('ifconfig | grep "inet " | grep -v 127.0.0.1 | awk ''{print $2}''')
    let lines = split(ifconfig_output, '\n')
    let server_ip = ''
    for line in lines
        if line != ''
            let server_ip = line
            break
        endif
    endfor
    if g:host == "YourVscodeReomoteServerName"
      echo "Server IP: " . 'localhost'
    else
      echo "Server IP: " . server_ip
    endif
endfunction
" if g:host != "YourVscodeReomoteServerName"
"   let ifconfig_output = system('ifconfig | grep "inet " | grep -v 127.0.0.1 | awk ''{print $2}''')
"   let lines = split(ifconfig_output, '\n')
"   let server_ip = ''
"   for line in lines
"       if line != ''
"           let server_ip = line
"           break
"       endif
"   endfor
"   let $JUPYTER_ASCENDING_EXECUTE_HOST = server_ip
" endif
function! CleanJupyterAPICatchProcess()
  let api_awk_pid_pgid = systemlist("ps axjf | grep 'awk.*/notebooks/' | grep -v 'grep' | awk '{print $2,$4}'")
  for pid_pgid in api_awk_pid_pgid
    let [pid, pgid] = split(pid_pgid)
    " 在這裡使用 pid 和 pgid 進行進一步的處理
    " echo "PID: " . pid . ", PGID: " . pgid
    let api_catchgroup_pgid = systemlist("ps -eo pgid | awk '$1 == " . pgid . " {print $1}'")
    if len(api_catchgroup_pgid) == 1
      call system('kill -9 ' . pid)
    endif
  endfor
endfunction

function! FindAvailablePort()
  let start_port = 8888

  let port = start_port
  while system('netstat -tl | grep ":'. port .'"') !=# ''
    let port += 1
  endwhile

  return port
endfunction

function! FindRemoteAvailablePort(sshL_port_list)
  let run_jupyter_list = systemlist('ps -axjf | grep "[o]pen_jupyter_notebook.sh --mark-open-file"')
  let used_ports = []
  for jupyter_process in run_jupyter_list
    let jupyter_port = matchstr(jupyter_process, '--port \zs\d\+')
    if jupyter_port != ''
      call add(used_ports, jupyter_port)
    endif
  endfor

  let available_ports = copy(a:sshL_port_list)
  let available_ports = filter(available_ports, 'index(used_ports, v:val) == -1')
  if empty(available_ports)
    return 8888
  endif

  let min_port = min(available_ports)
  return min_port
endfunction

function! DisplayCurrentJupyterKernel(echo_result)
    let b:jupyter_kernel = ''
    let filename = expand('%:p')
    if filename !~ '\.py$'
        return
    endif

    let jupyter_kernel_string = system('ps -axjf | grep "[o]pen_jupyter_notebook.sh --mark-open-file ' . l:filename . '" -A2')

    " 將 jupyter_kernel_string 以換行符號拆分成多行
    let jupyter_kernel_lines = split(jupyter_kernel_string, '\n')

    if len(jupyter_kernel_lines) >= 3
        " 取得最後一行並以空白字元拆分成多個項目
        let last_line_items = split(jupyter_kernel_lines[-1], ' ')

        " 使用正規表達式提取類似 kernel-.*json 的字段
        let kernel_file = ''
        for item in last_line_items
            if item =~ 'kernel-.*json$'
                let kernel_file = substitute(item, '\v^.*/(kernel-.*json)$', '\1', '')
                break
            endif
        endfor
        
        if !empty(kernel_file)
            if a:echo_result == 'Y'
              echo kernel_file
            endif
            let b:jupyter_kernel = kernel_file
        endif
    endif
endfunction
command! JupyterKernelCurrentFile call DisplayCurrentJupyterKernel('Y')


" 检查日志文件是否存在并且有 url
" 等待一段时间后检查日志文件，并根据结果执行相应的命令
function! CheckJupyterAscendingLogFile()
  let l:log_file = expand('~/jupyter_ascending.log')
  let l:http_found = 0

  for l:count in range(1, 10)
    redraw | sleep 500m
    let l:result = readfile(l:log_file)
    let l:http_found = match(join(l:result, "\n"), 'http') >= 0
    if l:http_found
      break
    endif
  endfor
  execute 'tabnew' l:log_file
endfunction
function! KillAllJupyterNoteBook()
  let l:current_user = systemlist('whoami')[0]
  let l:pid_list = systemlist('ps aux | grep "open_jupyter_notebook.sh.*--no-browser" | awk ''{print $2}''')
  let l:pid_node_list = systemlist('ps aux | grep "jupyter-notebook" | awk ''{print $2}''')
  let l:pid_list_json = systemlist('ps aux | grep "ipykernel_launcher -f.*json$" | awk ''{print $2}''')
  let l:pid_list_awk_notebooks = systemlist('ps aux | grep "awk.*/notebooks/" | awk ''{print $2}''')
  for l:pid in l:pid_list
    try
      let l:user = systemlist('ps -o user= -p ' . l:pid . ' | tr -d "\n"')[0]
      if l:user ==# l:current_user
          silent! call system('kill ' . l:pid)
      endif
    catch
    endtry
  endfor

  for l:pid in l:pid_node_list
    try
      let l:user = systemlist('ps -o user= -p ' . l:pid . ' | tr -d "\n"')[0]
      if l:user ==# l:current_user
          silent! call system('kill ' . l:pid)
      endif
    catch
    endtry
  endfor

  for l:pid in l:pid_list_json
    try
      let l:user = systemlist('ps -o user= -p ' . l:pid . ' | tr -d "\n"')[0]
      if l:user ==# l:current_user
          silent! call system('kill ' . l:pid)
      endif
    catch
    endtry
  endfor
  for l:pid in l:pid_list_awk_notebooks
    try
      let l:user = systemlist('ps -o user= -p ' . l:pid . ' | tr -d "\n"')[0]
      if l:user ==# l:current_user
          silent! call system('kill ' . l:pid)
      endif
    catch
    endtry
  endfor
endfunction
function! OpenJupyterNotebook(whichhost)
  " 关闭当前用户打开的 Jupyter 进程
  " call KillAllJupyterNoteBook()
  let l:current_user = systemlist('whoami')[0]
  let ifconfig_output = system('ifconfig | grep "inet " | grep -v 127.0.0.1 | awk ''{print $2}''')
  let lines = split(ifconfig_output, '\n')
  let server_ip = ''
  for line in lines
      if line != ''
          let server_ip = line
          break
      endif
  endfor
  let sshL_port = 8888
  let port_for_jupyter = 8888
  if a:whichhost == 'localhost'
    let port_for_jupyter = FindAvailablePort()
    let g:runing_remote_server = 0
  elseif a:whichhost == 'remote'
    let sshL_port_list = []
    let g:runing_remote_server = 1
    if filereadable(expand('~') . '/sent_from_local_ssh_L_port.log') && getfsize(expand('~') . '/sent_from_local_ssh_L_port.log') > 0
        let file_contents = readfile(expand('~') . '/sent_from_local_ssh_L_port.log')
        for line in file_contents
            if line =~ '^\d\+$'
                call add(sshL_port_list, line)
            endif
        endfor
        let sshL_port = FindRemoteAvailablePort(sshL_port_list)
        let port_for_jupyter = sshL_port
    endif
  endif
  " if filereadable(expand('~') . '/sent_from_local_ssh_L_port.log')
  "     let file_contents = readfile(expand('~') . '/sent_from_local_ssh_L_port.log')
  "     let trimmed_contents = substitute(join(file_contents), '\n', '', 'g')
  "     if trimmed_contents =~ '^\d\+$'
  "         let sshL_port = trimmed_contents
  "     endif
  " endif

  let l:filename = expand('%:p')
  if l:filename !~ '\.py$'
    return
  endif
  let l:filename_not_path = fnamemodify(l:filename, ':t')
  let l:directory = fnamemodify(filename, ':h')
  let l:notebook_name = substitute(l:filename, '\.py$', '.ipynb', '')
  let l:notebook_name_not_path = fnamemodify(l:filename, ':t:r') . '.ipynb'
  if filereadable(l:notebook_name) == 0
    let l:copy_command = 'cp ~/.config/lvim/jupyter_ascending/example.sync.ipynb ' . l:notebook_name
    silent! call system(l:copy_command)
  endif
  if l:current_user == 'root'
    let l:command = "!cd " . l:directory . " && ~/.config/lvim/jupyter_ascending/open_jupyter_notebook.sh --mark-open-file " . l:filename  
      \ . " --allow-root --no-browser --port " . port_for_jupyter  . " 2>&1 | awk '/http/ { print $0; print \"---------------------------------------------\"; split($0, arr, \"/\"); print arr[1] \"//\" arr[3] \"/notebooks/" . l:notebook_name_not_path . "\"; print \"=============================================\\n\"; fflush(); }' > ~/jupyter_ascending.log &"
  else
    let l:command = "!cd " . l:directory . " && JUPYTER_ASCENDING_EXECUTE_PORT=" . port_for_jupyter . " ~/.config/lvim/jupyter_ascending/open_jupyter_notebook.sh --mark-open-file " . l:filename
      \ . " --no-browser --port " . port_for_jupyter . " 2>&1 | awk '/http/ { print $0; print \"---------------------------------------------\"; split($0, arr, \"/\"); print arr[1] \"//\" arr[3] \"/notebooks/" . l:notebook_name_not_path . "\"; print \"=============================================\\n\"; fflush(); }' > ~/jupyter_ascending.log &"
  endif
  " let pid = system('ps -axjf | grep "[o]pen_jupyter_notebook.sh --mark-open-file ' . l:filename . '" -A1 | awk ''NR==2 {print $2}''')[:-2]
  let pid_and_port = system('ps -axjf | grep "[o]pen_jupyter_notebook.sh --mark-open-file ' . l:filename . '" -A1 | awk ''NR==2 {print $0}''')[:-2]
  let pid = ''
  let current_jupyter_port = ''
  if !empty(pid_and_port)
    let pid = split(pid_and_port)[1]
    let current_jupyter_port = substitute(pid_and_port, '.*--port \(\d\+\).*', '\1', '')
  endif

  let separator_50 = repeat("=", 50)
  let separator_25 = repeat("-", 25)
  if !empty(pid)
    let command_restart = 'netstat -tulnep 2>/dev/null | grep ' . pid . " | grep 127.0.0.1 | awk -v pid=" . pid . ' ''$0 ~ pid {print $4}'''
    let port_for_jupyter = current_jupyter_port
    let jupyter_url = substitute(system(command_restart), '\n', '', 'g')
    let jupyter_url = 'http://' . jupyter_url . '/notebooks/' . l:notebook_name_not_path
    if jupyter_url !~ "http://127.0.0.1:"
      let jupyter_localhost_url = ''
      " 构建带前缀的记录行 (空)
      let log_entry_2 = ''
    else
      let jupyter_localhost_url = substitute(jupyter_url, 'http://127.0.0.1:', 'http://localhost:', '')
      " 构建带前缀的记录行
      let log_entry_2 = '[NotebookApp] ' . jupyter_url
    endif
      " 将 jupyter_localhost_url 写入文件
      " 构建带前缀的记录行
      let log_entry_1 = '[NotebookApp (recommend)] ' . jupyter_localhost_url
      

      " 将记录行写入文件
      let logfile = expand('~/jupyter_open_record.log')
      call writefile([log_entry_1], logfile)
      if !empty(log_entry_2)
        " 写入 jupyter_url 到文件
        call writefile([log_entry_2], logfile, 'a') " 使用 'a' 参数以追加模式写入文件
      endif

      execute 'tabnew' l:logfile
      let user_guid = 'echo "click web link for open sync .ipynb (if kernel not exists will create after click)"; ' .
        \ 'echo "file      : ' . l:filename . '"; ' .
        \ 'echo "sync file : ' . notebook_name . '"; ' .
        \ 'echo "--port : ' . port_for_jupyter . '"; '
  else
    execute l:command
    let pid = system('ps -axjf | grep "[o]pen_jupyter_notebook.sh --mark-open-file ' . l:filename . '" -A1 | awk ''NR==2 {print $2}''')[:-2]
    " 启动检查日志文件
    call CheckJupyterAscendingLogFile()
    let user_guid = 'echo "click web link for create new ipython kernel and sync .py to .ipynb"; ' .
          \ 'echo "file      : ' . l:filename . '"; ' .
          \ 'echo "sync file : ' . notebook_name . '"; ' .
          \ 'echo "--port ' . port_for_jupyter . '"; '
  endif
  let kernel_ppid = pid
  let jupyter_ascending_command = "python -m jupyter_ascending.requests.sync --filename " . filename
  if a:whichhost == 'remote'
    let jupyter_ascending_command = "JUPYTER_ASCENDING_EXECUTE_PORT=" . port_for_jupyter . " " . jupyter_ascending_command
  endif
  let while_cmd = 'while [ -z "$(pgrep -P ' . kernel_ppid . ')" ]; do sleep 1; done; sleep 2; ' .
        \ 'echo "jupyter notebook sync (Retry until sync sucess or Ctril+C) ...."; ' .
        \ 'echo "'. separator_50 .'"; '
  let while_cmd = user_guid . while_cmd
  let sync_cmd = while_cmd . 'while true; do ' . jupyter_ascending_command . ' 2>&1 | ' .
        \ 'grep -o "jupyter_ascending.requests.client_lib.RequestFailure" >/dev/null; ' .
        \ 'if [ $? -eq 0 ]; then echo "sync failed"; ' .
        \ 'echo "'. separator_25 .'"; ' .
        \ 'else echo "sync success"; ' . 
        \ 'break; fi; done; '
  let sync_script = tempname()
  call writefile([sync_cmd], sync_script)
  let sync_cmd = 'rm -rf ' . sync_script . '; ' . sync_cmd
  " 在終端中執行腳本文件 (讀取完臨時文件時臨時文件會直接被刪除)
  execute 'belowright split' | execute 'term' 'source ' . sync_script
endfunction

" 设置快捷键 <leader>j 来调用函数
command! JupyterNotebookOpen :call OpenJupyterNotebook('localhost')
command! JupyterNotebookRemoteOpen :call OpenJupyterNotebook('remote')
command! KillAllJupyterNotebook :call KillAllJupyterNoteBook()

function! JupyterAscendingRequestsExecuteRunning() abort
  let grep_command = 'ps aux | grep jupyter_ascending.requests.execute | grep -v "grep"'
  let output = system(grep_command)
  return len(output) > 0
endfunction
function! ExecuteJupyterAscending()
    let filename = expand('%:p')
    if filename !~ '\.py$'
      return
    endif
    let jupyter_port = 8888
    let sshL_port = 8888
    " if filereadable(expand('~') . '/sent_from_local_ssh_L_port.log')
    "     let file_contents = readfile(expand('~') . '/sent_from_local_ssh_L_port.log')
    "     let trimmed_contents = substitute(join(file_contents), '\n', '', 'g')
    "     if trimmed_contents =~ '^\d\+$'
    "         let sshL_port = trimmed_contents
    "     endif
    " endif

    if filereadable(expand('~') . '/sent_from_local_ssh_L_port.log')
        let file_contents = readfile(expand('~') . '/sent_from_local_ssh_L_port.log')
        let trimmed_contents = substitute(join(file_contents), '\n', '', 'g')
        if trimmed_contents =~ '^\d\+$'
            let sshL_port = trimmed_contents
        endif
    endif
    " let pid = system('ps -axjf | grep "[o]pen_jupyter_notebook.sh --mark-open-file ' . l:filename . '" -A1 | awk ''NR==2 {print $2}''')[:-2]
    let pid_and_port = system('ps -axjf | grep "[o]pen_jupyter_notebook.sh --mark-open-file ' . l:filename . '" -A1 | awk ''NR==2 {print $0}''')[:-2]
    let pid = ''
    let current_jupyter_port = ''
    if !empty(pid_and_port)
      let pid = split(pid_and_port)[1]
      let current_jupyter_port = substitute(pid_and_port, '.*--port \(\d\+\).*', '\1', '')
    endif

    if !empty(pid)
      let command_restart = 'netstat -tulnep | grep ' . pid . " | awk -v pid=" . pid . ' ''$0 ~ pid {print $4}'''
      let jupyter_url = substitute(system(command_restart), '\n', '', 'g')
      let jupyter_port = matchstr(jupyter_url, ':\zs\d\+')
    endif

    let directory = fnamemodify(filename, ':h')
    let line = line('.') -1
    execute "normal! :w\<CR>"
    " 檢查是否有執行中的 execute 指令，當沒有時才能執行下一個 execute
    if !JupyterAscendingRequestsExecuteRunning()
      if g:runing_remote_server
        let command = "nohup sh -c \'JUPYTER_ASCENDING_EXECUTE_PORT=" . jupyter_port . " JUPYTER_PORT=" . jupyter_port .
              \ " python -m jupyter_ascending.requests.execute --filename " . filename . " --line " . line . "\' >/dev/null 2>&1 &"
      else
        let command = "nohup sh -c \'python -m jupyter_ascending.requests.execute --filename " . filename . " --line " . line . "\' >/dev/null 2>&1 &"
      endif
      silent! execute "!".command
      let jupyter_kernel = get(b:, 'jupyter_kernel', '')
      if empty(jupyter_kernel)
        call DisplayCurrentJupyterKernel('N')
      endif
    endif
endfunction
" Trash
function! ExecuteAllJupyterAscending()
    let filename = expand('%:p')
    if filename !~ '\.py$'
      return
    endif
    let jupyter_port = 8888
    let sshL_port = 8888
    " if filereadable(expand('~') . '/sent_from_local_ssh_L_port.log')
    "     let file_contents = readfile(expand('~') . '/sent_from_local_ssh_L_port.log')
    "     let trimmed_contents = substitute(join(file_contents), '\n', '', 'g')
    "     if trimmed_contents =~ '^\d\+$'
    "         let sshL_port = trimmed_contents
    "     endif
    " endif

    if filereadable(expand('~') . '/sent_from_local_ssh_L_port.log')
        let file_contents = readfile(expand('~') . '/sent_from_local_ssh_L_port.log')
        let trimmed_contents = substitute(join(file_contents), '\n', '', 'g')
        if trimmed_contents =~ '^\d\+$'
            let sshL_port = trimmed_contents
        endif
    endif
    let pid_and_port = system('ps -axjf | grep "[o]pen_jupyter_notebook.sh --mark-open-file ' . l:filename . '" -A1 | awk ''NR==2 {print $0}''')[:-2]
    let pid = ''
    let current_jupyter_port = ''
    if !empty(pid_and_port)
      let pid = split(pid_and_port)[1]
      let current_jupyter_port = substitute(pid_and_port, '.*--port \(\d\+\).*', '\1', '')
    endif

    if !empty(pid)
      let jupyter_port = current_jupyter_port
    endif

    let directory = fnamemodify(filename, ':h')
    let line = line('.')

    execute "normal! :w\<CR>"
    " 檢查是否有執行中的 execute 指令，當沒有時才能執行下一個 execute
    if !JupyterAscendingRequestsExecuteRunning()
      if g:runing_remote_server
        let command = "nohup sh -c \'JUPYTER_ASCENDING_EXECUTE_PORT=" . jupyter_port . " JUPYTER_PORT=" . jupyter_port .
              \ " python -m jupyter_ascending.requests.execute_all --filename " . filename . "\' >/dev/null 2>&1 &"
      else
        let command = "nohup sh -c \'python -m jupyter_ascending.requests.execute_all --filename " . filename . "\' >/dev/null 2>&1 &"
      endif
      silent! execute "!".command
      let jupyter_kernel = get(b:, 'jupyter_kernel', '')
      if empty(jupyter_kernel)
        call DisplayCurrentJupyterKernel('N')
      endif
    endif
endfunction
function! KillCurrentJupyterKernel()
  let filename = expand('%:p')
  if filename !~ '\.py$'
    return
  endif
  let pid_list = systemlist("ps axjf | grep '[o]pen_jupyter_notebook.sh --mark-open-file " . l:filename . "' -A3 | grep 'jupyter\\|kernel.*json\\|awk /http' | grep -v 'grep' | awk '{print $2}'")

  for pid in pid_list
    if pid =~ '^\d\+$'
      call system('kill -9 ' . pid)
    endif
  endfor
endfunction
command! KillCurrentJupyterNotebook :call KillCurrentJupyterKernel()

function! RestartJupyterkernel()
    let filename = expand('%:p')
    if filename !~ '\.py$'
      return
    endif
    let jupyter_port = 8888
    " let sshL_port = 8888
    " if filereadable(expand('~') . '/sent_from_local_ssh_L_port.log')
    "     let file_contents = readfile(expand('~') . '/sent_from_local_ssh_L_port.log')
    "     let trimmed_contents = substitute(join(file_contents), '\n', '', 'g')
    "     if trimmed_contents =~ '^\d\+$'
    "         let sshL_port = trimmed_contents
    "     endif
    " endif

    let pid_and_port = system('ps -axjf | grep "[o]pen_jupyter_notebook.sh --mark-open-file ' . l:filename . '" -A1 | awk ''NR==2 {print $0}''')[:-2]
    let pid = ''
    let current_jupyter_port = ''
    if !empty(pid_and_port)
      let pid = split(pid_and_port)[1]
      let current_jupyter_port = substitute(pid_and_port, '.*--port \(\d\+\).*', '\1', '')
    endif

    if !empty(pid)
      let jupyter_port = current_jupyter_port
    endif

    let directory = fnamemodify(filename, ':h')
    let line = line('.')
    " let command = "cd " . directory  . " && JUPYTER_ASCENDING_EXECUTE_PORT=" . sshL_port . " python -m jupyter_ascending.requests.restart --filename " . filename
    let command = "JUPYTER_ASCENDING_EXECUTE_PORT=" . jupyter_port . " python -m jupyter_ascending.requests.restart --filename " . filename
    silent! execute "!".command
    " echo command
endfunction
command! JupyterNotebookKernelRestart :call RestartJupyterkernel()


" 绑定函数到快捷键
nnoremap <a-[> :call ExecuteJupyterAscending()<CR>
nnoremap <a-]> :call ExecuteAllJupyterAscending()<CR>



autocmd VimLeave * call DeleteLogFile()

function! DeleteLogFile()
    let log_file = '/tmp/jupyter_ascending/log.log'
    if filereadable(log_file)
        silent! execute '!rm -rf ' . log_file
    endif
endfunction

" 定义 VimLeave 事件的自动命令
autocmd VimLeave * call KillJupyterAscendingProcesses()
autocmd VimEnter,VimLeave * call CleanJupyterAPICatchProcess()

" 终止所有名字以 'while.' 开头的进程
function! KillJupyterAscendingProcesses()
    let l:process_list = system('ps -ef | grep "while.*jupyter_ascending.requests.sync" | grep -v grep')
    let l:process_lines = split(l:process_list, '\n')
    for l:line in l:process_lines
        let l:columns = split(l:line)
        if len(l:columns) >= 2
            let l:pid = l:columns[1]
            call system('kill ' . l:pid)
        endif
    endfor
endfunction

function! JupyterVarableExplorer()
    if exists('$TMUX')
      let pane_count = system('tmux list-panes | wc -l')
      if pane_count >= 2
        silent execute '!tmux select-pane -t 2 && tmux split-window -hb && tmux send-keys "cpyvke last ; kd5 stop ; exit" Enter && tmux select-pane -t 1'
      else
        silent execute '!tmux split-window -v && tmux send-keys -t 2 "cpyvke last ; kd5 stop ; exit" Enter'
      endif
    else
      echo "Not in a tmux session"
    endif
endfunction
command! JupyterVarableExplorer call JupyterVarableExplorer()

" 定義快捷鍵
augroup pythonShortcuts
    autocmd!
    autocmd FileType python nnoremap <buffer> gi ?^# %%<CR>:nohlsearch<CR>
    autocmd FileType python nnoremap <buffer> gk /^# %%<CR>:nohlsearch<CR>
augroup END

function! RestoreTSV()
    " 获取当前缓冲区的内容
    let buffer_content = getline(1, '$')

    " 将连续的空格替换为制表符
    let restored_content = substitute(join(buffer_content, "\n"), ' \+', '\t', 'g')

    " 清空当前缓冲区
    %delete _

    " 将还原的内容写入缓冲区
    call setline(1, split(restored_content, "\n"))
endfunction
command! RestoreTSV call RestoreTSV()

function! FormatTSVOutput()
  silent % !column -t -s $'\t'
endfunction
command! FormatTSVOutput call FormatTSVOutput()
