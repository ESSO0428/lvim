-- lvim.keys.normal_mode['<leader><a-u>'] = "<cmd>Lspsaga lsp_finder<cr>"
-- lvim.keys.normal_mode['<a-u>'] = "<cmd>Lspsaga lsp_finder<cr>"
lvim.keys.normal_mode['<a-u>'] = "<cmd>Lspsaga finder<cr>"
-- lvim.keys.normal_mode['<c-t>'] = "<cmd>Lspsaga outline<cr>"

function lspsaga_callhierarchy_prompt()
  vim.g.dress_input = true
  vim.ui.input({ prompt = 'Lspsaga ', completion = 'customlist,v:lua.lspsaga_callhierarchy_list' }, function(method)
    if method then
      pcall(function()
        vim.fn.execute(table.concat({ "Lspsaga", method }, " "))
      end)
    end
  end)
end

-- 用于补全的函数
function lspsaga_callhierarchy_list(ArgLead, CmdLine, CursorPos)
  local completions = {
    "incoming_calls",
    "outgoing_calls"
  }

  local matches = {}
  for _, option in ipairs(completions) do
    if option:sub(1, #ArgLead) == ArgLead then
      table.insert(matches, option)
    end
  end
  return matches
end

lvim.keys.normal_mode['ga'] = "<cmd>lua lspsaga_callhierarchy_prompt()<CR>"
