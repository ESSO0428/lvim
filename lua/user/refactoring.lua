function refactor_prompt()
  vim.ui.input({ prompt = ':Refactor ', completion = 'customlist,v:lua.refactor_completion' }, function(input)
    if input then
      vim.fn.execute("Refactor " .. input)
    end
  end)
end

-- 用于补全的函数
function refactor_completion(ArgLead, CmdLine, CursorPos)
  local completions = {
    "extract",
    "extract_to_file",
    "extract_var",
    "inline_var",
    "inline_func",
    "extract_block",
    "extract_block_to_file"
  }

  local matches = {}
  for _, option in ipairs(completions) do
    if option:sub(1, #ArgLead) == ArgLead then
      table.insert(matches, option)
    end
  end
  return matches
end

lvim.builtin.which_key.mappings.u["="] = { "<cmd>lua require('lvim.lsp.utils').format()<cr>", "Format" }

lvim.keys.visual_mode['<leader>uf'] = "<cmd>lua refactor_prompt()<CR>"
lvim.builtin.which_key.mappings.u["f"] = { "<cmd>lua refactor_prompt()<CR>", "Refactor" }
