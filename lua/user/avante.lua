local M = {}

-- NOTE: Avante ColorScheme
vim.cmd "au ColorScheme * hi link AvanteSuggestion Comment"
vim.cmd "au ColorScheme * hi link AvanteAnnotation Comment"
vim.cmd "au ColorScheme * hi link AvantePopupHint NormalFloat"
vim.cmd "au ColorScheme * hi link AvanteInlineHint Keyword"
vim.cmd "au ColorScheme * hi AvanteConflictCurrentLabel guibg=#2C374D"
vim.cmd "au ColorScheme * hi link AvanteConflictCurrent DiffText"
vim.cmd "au ColorScheme * hi AvanteConflictIncomingLabel guibg=#1a3c3e"
vim.cmd "au ColorScheme * hi link AvanteConflictIncoming DiffAdd"

-- NOTE: `AvanteCacheReset` resolves issues
-- where Avante is unusable
-- and throws `Make sure to build avante (missing avante_templates)`.
-- It:
--  1. Reinitializes the avante.path module
--  2. Creates cache files and history records
--  3. Loads `avante_templates`
-- Reloading this workflow may correct Avante.
vim.api.nvim_create_user_command('AvanteCacheReset', function() require("avante.path").setup() end, {})

-- NOTE: Avante config
local Utils = require("avante.utils")
require('avante.config').support_paste_image = function()
  local has_xclip = os.execute('which xclip > /dev/null 2>&1') == 0
  if has_xclip then
    return Utils.has("img-clip.nvim") or Utils.has("img-clip")
  else
    return false
  end
end

---@class avante.Config
M.opts = {
  ---@alias Provider "claude" | "openai" | "azure" | "gemini" | "cohere" | "copilot" | string
  provider = "copilot", -- Recommend using Claude
  copilot = {
    endpoint = "https://api.githubcopilot.com",
    model = "claude-3.7-sonnet",
    proxy = nil,            -- [protocol://]host[:port] Use this proxy
    allow_insecure = false, -- Allow insecure server connections
    timeout = 30000,        -- Timeout in milliseconds
    temperature = 0,
    -- NOTE: [2025-03-04 00:34]
    -- Default Copilot GPT-4o config in avante.nvim used **4096 tokens**.
    -- However, 4096 is nearly unusable for Claude-3.5 or 3.7.
    -- Even GPT-4o struggles at 4096 due to Vim's scheduling mechanism.
    -- - Related issue: [#981](https://github.com/yetone/avante.nvim/issues/981)
    -- Copilot previously claimed **8000 tokens support**, and this setting
    -- works smoothly with `claude-3.7-sonnet`. `claude-3.5-sonnet` has not been tested yet.
    max_tokens = 32768,
  },
  vendors = {
    ["copilot-claude-3.7-sonnet-thought"] = {
      __inherited_from = "copilot",
      endpoint = "https://api.githubcopilot.com",
      model = "claude-3.7-sonnet-thought",
      proxy = nil,
      allow_insecure = false,
      timeout = 30000,
      temperature = 0,
      max_tokens = 32768,
    },
    ["copilot-claude-3.5-sonnet"] = {
      __inherited_from = "copilot",
      endpoint = "https://api.githubcopilot.com",
      model = "claude-3.5-sonnet",
      proxy = nil,
      allow_insecure = false,
      timeout = 30000,
      temperature = 0,
      max_tokens = 32768,
    },
    ["copilot-gpt-4o"] = {
      __inherited_from = "copilot",
      endpoint = "https://api.githubcopilot.com",
      model = "gpt-4o",
      proxy = nil,
      allow_insecure = false,
      timeout = 30000,
      temperature = 0,
      max_tokens = 64000,
    },
    ["copilot-o1"] = {
      __inherited_from = "copilot",
      endpoint = "https://api.githubcopilot.com",
      model = "o1",
      proxy = nil,
      allow_insecure = false,
      timeout = 30000,
      temperature = 0,
      max_tokens = 20000,
    },
  },
  system_prompt = function()
    local hub = require("mcphub").get_hub_instance()
    return hub:get_active_servers_prompt()
  end,
  -- The custom_tools type supports both a list and a function that returns a list. Using a function here prevents requiring mcphub before it's loaded
  custom_tools = function()
    return {
      require("mcphub.extensions.avante").mcp_tool(),
    }
  end,
  behaviour = {
    auto_suggestions = false, -- Experimental stage
    auto_set_highlight_group = true,
    auto_set_keymaps = true,
    auto_apply_diff_after_generation = false,
    support_paste_from_clipboard = false,
    minimize_diff = true,                -- Whether to remove unchanged lines when applying a code block
    enable_token_counting = true,        -- Whether to enable token counting. Default to true.
    enable_cursor_planning_mode = false, -- Whether to enable Cursor Planning Mode. Default to false.
  },
  mappings = {
    --- @class AvanteConflictMappings
    diff = {
      ours = "cu",
      theirs = "co",
      all_theirs = "cO",
      both = "cN",
      cursor = "cn",
      next = "]x",
      prev = "[x",
    },
    suggestion = {
      accept = "<M-l>",
      next = "<M-]>",
      prev = "<M-[>",
      dismiss = "<C-]>",
    },
    jump = {
      next = "]]",
      prev = "[[",
    },
    submit = {
      normal = "<CR>",
      insert = "<C-s>",
    },
    sidebar = {
      apply_all = "A",
      apply_cursor = "a",
      switch_windows = "<Tab>",
      reverse_switch_windows = "<S-Tab>",
      remove_file = "d",
      add_file = "@",
      close = { "q" },        -- default: close = { "<Esc>", "q" }
      close_from_input = nil, -- e.g., { normal = "<Esc>", insert = "<C-d>" }
    },
    files = {
      add_current = "<leader>ac", -- Add current buffer to selected files
    },
    select_model = "<leader>a?",  -- Select model command
  },
  hints = { enabled = true },
  windows = {
    ---@type "right" | "left" | "top" | "bottom"
    position = "right", -- the position of the sidebar
    wrap = true,        -- similar to vim.o.wrap
    width = 30,         -- default % based on available width
    sidebar_header = {
      enabled = true,   -- true, false to enable/disable the header
      align = "center", -- left, center, right for title
      rounded = true,
    },
    input = {
      prefix = "> ",
      height = 8, -- Height of the input window in vertical layout
    },
    edit = {
      border = "rounded",
      start_insert = false, -- Start insert mode when opening the edit window
    },
    ask = {
      floating = false,     -- Open the 'AvanteAsk' prompt in a floating window
      start_insert = false, -- Start insert mode when opening the ask window, only effective if floating = true.
      border = "rounded",
      ---@type "ours" | "theirs"
      focus_on_apply = "ours", -- which diff to focus after applying
    },
  },
  highlights = {
    ---@type AvanteConflictHighlights
    diff = {
      current = "DiffText",
      incoming = "DiffAdd",
    },
  },
  --- @class AvanteConflictUserConfig
  diff = {
    autojump = true,
    ---@type string | fun(): any
    list_opener = "copen",
    --- Override the 'timeoutlen' setting while hovering over a diff (see :help timeoutlen).
    --- Helps to avoid entering operator-pending mode with diff mappings starting with `c`.
    --- Disable by setting to -1.
    override_timeoutlen = 500,
  },
  suggestion = {
    debounce = 600,
    throttle = 600,
  },
}

return M
