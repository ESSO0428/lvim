vim.g.copilot_assume_mapped = true
vim.api.nvim_set_keymap("i", "<M-l>", 'copilot#Accept("<cr>")', { silent = true, expr = true })
vim.g.copilot_no_tab_map = true

-- Quick chat with Copilot (no context)
function CopilotChatNoContextchat()
  require("CopilotChat").ask("", {
    selection = false,
  })
end

-- Quick chat with Copilot
function CopilotChatQuickchatCore(_, _, ask)
  if ask == true then
    local ok, input = pcall(vim.fn.input, "Quick Chat: ")
    if ok and input ~= "" then
      require("CopilotChat").ask(input, { selection = require("CopilotChat.select").buffer })
    end
  else
    require("CopilotChat").ask("", { selection = require("CopilotChat.select").buffer })
  end
end

function CopilotChatQuickchat(ask)
  local wrapped_fn = Nvim.DAPUI.with_layout_handling_when_dapui_open(CopilotChatQuickchatCore)
  wrapped_fn(ask)
end

-- Quick chat (visuals) for Copilot
function CopilotChatQuickchatVisualCore(_, _, ask)
  if ask == true then
    local ok, input = pcall(vim.fn.input, "Quick Chat: ")
    if ok and input ~= "" then
      require("CopilotChat").ask(input, { selection = require("CopilotChat.select").visual })
    end
  else
    require("CopilotChat").ask("", { selection = require("CopilotChat.select").visual })
  end
end

function CopilotChatQuickchatVisual(ask)
  local wrapped_fn = Nvim.DAPUI.with_layout_handling_when_dapui_open(CopilotChatQuickchatVisualCore)
  wrapped_fn(ask)
end

-- Triggers the Copilot chat prompt action
function CopilotChatPromptActionCore()
  local actions = require("CopilotChat.actions")
  require("CopilotChat.integrations.telescope").pick(actions.prompt_actions())
end

function CopilotChatPromptAction()
  local wrapped_fn = Nvim.DAPUI.with_layout_handling_when_dapui_open(CopilotChatPromptActionCore)
  wrapped_fn()
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
lvim.builtin.which_key.mappings.u['kw'] = { "<cmd>lua CopilotChatNoContextchat()<cr>", "CopilotChat - No context chat" }

lvim.builtin.which_key.mappings.u['ka'] = { "<cmd>lua CopilotChatQuickchat(true)<cr>", "CopilotChat - Quick chat" }
lvim.builtin.which_key.vmappings.u['ka'] = { "<cmd>lua CopilotChatQuickchatVisual(true)<cr>", "CopilotChat - Quick chat" }

lvim.builtin.which_key.mappings.u['kk'] = { "<cmd>lua CopilotChatPromptAction()<cr>", "CopilotChat Prompt Action" }
lvim.builtin.which_key.vmappings.u['kk'] = { "<cmd>lua CopilotChatPromptAction()<cr>", "CopilotChat Prompt Action" }

local select = require('CopilotChat.select')
local buffer = require('CopilotChat.select').buffer


select.diagnostics = function(source)
  local bufnr = source.bufnr
  local winnr = source.winnr
  local select_buffer = buffer(source)
  if not select_buffer then
    return nil
  end

  local cursor = vim.api.nvim_win_get_cursor(winnr)

  local line_diagnostics = vim.lsp.diagnostic.get_line_diagnostics(bufnr, cursor[1] - 1)

  if #line_diagnostics == 0 then
    return nil
  end

  local diagnostics = {}
  for _, diagnostic in ipairs(line_diagnostics) do
    table.insert(diagnostics, diagnostic.message)
  end

  local result = table.concat(diagnostics, '. ')
  result = result:gsub('^%s*(.-)%s*$', '%1'):gsub('\n', ' ')

  local file_name = vim.api.nvim_buf_get_name(bufnr)

  local out = {
    content = file_name .. ':' .. cursor[1] .. '. ' .. result,
    filename = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(bufnr), ':p:.'),
    filetype = vim.bo[bufnr].filetype,
    start_line = cursor[1],
    end_line = cursor[1],
    bufnr = bufnr,
  }

  return out
end


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

  return {
    content = result,
    filename = 'git_diff_' .. (staged and 'staged' or 'unstaged'),
    filetype = 'diff',
  }
end

local function read_copilot_prompt(file)
  -- Get the current Neovim configuration directory
  local config_dir = vim.fn.stdpath('config')

  -- Directory containing the .md files
  local prompt_directory = config_dir .. '/docs/CopilotChatPrompts'
  local prompt_file = prompt_directory .. '/' .. file
  local f = io.open(prompt_file, 'r')
  local prompts = ""
  if f then
    local content = f:read('*all')
    prompts = content
    f:close()
  else
    prompts = ""
  end
  return prompts
end

-- NOTE: CopilotChat 主要配置
-- prompts 另外配置於 : `~/.config/lvim/docs/CopilotChatPrompts/`
-- Prompts are configured separately at: `~/.config/lvim/docs/CopilotChatPrompts/`
-- For detailed information, see: `~/.config/lvim/docs/CopilotChatPrompts/Index.md`
local user = vim.env.USER or "User"
user = user:sub(1, 1):upper() .. user:sub(2)

