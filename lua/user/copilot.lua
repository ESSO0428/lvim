vim.g.copilot_assume_mapped = true
vim.api.nvim_set_keymap("i", "<M-l>", 'copilot#Accept("<CR>")', { silent = true, expr = true })
vim.g.copilot_no_tab_map = true

function CopilotChatQuickchat()
  -- local input = vim.fn.input("Quick Chat: ")
  -- if input ~= "" then
  --   require("CopilotChat").ask(input, { selection = require("CopilotChat.select").buffer })
  -- end
  require("CopilotChat").ask("", { selection = require("CopilotChat.select").buffer })
end

function CopilotChatPromptAction()
  local actions = require("CopilotChat.actions")
  require("CopilotChat.integrations.telescope").pick(actions.prompt_actions())
end

lvim.builtin.which_key.mappings.u['ki'] = { "<cmd>lua CopilotChatQuickchat()<cr>", "CopilotChat - Quick chat" }
lvim.builtin.which_key.mappings.u['kk'] = { "<cmd>lua CopilotChatPromptAction()<cr>", "CopilotChat Prompt Action" }
lvim.builtin.which_key.vmappings.u['kk'] = { ":lua CopilotChatPromptAction()<cr>", "CopilotChat Prompt Action" }
