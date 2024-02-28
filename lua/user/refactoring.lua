Nvim.builtin = Nvim.builtin or {}
Nvim.builtin.refactoring = Nvim.builtin.refactoring or {}

Nvim.builtin.refactoring.method = {
  "extract",
  "extract_to_file",
  "extract_var",
  "inline_var",
  "inline_func",
  "extract_block",
  "extract_block_to_file"
}

function refactor_prompt()
  vim.g.dress_input = true
  vim.ui.input({ prompt = 'Refactor ', completion = 'customlist,v:lua.refactor_completion' }, function(method)
    if method and method_is_valid(method) then
      vim.g.dress_input = true
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

lvim.builtin.which_key.mappings.u["="] = { "<cmd>lua require('lvim.lsp.utils').format()<cr>", "Format" }
-- lvim.builtin.which_key.mappings.u.r = { "<cmd>LspLensToggle<cr>", "Like IDEA : definition info" }

lvim.keys.visual_mode['<leader>rf'] = "<cmd>lua refactor_prompt()<CR>"
lvim.keys.normal_mode['<leader>rf'] = "<cmd>lua refactor_prompt()<CR>"
