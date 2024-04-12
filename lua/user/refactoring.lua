Nvim.builtin = Nvim.builtin or {}
Nvim.builtin.refactoring = Nvim.builtin.refactoring or {}

Nvim.builtin.refactoring.method = {
  "extract",
  "extract_to_file",
  "extract_var",
  "inline_var",
  "inline_func",
  "extract_block",
  "extract_block_to_file",
  "move_block_to_file",
}

function refactor_prompt()
  -- vim.ui.select exits visual mode without setting the `<` and `>` marks
  local mode = vim.api.nvim_get_mode().mode
  if mode == "v" or mode == "V" or mode == "vs" or mode == "Vs" then
    vim.cmd("norm! ")
  end

  vim.g.dress_input = true
  -- vim.ui.input({ prompt = 'Refactor ', completion = 'customlist,v:lua.refactor_completion' }, function(method)
  vim.ui.select(Nvim.builtin.refactoring.method, { prompt = 'Refactor ' }, function(method)
    if method and method_is_valid(method) then
      vim.g.dress_input = true
      if method == "move_block_to_file" then
        move_block_to_file()
        return
      end
      vim.ui.input({ prompt = 'Refactor ' .. method .. ' ' }, function(input)
        if input then
          vim.fn.execute(table.concat({ "Refactor", method, input }, " "))
        else
          vim.fn.execute(table.concat({ "Refactor", method }, " "))
        end
      end)
    end
  end)
end

-- 验证方法是否存在于补全列表中
function method_is_valid(method)
  local completions = Nvim.builtin.refactoring.method
  for _, option in ipairs(completions) do
    if option == method then
      return true
    end
  end
  return false
end

-- 用于补全的函数
function refactor_completion(ArgLead, CmdLine, CursorPos)
  local completions = Nvim.builtin.refactoring.method

  local matches = {}
  for _, option in ipairs(completions) do
    if option:sub(1, #ArgLead) == ArgLead then
      table.insert(matches, option)
    end
  end
  return matches
end

function move_block_to_file()
  -- 获取当前文件的完整路径
  local current_file_path = vim.fn.expand('%:p')
  -- 获取当前文件的工作目录
  local current_file_dir = vim.fn.fnamemodify(current_file_path, ':h')
  -- 获取当前 Neovim 的工作目录
  local current_working_dir = vim.fn.getcwd()
  -- 计算相对路径
  local relative_path = vim.fn.fnamemodify(current_file_dir, ':.'):gsub("^" .. vim.pesc(current_working_dir .. "/"), "")

  -- 如果当前文件的工作目录是当前 Neovim 工作目录的直接子目录
  local default_input_value = "."
  if current_file_dir ~= current_working_dir and relative_path ~= "" then
    -- 使用相对于当前工作目录的子目录路径作为预输入值
    default_input_value = relative_path
  elseif vim.fn.isdirectory(current_file_dir) == 0 or not string.find(current_file_path, current_working_dir) then
    -- 如果工作目录不存在或者非当前目录的子目录，则不给定预输入值
    default_input_value = ""
  elseif current_file_dir == current_working_dir then
    -- 如果工作目录等于当前目录，则提示输入 "."
    default_input_value = "."
  end

  -- 提示用户输入目标文件路径，提供默认值
  local file_path = vim.fn.input('Move to File: > ', default_input_value, 'file')

  if file_path == "" or file_path == "." then
    print("No file path provided.")
    return
  end

  -- 删除选中的文本
  if mode == "v" or mode == "V" or mode == "vs" or mode == "Vs" then
    vim.cmd('normal! gv"xd')
  else
    vim.cmd('normal! "xdd')
  end


  -- 检查缓冲区是否存在
  local bufnr = vim.fn.bufnr(file_path)
  local buffer_exists = bufnr ~= -1

  -- 检查当前标签页中是否有打开该缓冲区的窗口
  local win_found = false
  local target_win_id = nil
  local tab_wins = vim.api.nvim_tabpage_list_wins(0) -- 获取当前标签页的窗口列表
  if buffer_exists then
    for _, win_id in ipairs(tab_wins) do
      if vim.api.nvim_win_get_buf(win_id) == bufnr then
        win_found = true
        target_win_id = win_id
        break
      end
    end
  end

  -- 根据检查结果决定操作
  if buffer_exists and win_found then
    -- 缓冲区存在且已经在当前标签页的某个窗口中打开，跳转到那个窗口
    ---@diagnostic disable-next-line: param-type-mismatch
    vim.api.nvim_set_current_win(target_win_id)
  elseif buffer_exists and not win_found then
    -- 缓冲区存在但没有在当前标签页打开的窗口，垂直分割并打开该缓冲区
    vim.cmd('vsp')
    vim.api.nvim_win_set_buf(vim.api.nvim_get_current_win(), bufnr)
  else
    -- 缓冲区不存在，创建新的垂直分割窗口并打开文件
    vim.cmd('vsp ' .. file_path)
  end

  -- 在目标文件中粘贴文本
  vim.cmd('normal! G"xp')
  vim.cmd('wincmd p')

  -- 返回到之前的模式，如果需要的话
  -- 这一步可能不是必需的，取决于你的具体需求
end

-- 将函数注册为一个 Neovim 命令，以便可以在可视模式下调用
vim.api.nvim_create_user_command('MoveBlockToFile', move_block_to_file, { range = true })

lvim.builtin.which_key.mappings.u["="] = { "<cmd>lua require('lvim.lsp.utils').format()<cr>", "Format" }
-- lvim.builtin.which_key.mappings.u.r = { "<cmd>LspLensToggle<cr>", "Like IDEA : definition info" }

lvim.keys.visual_mode['<leader>rf'] = "<cmd>lua refactor_prompt()<CR>"
lvim.keys.normal_mode['<leader>rf'] = "<cmd>lua refactor_prompt()<CR>"