local question_header = "  " .. user .. " "
local answer_header = "  Copilot "
require("CopilotChat").setup {
  -- system_prompt = require("CopilotChat").prompts().COPILOT_INSTRUCTIONS, -- System prompt to use (can be specified manually in prompt via /).
  model = 'claude-3.5-sonnet', -- Default model to use, see ':CopilotChatModels' for available models (can be specified manually in prompt via $).
  agent = 'copilot',           -- Default agent to use, see ':CopilotChatAgents' for available agents (can be specified manually in prompt via @).
  context = nil,               -- Default context to use (can be specified manually in prompt via #).
  sticky = nil,                -- Default sticky prompt or array of sticky prompts to use at start of every new chat.

  temperature = 0.1,           -- GPT result temperature
  headless = false,            -- Do not write to chat buffer and use history(useful for using callback for custom processing)
  callback = nil,              -- Callback to use when ask response is received

  -- default selection
  selection = function(source)
    return select.visual(source) or select.buffer(source)
  end,

  -- default window options
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

  show_help = true,                 -- Shows help message as virtual lines when waiting for user input
  show_folds = true,                -- Shows folds for sections in chat
  highlight_selection = true,       -- Highlight selection in the source buffer when in the chat window
  highlight_headers = true,         -- Highlight headers in chat, disable if using markdown renderers (like render-markdown.nvim)
  auto_follow_cursor = true,        -- Auto-follow cursor in chat
  auto_insert_mode = false,         -- Automatically enter insert mode when opening window and on new prompt
  insert_at_end = false,            -- Move cursor to end of buffer when inserting text
  clear_chat_on_new_prompt = false, -- Clears chat on every new prompt

  -- Static config starts here (can be configured only via setup function)

  debug = false, -- Enable debug logging (same as 'log_level = 'debug')
  log_level = 'info', -- Log level to use, 'trace', 'debug', 'info', 'warn', 'error', 'fatal'
  proxy = nil, -- [protocol://]host[:port] Use this proxy
  allow_insecure = false, -- Allow insecure server connections

  chat_autocomplete = true, -- Enable chat autocompletion (when disabled, requires manual `mappings.complete` trigger)
  history_path = vim.fn.stdpath('data') .. '/copilotchat_history', -- Default path to stored history

  question_header = question_header, -- Header to use for user questions
  answer_header = answer_header, -- Header to use for AI answers
  error_header = '> [!ERROR] Error', -- Header to use for errors (default is '## Error ')
  separator = '───', -- Separator to use in chat

  -- default contexts
  contexts = {},
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
    Explain = '> /COPILOT_EXPLAIN\n\n' .. read_copilot_prompt('Explain.md'),
    Ask = '> /COPILOT_EXPLAIN\n\n' .. read_copilot_prompt('Ask.md'),
    Review = {
      prompt = '> /COPILOT_REVIEW\n\n' .. read_copilot_prompt('Review.md'),
      callback = function(response, source)
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
        vim.diagnostic.set(
          vim.api.nvim_create_namespace('copilot_diagnostics'),
          source.bufnr,
          diagnostics
        )
      end,
    },
    ReviewClear = {
      prompt = '> /COPILOT_REVIEW\n\n' .. read_copilot_prompt('ReviewClear.md'),
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
    Fix = '> /COPILOT_GENERATE\n\n' .. read_copilot_prompt('Fix.md'),
    Optimize = '> /COPILOT_GENERATE\n\n' .. read_copilot_prompt('Optimize.md'),
    OneLineComment = '> /COPILOT_GENERATE\n\n' .. read_copilot_prompt('OneLineComment.md'),
    OneParagraphComment = '> /COPILOT_GENERATE\n\n' .. read_copilot_prompt('OneParagraphComment.md'),
    Docs = '> /COPILOT_GENERATE\n\n' .. read_copilot_prompt('Docs.md'),
    Tests = '> /COPILOT_GENERATE\n\n' .. read_copilot_prompt('Tests.md'),
    CodeGraph = '> /COPILOT_EXPLAIN\n\n' .. read_copilot_prompt('CodeGraph.md'),
    MermaidUml = '> /COPILOT_EXPLAIN\n\n' .. read_copilot_prompt('MermaidUml.md'),
    MermaidSequence = '> /COPILOT_EXPLAIN\n\n' .. read_copilot_prompt('MermaidSequence.md'),
    FixDiagnostic = {
      prompt = read_copilot_prompt('FixDiagnostic.md'),
      selection = select.diagnostics,
    },
    -- Commit = {
    --   prompt = '> #git:staged\n\nWrite commit message for the change with commitizen convention. Make sure the title has maximum 50 characters and message is wrapped at 72 characters. Wrap the whole message in code block with language gitcommit.',
    -- },
    Commit = {
      prompt = read_copilot_prompt('Commit.md'),
      selection = select.gitdiff,
    },
    CommitStaged = {
      prompt = read_copilot_prompt('CommitStaged.md'),
      selection = function(source)
        return select.gitdiff(source, true)
      end,
    },
  },

  -- default mappings
  mappings = {
    complete = {
      insert = '<Tab>',
    },
    close = {
      normal = 'q',
      insert = '<C-c>',
    },
    reset = {
      normal = '<C-l>',
      insert = '<C-l>',
    },
    submit_prompt = {
      normal = '<CR>',
      insert = '<C-s>',
    },
    toggle_sticky = {
      detail = 'Makes line under cursor sticky or deletes sticky line.',
      normal = 'gr',
    },
    accept_diff = {
      normal = '<C-y>',
      insert = '<C-y>',
    },
    jump_to_diff = {
      normal = 'gD',
    },
    quickfix_diffs = {
      normal = 'gq',
    },
    yank_diff = {
      normal = 'gy',
      register = '"',
    },
    show_diff = {
      normal = 'gd',
    },
    show_info = {
      normal = 'gp',
    },
    show_context = {
      normal = 'gs',
    },
    show_help = {
      normal = 'gh',
    },
  },
}
vim.api.nvim_create_autocmd("BufEnter", {
  pattern = "copilot-*",
  callback = function()
    vim.opt_local.number = true
  end,
})
