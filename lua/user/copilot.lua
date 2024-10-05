vim.g.copilot_assume_mapped = true
vim.api.nvim_set_keymap("i", "<M-l>", 'copilot#Accept("<cr>")', { silent = true, expr = true })
vim.g.copilot_no_tab_map = true

-- Quick chat with Copilot
function CopilotChatQuickchat(ask)
  if ask == true then
    local ok, input = pcall(vim.fn.input, "Quick Chat: ")
    if ok and input ~= "" then
      require("CopilotChat").ask(input, { selection = require("CopilotChat.select").buffer })
    end
  else
    require("CopilotChat").ask("", { selection = require("CopilotChat.select").buffer })
  end
end

-- Quick chat (visuals) for Copilot
function CopilotChatQuickchatVisual(ask)
  if ask == true then
    local ok, input = pcall(vim.fn.input, "Quick Chat: ")
    if ok and input ~= "" then
      require("CopilotChat").ask(input, { selection = require("CopilotChat.select").visual })
    end
  else
    require("CopilotChat").ask("", { selection = require("CopilotChat.select").visual })
  end
end

-- Triggers the Copilot chat prompt action
function CopilotChatPromptAction()
  local actions = require("CopilotChat.actions")
  require("CopilotChat.integrations.telescope").pick(actions.prompt_actions())
end

function CopilotChatInline()
  require("CopilotChat").ask("", {
    selection = require('CopilotChat.select').buffer,
    window = {
      layout = "float",
      relative = "cursor",
      width = 1,
      height = 0.4,
      row = 1,
    },
  })
end

-- Initialize CopilotChat with inline arguments and custom window layout
function CopilotChatInlineVisual()
  require("CopilotChat").ask("", {
    selection = require('CopilotChat.select').visual,
    window = {
      layout = "float",
      relative = "cursor",
      width = 1,
      height = 0.4,
      row = 1,
    },
  })
end

lvim.builtin.which_key.mappings.u['ki'] = { "<cmd>lua CopilotChatQuickchat(false)<cr>", "CopilotChat - Quick chat panel" }
lvim.builtin.which_key.vmappings.u['ki'] = { "<cmd>lua CopilotChatQuickchatVisual(false)<cr>",
  "CopilotChat - Quick chat panel" }
lvim.builtin.which_key.mappings.u['kw'] = { "<cmd>lua CopilotChatInline()<cr>", "CopilotChat Inline" }
lvim.builtin.which_key.vmappings.u['kw'] = { "<cmd>lua CopilotChatInlineVisual()<cr>", "CopilotChat Inline" }

lvim.builtin.which_key.mappings.u['ka'] = { "<cmd>lua CopilotChatQuickchat(true)<cr>", "CopilotChat - Quick chat" }
lvim.builtin.which_key.vmappings.u['ka'] = { "<cmd>lua CopilotChatQuickchatVisual(true)<cr>", "CopilotChat - Quick chat" }

lvim.builtin.which_key.mappings.u['kk'] = { "<cmd>lua CopilotChatPromptAction()<cr>", "CopilotChat Prompt Action" }
lvim.builtin.which_key.vmappings.u['kk'] = { "<cmd>lua CopilotChatPromptAction()<cr>", "CopilotChat Prompt Action" }

local select = require('CopilotChat.select')
local buffer = require('CopilotChat.select').buffer

-- This function generates a git diff for a given file. If the diff is too large,
-- it uses a `diff --stat` instead. The function returns a buffer with the diff result.
-- It first checks if the file directory exists, if not, it uses the current directory.
-- Then it constructs the `git diff` command and executes it.
-- If the diff result is too large (> 30000 characters), it uses the git diff stat command instead.
-- Finally, it sets the filetype of the buffer to `diff` and the lines of the buffer to the diff result.
select.gitdiff = function(source, staged)
  local select_buffer = buffer(source)
  if not select_buffer then
    return nil
  end
  local file_path = vim.api.nvim_buf_get_name(source.bufnr)
  local file_dir = vim.fn.fnamemodify(file_path, ':h')
  -- check file dir is exist, or use current dir instead
  if vim.fn.isdirectory(file_dir) == 0 then
    file_dir = vim.fn.getcwd()
  end

  -- NOTE: Fix vulnerability #417 in CopilotC-Nvim/CopilotChat.nvim
  file_dir = file_dir:gsub('.git$', '')

  local cmd_diff = 'git -C ' ..
      file_dir .. ' diff --no-color --no-ext-diff' .. (staged and ' --staged' or '') .. ' 2>/dev/null'
  local cmd_diff_stat = 'git -C ' ..
      file_dir .. ' diff --stat --no-color --no-ext-diff' .. (staged and ' --staged' or '') .. ' 2>/dev/null'

  local handle = io.popen(cmd_diff)
  if not handle then
    return nil
  end

  local result = handle:read('*a')
  handle:close()

  -- jugde if the diff is too large (> 30000 characters) to handle, use diff --stat to instead
  if #result > 30000 then
    handle = io.popen(cmd_diff_stat)
    if not handle then
      return nil
    end

    result = handle:read('*a')
    handle:close()
  end

  if not result or result == '' then
    return nil
  end

  select_buffer.filetype = 'diff'
  select_buffer.lines = result
  return select_buffer
