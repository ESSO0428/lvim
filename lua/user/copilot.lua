vim.g.copilot_assume_mapped = true
vim.api.nvim_set_keymap("i", "<M-l>", 'copilot#Accept("<cr>")', { silent = true, expr = true })
vim.g.copilot_no_tab_map = true


local utils = require('CopilotChat.utils')
local select = require('CopilotChat.select')
local buffer = require('CopilotChat.select').buffer
select.open_select_promt_mode = nil

-- Quick chat with Copilot (no context)
function CopilotChatNoContextchat()
  local is_focused = require("CopilotChat").chat:focused()
  if is_focused then
    require("CopilotChat").open({ selection = false })
    -- HACK: Manually trigger BufLeave event to clear selection highlights
    -- This is a workaround because CopilotChat currently doesn't properly handle
    -- selection highlight clearing in all cases. The plugin only clears highlights
    -- on buffer leave events.
    vim.cmd("doautocmd BufLeave")
  else
    require("CopilotChat").open({ selection = false })
  end
end

-- Quick chat with Copilot
function CopilotChatQuickchatCore(_, _, ask)
  local is_focused = require("CopilotChat").chat:focused()
  local config = { selection = false }
  if not is_focused then
    config.sticky = { "#buffer" }
  end
  if ask == true then
    local ok, input = pcall(vim.fn.input, "Quick Chat: ")
    if ok and input ~= "" then
      require("CopilotChat").ask(input, config)
    end
  else
    require("CopilotChat").open(config)
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
    require("CopilotChat").open({ selection = require("CopilotChat.select").visual })
  end
end

function CopilotChatQuickchatVisual(ask)
  local wrapped_fn = Nvim.DAPUI.with_layout_handling_when_dapui_open(CopilotChatQuickchatVisualCore)
  wrapped_fn(ask)
end

-- Triggers the Copilot chat prompt action
function CopilotChatPromptActionCore()
  require("CopilotChat").select_prompt()
end

function CopilotChatPromptAction()
  select.open_select_promt_mode = vim.fn.mode()
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

local function get_select_prompt_selection(source)
  local open_select_promt_mode = select.open_select_promt_mode
  local content = select.buffer(source)

  -- "\x16" represents Visual Block mode
  local visual_modes = { v = true, V = true, ["\x16"] = true }
  if visual_modes[open_select_promt_mode] then
    content = select.visual(source) or content
  end
  select.open_select_promt_mode = nil
  return content
