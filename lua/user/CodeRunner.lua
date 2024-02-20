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

local function sass_watch_status()
  local filetype = vim.bo.filetype
  if filetype == 'sass' or filetype == 'scss' then
    if vim.g.watch_sass then
      return " Watch Sass: true"
    else
      return " Watch Sass: false"
    end
  end
  return "" -- 对于非sass/scss文件，不显示任何信息
end

local function compile_sass()
  local filetype = vim.bo.filetype               -- 获取当前文件类型
  local filedir = vim.fn.expand('%:p:h')         -- 获取当前文件的目录
  local filename = vim.fn.expand('%:t')          -- 获取当前文件名
  local relative_filename = vim.fn.expand('%:.') -- 获取当前文件名 (相對路徑)
  local output_filename = filename:gsub("%.scss$", ".css"):gsub("%.sass$", ".css")
  local full_output_path = filedir .. '/' .. output_filename

  -- 检查文件类型是否为sass或scss，忽略以下划线开头的文件
  if filetype == "sass" or filetype == "scss" and not string.match(filename, "^_") then
    -- 构建并执行sass命令，直接在命令中改变工作目录
    local sass_cmd = string.format("cd %s && sass %s %s", vim.fn.shellescape(filedir), vim.fn.shellescape(filename),
      vim.fn.shellescape(full_output_path))
    local result = vim.fn.systemlist(sass_cmd)

    if #result > 0 then
      -- 如果有输出或错误，将其添加到quickfix列表
      local qf = {}
      for _, line in ipairs(result) do
        table.insert(qf, { filename = relative_filename, lnum = 0, col = 0, text = line })
      end
      vim.fn.setqflist(qf, 'r') -- 使用'replace'选项来替换当前的quickfix列表内容
      -- 显示警告通知，并提醒用户可以通过:copen命令查看详细信息
      vim.notify("Compilation warnings or errors detected. Use ':copen' to view details.", vim.log.levels.WARN)
    else
      -- 没有错误，显示成功信息
      vim.notify("Compiled: " .. filename .. " to " .. output_filename, vim.log.levels.INFO)
      vim.fn.setqflist({}, 'r')
    end
  end
end

-- 初始化自动编译Sass的全局变量
vim.g.watch_sass = true

-- 创建auto_compile_sass组，但不添加任何autocmd
-- 这样可以避免在不需要时就启动autocmd
vim.api.nvim_create_augroup("auto_compile_sass", {})

-- 在Neovim启动时检查是否需要启用自动编译
if vim.g.watch_sass then
  vim.api.nvim_create_autocmd("BufWritePost", {
    group = "auto_compile_sass",
    pattern = { "*.scss", "*.sass" },
    callback = function()
      local filename = vim.fn.expand('%:t')
      if not string.match(filename, "^_") then -- 忽略以_开头的文件
        compile_sass()
      end
    end,
  })
end

-- 定义切换Sass自动编译状态的命令
local function toggle_sass_auto_compile()
  vim.g.watch_sass = not vim.g.watch_sass
  if vim.g.watch_sass then
    -- 如果启用了自动编译，添加相关的autocmd
    vim.api.nvim_create_autocmd("BufWritePost", {
      group = "auto_compile_sass",
      pattern = { "*.scss", "*.sass" },
      callback = function()
        local filename = vim.fn.expand('%:t')
        if not string.match(filename, "^_") then
          compile_sass()
        end
      end,
    })
    print("Sass auto compile enabled.")
  else
    -- 如果禁用了自动编译，清除相关的autocmd
    vim.api.nvim_clear_autocmds({ group = "auto_compile_sass" })
    print("Sass auto compile disabled.")
  end
end

-- 创建一个命令，方便用户开关自动编译功能
vim.api.nvim_create_user_command("ToggleSassWatch", toggle_sass_auto_compile, {})

lvim.builtin.lualine.sections.lualine_c[#lvim.builtin.lualine.sections.lualine_c + 1] = { sass_watch_status }

-- 创建一个 Neovim 命令来调用这个函数
vim.api.nvim_create_user_command('CodeRunner', code_runner, {})
lvim.keys.normal_mode["<leader>rr"] = "<cmd>CodeRunner<CR>"