end

require("CopilotChat.integrations.cmp").setup()
require("CopilotChat").setup {
  debug = true, -- Enable debugging
  model = "gpt-4o",
  window = {
    layout = 'vertical',    -- 'vertical', 'horizontal', 'float', 'replace'
    width = 0.5,            -- fractional width of parent, or absolute width in columns when > 1
    height = 0.5,           -- fractional height of parent, or absolute height in rows when > 1
    -- Options below only apply to floating windows
    relative = 'editor',    -- 'editor', 'win', 'cursor', 'mouse'
    border = 'single',      -- 'none', single', 'double', 'rounded', 'solid', 'shadow'
    row = nil,              -- row position of the window, default is centered
    col = nil,              -- column position of the window, default is centered
    title = 'Copilot Chat', -- title of chat window
    footer = nil,           -- footer of chat window
    zindex = 1,             -- determines if window is on top or below other floating windows
  },
  mappings = {
    complete = {
      insert = '',
    },
  },
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
    Ask = '/COPILOT_EXPLAIN 等待我對選定文字的提問 (請告訴我你是否準備好了)',
    Review = {
      prompt = '/COPILOT_REVIEW 審查選定的程式碼 (並用繁體中文說明)。',
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
    ReviewClear = {
      prompt = '/COPILOT_REVIEW 幫我清除 Review 的標記 (只要回答沒問題即可)',
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
      end
    },
    Fix = '/COPILOT_GENERATE 1. 這段程式碼有問題。請重寫程式碼以修復錯誤 (並在修復錯誤後用繁體中文說明修復了什麼) 2. 注意產生的代碼塊不能包含行號',
    Optimize = '/COPILOT_GENERATE 1. 優化選定的程式碼以提高性能和可讀性 (並在優化完後用繁體中文說明寫了什麼) 2. 注意產生的代碼塊不能包含行號',
    OneLineComment = '/COPILOT_GENERATE 1. 為選定的部分上方添加一行英文註釋 2. 在寫完註釋後，用繁體中文完整說明生成的註釋內容 3. 如果生成的註解為英文，最後說明的部分必須提供對應的繁體中文翻譯 4. 注意產生的代碼塊不能包含行號',
    OneParagraphComment = '/COPILOT_GENERATE 1. 為選定的部分上方添加英文註釋摘要，確保每一行不超過 50 字 2. 在寫完註釋後，用繁體中文完整說明生成的註釋內容 3. 如果生成的註解為英文，最後說明的部分必須提供對應的繁體中文翻譯 4. 注意產生的代碼塊不能包含行號',
    Docs = '/COPILOT_GENERATE 1. 請為選定的部分添加英文的文檔註釋 2. 若檢測到文檔註釋處先前已按照其他 Annotation Conventions 撰寫，請繼續依照該 Conventions 將文檔撰寫完成 3. 在寫完註釋後，請用繁體中文完整說明生成的文檔註釋的內容 4. 如果生成的註解為英文，最後說明的部分必須提供對應的繁體中文翻譯 5. 注意產生的代碼塊不能包含行號',
    Tests = '/COPILOT_GENERATE 1. 請為我的程式碼生成測試 (並在寫完測試後用繁體中文說明寫了什麼) 2. 注意產生的代碼塊不能包含行號',
    FixDiagnostic = {
      prompt = '請協助修復檔案的診斷問題 (並用繁體中文說明):',
      selection = select.diagnostics,
    },
    Commit = {
      prompt = '按照 commitizen 規範撰寫英文提交訊息。確保標題最多有 50 個字元，訊息在 72 個字元處換行。將整個訊息用 gitcommit 語言的程式碼塊包裹起來 (隨後提供一個不包含語法高亮標籤的對應的繁體中文版本)。',
      selection = select.gitdiff,
    },
    CommitStaged = {
      prompt = '按照 commitizen 規範撰寫英文提交訊息。確保標題最多有 50 個字元，訊息在 72 個字元處換行。將整個訊息用 gitcommit 語言的程式碼塊包裹起來 (隨後提供一個不包含語法高亮標籤的對應的繁體中文版本)。',
      selection = function(source)
        return select.gitdiff(source, true)
      end,
    },
  }
}
vim.api.nvim_create_autocmd("BufEnter", {
  pattern = "copilot-*",
  callback = function()
    vim.opt_local.number = true
  end,
})