end


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
  model = 'claude-sonnet-4.5', -- Default model to use, see ':CopilotChatModels' for available models (can be specified manually in prompt via $).
  sticky = nil,                -- Default sticky prompt or array of sticky prompts to use at start of every new chat.

  temperature = 0.1,           -- GPT result temperature
  headless = false,            -- Do not write to chat buffer and use history(useful for using callback for custom processing)
  callback = nil,              -- Callback to use when ask response is received

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
    blend = 0,              -- window blend (transparency), 0-100, 0 is opaque, 100 is fully transparent
  },

  show_help = true,                 -- Shows help message as virtual lines when waiting for user input
  show_folds = true,                -- Shows folds for sections in chat
  auto_fold = false,                -- Automatically non-assistant messages in chat (requires 'show_folds' to be true)
  highlight_selection = true,       -- Highlight selection in the source buffer when in the chat window
  highlight_headers = true,         -- Highlight headers in chat, disable if using markdown renderers (like render-markdown.nvim)
  auto_follow_cursor = true,        -- Auto-follow cursor in chat
  auto_insert_mode = false,         -- Automatically enter insert mode when opening window and on new prompt
  insert_at_end = false,            -- Move cursor to end of buffer when inserting text
  clear_chat_on_new_prompt = false, -- Clears chat on every new prompt

  -- Static config starts here (can be configured only via setup function)

  debug = false,                                                   -- Enable debug logging (same as 'log_level = 'debug')
  log_level = 'info',                                              -- Log level to use, 'trace', 'debug', 'info', 'warn', 'error', 'fatal'
  proxy = nil,                                                     -- [protocol://]host[:port] Use this proxy
  allow_insecure = false,                                          -- Allow insecure server connections

  selection = 'visual',                                            -- Selection source
  chat_autocomplete = true,                                        -- Enable chat autocompletion (when disabled, requires manual `mappings.complete` trigger)
  history_path = vim.fn.stdpath('data') .. '/copilotchat_history', -- Default path to stored history

  headers = {
    user = question_header, -- Header to use for user questions
    assistant = answer_header, -- Header to use for AI answers
    tool = ' Tool ', -- Header to use for tool calls
  },
  separator = '───', -- Separator to use in chat

  -- default prompts
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
    Explain = {
      prompt = read_copilot_prompt('Explain.md'),
      sticky = '/COPILOT_EXPLAIN',
    },
    Ask = {
      prompt = read_copilot_prompt('Ask.md'),
      sticky = '/COPILOT_EXPLAIN',
    },
    Review = {
      prompt = read_copilot_prompt('Review.md'),
      sticky = '/COPILOT_REVIEW',
      selection = get_select_prompt_selection,
    },
    ReviewClear = {
      prompt = read_copilot_prompt('ReviewClear.md'),
      sticky = '/COPILOT_REVIEW',
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
    Fix = {
      prompt = read_copilot_prompt('Fix.md'),
    },
    Optimize = {
      prompt = read_copilot_prompt('Optimize.md'),
    },
    OneLineComment = {
      prompt = read_copilot_prompt('OneLineComment.md'),
    },
    OneParagraphComment = {
      prompt = read_copilot_prompt('OneParagraphComment.md'),
    },
    Docs = {
      prompt = read_copilot_prompt('Docs.md'),
      selection = get_select_prompt_selection,
    },
    Tests = {
      prompt = read_copilot_prompt('Tests.md'),
      selection = get_select_prompt_selection,
    },
    CodeGraph = {
      prompt = read_copilot_prompt('CodeGraph.md'),
      sticky = '/COPILOT_EXPLAIN',
      selection = get_select_prompt_selection,
    },
    MermaidUml = {
      prompt = read_copilot_prompt('MermaidUml.md'),
      sticky = '/COPILOT_EXPLAIN',
      selection = get_select_prompt_selection,
    },
    MermaidSequence = {
      prompt = read_copilot_prompt('MermaidSequence.md'),
      sticky = '/COPILOT_EXPLAIN',
      selection = get_select_prompt_selection,
    },
    FixDiagnostic = {
      prompt = read_copilot_prompt('FixDiagnostic.md'),
      selection = select.diagnostics,
    },
    -- Commit = {
    --   prompt = '> #gitdiff:staged\n\nWrite commit message for the change with commitizen convention. Make sure the title has maximum 50 characters and message is wrapped at 72 characters. Wrap the whole message in code block with language gitcommit.',
    -- },
    Commit = {
      prompt = read_copilot_prompt('Commit.md'),
      sticky = '#gitdiff:unstaged',
    },
    CommitStaged = {
      prompt = read_copilot_prompt('CommitStaged.md'),
      sticky = '#gitdiff:staged',
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
      normal = 'grr',
    },
    clear_stickies = {
      normal = 'grx',
    },
    accept_diff = {
      normal = '<C-y>',
      insert = '<C-y>',
    },
    jump_to_diff = {
      normal = 'gD',
    },
    quickfix_answers = {
      normal = 'gqa',
    },
    quickfix_diffs = {
      normal = 'gqd',
    },
    yank_diff = {
      normal = 'gy',
      register = '"',
    },
    show_diff = {
      normal = 'gd',
      full_diff = false, -- Show full diff instead of unified diff when showing diff window
    },
    show_info = {
      normal = 'gc',
    },
    -- WARNING: NOT WORKING
    -- show_context = {
    --   normal = 'gs',
    -- },
    show_help = {
      normal = 'g?',
    },
  },
}
local copilot_functions = require("CopilotChat.config.functions")
copilot_functions.gitdiff = {
  group = 'copilot',
  uri = 'git://diff/{target}',
  description =
  'Retrieves git diff information. Requires git to be installed. Useful for discussing code changes or explaining the purpose of modifications.',

  schema = {
    type = 'object',
    required = { 'target' },
    properties = {
      target = {
        type = 'string',
        description = 'Target to diff against.',
        enum = { 'unstaged', 'staged', '<sha>' },
        default = 'unstaged',
      },
    },
  },

  resolve = function(input, source)
    local file_path = vim.api.nvim_buf_get_name(source.bufnr)
    local file_dir
    if file_path ~= '' then
      file_dir = vim.fn.fnamemodify(file_path, ':h')
      if vim.fn.isdirectory(file_dir) == 0 then
        file_dir = source.cwd()
      end
    else
      file_dir = source.cwd()
    end

    local cmd = {
      'git',
      '-C',
      file_dir,
      'diff',
      '--no-color',
      '--no-ext-diff',
    }
    local cmd_stat = {
      'git',
      '-C',
      file_dir,
      'diff',
      '--stat',
      '--no-color',
      '--no-ext-diff',
    }

    if input.target == 'staged' then
      table.insert(cmd, '--staged')
      table.insert(cmd_stat, '--staged')
    elseif input.target == 'unstaged' then
      table.insert(cmd, '--')
      table.insert(cmd_stat, '--')
    else
      table.insert(cmd, input.target)
      table.insert(cmd_stat, input)
    end

    local cmd_out = utils.system(cmd)

    -- jugde if the diff is too large (> 30000 characters) to handle, use diff --stat to instead
    local out = cmd_out
    if #cmd_out.stdout > 30000 then
      out = utils.system(cmd_stat)
    end
    return {
      {
        uri = 'git://diff/' .. input.target,
        mimetype = 'text/plain',
        data = out.stdout,
      },
    }
  end,
}

vim.api.nvim_create_autocmd("BufEnter", {
  pattern = "copilot-*",
  callback = function()
    vim.opt_local.number = true
  end,
})
