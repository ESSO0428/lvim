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

local select = require('CopilotChat.select')
local buffer = require('CopilotChat.select').buffer

select.gitdiff = function(source, staged)
  local select_buffer = buffer(source)
  if not select_buffer then
    return nil
  end
  local file_path = vim.api.nvim_buf_get_name(source.bufnr)
  local file_dir = vim.fn.fnamemodify(file_path, ':h')

  local cmd = 'git -C ' ..
      file_dir .. ' diff --no-color --no-ext-diff' .. (staged and ' --staged' or '') .. ' 2>/dev/null'
  local handle = io.popen(cmd)
  if not handle then
    return nil
  end

  local result = handle:read('*a')
  handle:close()

  if not result or result == '' then
    return nil
  end

  select_buffer.filetype = 'diff'
  select_buffer.lines = result
  return select_buffer
end

require("CopilotChat").setup {
  debug = true, -- Enable debugging
  -- See Configuration section for rest
  -- NOTE: Default prompts configuration
  -- prompts = {
  --   Explain = '/COPILOT_EXPLAIN Write an explanation for the active selection as paragraphs of text.',
  --   Review = '/COPILOT_REVIEW Review the selected code.',
  --   Fix = '/COPILOT_GENERATE There is a problem in this code. Rewrite the code to show it with the bug fixed.',
  --   Optimize = '/COPILOT_GENERATE Optimize the selected code to improve performance and readablilty.',
  --   Docs = '/COPILOT_GENERATE Please add documentation comment for the selection.',
  --   Tests = '/COPILOT_GENERATE Please generate tests for my code.',
  --   FixDiagnostic = 'Please assist with the following diagnostic issue in file:',
  --   Commit = 'Write commit message for the change with commitizen convention. Make sure the title has maximum 50 characters and message is wrapped at 72 characters. Wrap the whole message in code block with language gitcommit.',
  --   CommitStaged = 'Write commit message for the change with commitizen convention. Make sure the title has maximum 50 characters and message is wrapped at 72 characters. Wrap the whole message in code block with language gitcommit.',
  -- },
  -- NOTE: Chinese prompts
  prompts = {
    Explain = '/COPILOT_EXPLAIN 為選定的部分寫一段文字解釋。',
    Review = {
      prompt = '/COPILOT_REVIEW 審查選定的程式碼。',
      callback = function(response, source)
        local ns = vim.api.nvim_create_namespace('copilot_review')
        local diagnostics = {}
        for line in response:gmatch('[^\r\n]+') do
          if line:find('^line=') then
            local start_line = nil
            local end_line = nil
            local message = nil
            local single_match, message_match = line:match('^line=(%d+): (.*)$')
            if not single_match then
              local start_match, end_match, m_message_match = line:match('^line=(%d+)-(%d+): (.*)$')
              if start_match and end_match then
                start_line = tonumber(start_match)
                end_line = tonumber(end_match)
                message = m_message_match
              end
            else
              start_line = tonumber(single_match)
              end_line = start_line
              message = message_match
            end

            if start_line and end_line then
              table.insert(diagnostics, {
                lnum = start_line - 1,
                end_lnum = end_line - 1,
                col = 0,
                message = message,
                severity = vim.diagnostic.severity.WARN,
                source = 'Copilot Review',
              })
            end
          end
        end
        vim.diagnostic.set(ns, source.bufnr, diagnostics)
      end,
    },
    Fix = '/COPILOT_GENERATE 這段程式碼有問題。請重寫程式碼以修復錯誤。',
    Optimize = '/COPILOT_GENERATE 優化選定的程式碼以提高性能和可讀性。',
    Docs = '/COPILOT_GENERATE 請為選定的部分添加文件註釋。',
    Tests = '/COPILOT_GENERATE 請為我的程式碼生成測試。',
    FixDiagnostic = {
      prompt = '請協助處理以下檔案中的診斷問題:',
      selection = select.diagnostics,
    },
    Commit = {
      prompt = '按照 commitizen 習慣為更改寫提交訊息。確保標題最多有 50 個字元，訊息在 72 個字元處換行。將整個訊息用 gitcommit 語言的程式碼塊包裹起來 (最後附上中文說明)。',
      selection = select.gitdiff,
    },
    CommitStaged = {
      prompt = '按照 commitizen 習慣為更改寫提交訊息。確保標題最多有 50 個字元，訊息在 72 個字元處換行。將整個訊息用 gitcommit 語言的程式碼塊包裹起來 (最後附上中文說明)。',
      selection = function(source)
        return select.gitdiff(source, true)
      end,
    },
  }
}
