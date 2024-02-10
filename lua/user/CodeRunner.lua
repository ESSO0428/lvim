function code_runner()
  local filetype = vim.bo.filetype                                   -- 获取当前文件类型
  local filedir = vim.fn.expand('%:p:h')                             -- 获取当前文件的目录
  local term_cd_cmd = "cd " .. vim.fn.shellescape(filedir) .. " && " -- 构造终端中执行的 cd 命令
  local filename = vim.fn.expand('%:t')

  -- 根据文件类型执行不同的命令
  if filetype == 'python' then
    vim.o.splitbelow = true
    vim.cmd("sp | term " .. term_cd_cmd .. "python %")
  elseif filetype == 'mysql' then
    vim.cmd("w")
  elseif filetype == 'c' then
    vim.o.splitbelow = true
    vim.cmd("sp | res -5 | term " .. term_cd_cmd .. "gcc % -o %< && time ./%<")
  elseif filetype == 'cpp' then
    vim.o.splitbelow = true
    vim.cmd("sp | res -15 | term " .. term_cd_cmd .. "g++ -std=c++11 % -Wall -o %< && ./%<")
  elseif filetype == 'cs' then
    vim.o.splitbelow = true
    vim.cmd("silent! !mcs %")
    vim.cmd("sp | res -5 | term " .. term_cd_cmd .. "mono %<.exe")
  elseif filetype == 'java' then
    vim.o.splitbelow = true
    vim.cmd("sp | res -5 | term " .. term_cd_cmd .. "javac % && time java %<")
  elseif filetype == 'sh' then
    vim.cmd("sp | term " .. term_cd_cmd .. "bash %")
  elseif filetype == 'html' then
    vim.cmd("silent! !" .. vim.g.mkdp_browser .. " % &")
  elseif filetype == 'markdown' then
    vim.cmd("MarkdownPreview")
  elseif filetype == 'tex' then
    vim.cmd("silent! VimtexStop")
    vim.cmd("silent! VimtexCompile")
  elseif filetype == 'scss' then
    vim.o.splitbelow = true
    local output_filename = filename:gsub("%.scss$", ".css")
    vim.cmd("sp | term " .. term_cd_cmd .. "sass " .. filename .. " " .. output_filename)
  elseif filetype == 'sass' then
    vim.o.splitbelow = true
    local output_filename = filename:gsub("%.sass$", ".css")
    vim.cmd("sp | term " .. term_cd_cmd .. "sass " .. filename .. " " .. output_filename)
  elseif filetype == 'dart' then
    vim.cmd("CocCommand flutter.run -d " .. vim.g.flutter_default_device .. " " .. vim.g.flutter_run_args)
    vim.cmd("silent! CocCommand flutter.dev.openDevLog")
  elseif filetype == 'javascript' then
    vim.o.splitbelow = true
    vim.cmd("sp | term " .. term_cd_cmd .. "export DEBUG='INFO,ERROR,WARNING'; node --trace-warnings .")
  elseif filetype == 'racket' then
    vim.o.splitbelow = true
    vim.cmd("sp | res -5 | term " .. term_cd_cmd .. "racket %")
  elseif filetype == 'go' then
    vim.o.splitbelow = true
    vim.cmd("sp | term " .. term_cd_cmd .. "go run .")
  end
end

-- 创建一个 Neovim 命令来调用这个函数
vim.api.nvim_create_user_command('CodeRunner', code_runner, {})
lvim.keys.normal_mode["<leader>rr"] = "<cmd>CodeRunner<CR>"
