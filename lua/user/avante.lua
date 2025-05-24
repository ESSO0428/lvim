local M = {}

-- NOTE: Avante ColorScheme
-- AvanteSidebarWinSeparator can be linked to FloatBorder or NormalFloat (defaults to NormalFloat).
vim.cmd "au ColorScheme * hi link AvanteSidebarWinSeparator WinSeparator"
vim.cmd "au ColorScheme * hi link AvanteSuggestion Comment"
vim.cmd "au ColorScheme * hi link AvanteAnnotation Comment"
vim.cmd "au ColorScheme * hi link AvantePopupHint NormalFloat"
vim.cmd "au ColorScheme * hi link AvanteInlineHint Keyword"
vim.cmd "au ColorScheme * hi AvanteConflictCurrentLabel guibg=#2C374D"
vim.cmd "au ColorScheme * hi link AvanteConflictCurrent DiffText"
vim.cmd "au ColorScheme * hi AvanteConflictIncomingLabel guibg=#1a3c3e"
vim.cmd "au ColorScheme * hi link AvanteConflictIncoming DiffAdd"

-- NOTE: Switch Avante mode
local function avante_switch_mode()
  local avante_config = require("avante.config")

  local modes = {
    { name = "legacy",  label = "Legacy mode (use SEARCH/REPLACE diff blocks)" },
    { name = "agentic", label = "Agentic mode (can directly overwrite file)" },
  }

  local current_mode = avante_config.mode or "legacy"

  -- Prepare the menu entries, add * to the current mode
  local items = vim.tbl_map(function(mode)
    local prefix = (mode.name == current_mode) and "* " or "  "
    return {
      mode = mode.name,
      display = prefix .. mode.label,
    }
  end, modes)

  vim.ui.select(items, {
    prompt = "Select Avante mode:",
    format_item = function(item) return item.display end,
  }, function(choice)
    if not choice then return end

    -- Always send reminder prompt, no matter if mode actually changed
    avante_config.mode = choice.mode
    if choice.mode == "legacy" then
      vim.notify("[Avante] Switched to legacy mode", vim.log.levels.INFO)
      require("avante.api").ask({
        question =
        "Reminder: Legacy mode enabled. Please apply the SEARCH/REPLACE diff block rule on your next response for file edits. Do not change files in the current conversation."
      })
    else
      vim.notify("[Avante] Switched to agentic mode", vim.log.levels.INFO)
      require("avante.api").ask({
        question =
        "Reminder: Agentic mode enabled. You may freely modify files as you normally would, starting with your next response to a file edit request. Do not make any file changes in the current conversation."
      })
    end
  end)
end

-- Optionally, add a command to call the menu
vim.api.nvim_create_user_command("AvanteSwitchMode", avante_switch_mode, {})

-- Optional: Add keymap for quick access
vim.keymap.set("n", "<leader>am", avante_switch_mode, {
  desc = "Select Avante mode (legacy/agentic)"
})

-- NOTE: Avante config
local Utils
local ok_utils, utils_module = pcall(require, "avante.utils")
if ok_utils then
  Utils = utils_module
else
  Utils = {
    has = function(_) return false end -- Simple fallback implementation
  }
  vim.notify("[Avante] avante.utils module not found", vim.log.levels.WARN)
end

local ok_config, avante_config = pcall(require, 'avante.config')
if ok_config then
  avante_config.support_paste_image = function()
    local has_xclip = os.execute('which xclip > /dev/null 2>&1') == 0
    if has_xclip then
      return Utils.has("img-clip.nvim") or Utils.has("img-clip")
    else
      return false
    end
  end
end

local api_key = os.getenv("OPENAI_API_KEY")

local function has_command(cmd)
  local handle = io.popen("command -v " .. cmd .. " 2>/dev/null")
  local result = handle:read("*a")
  handle:close()
  return result ~= ""
end

local function is_docker_running()
  local handle = io.popen("docker info 2>&1")
  local result = handle:read("*a")
  handle:close()
  return not result:match("Cannot connect to the Docker daemon")
end

local rag_enabled = true

if not api_key or api_key == "" then
  vim.notify("[RAG] OPENAI_API_KEY not found. RAG service disabled.", vim.log.levels.WARN)
  rag_enabled = false
elseif not has_command("docker") then
  vim.notify("[RAG] Docker command not found. RAG service disabled.", vim.log.levels.WARN)
  rag_enabled = false
elseif not is_docker_running() then
  vim.notify("[RAG] Docker daemon is not running. RAG service disabled.", vim.log.levels.WARN)
  rag_enabled = false
end

---@class avante.Config
M.opts = {
  ---@alias Provider "claude" | "openai" | "azure" | "gemini" | "cohere" | "copilot" | string
  provider = "copilot", -- Recommend using Claude
  ---@alias Mode "agentic" | "legacy"
  mode = "legacy",      -- The default mode for interaction. "agentic" uses tools to automatically generate code, "legacy" uses the old planning method to generate code.
  copilot = {
    endpoint = "https://api.githubcopilot.com",
    model = "claude-sonnet-4",
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
  disabled_tools = {},
  rag_service = {
    enabled = rag_enabled,                  -- Enables the RAG service
    host_mount = os.getenv("HOME"),         -- Host mount path for the rag service
    provider = "openai",                    -- The provider to use for RAG service (e.g. openai or ollama)
    llm_model = "",                         -- The LLM model to use for RAG service
    embed_model = "",                       -- The embedding model to use for RAG service
    endpoint = "https://api.openai.com/v1", -- The API endpoint for RAG service
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
    ["copilot-claude-3.7-sonnet"] = {
      __inherited_from = "copilot",
      endpoint = "https://api.githubcopilot.com",
      model = "claude-3.7-sonnet",
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
    ["copilot-gpt-4.1"] = {
      __inherited_from = "copilot",
      endpoint = "https://api.githubcopilot.com",
      model = "gpt-4.1",
      proxy = nil,
      allow_insecure = false,
      timeout = 30000,
      temperature = 0,
      max_tokens = 64000,
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
  behaviour = {
    auto_suggestions = false, -- Experimental stage
    auto_set_highlight_group = true,
    auto_set_keymaps = true,
    auto_apply_diff_after_generation = false,
    support_paste_from_clipboard = false,
    minimize_diff = true,         -- Whether to remove unchanged lines when applying a code block
    enable_token_counting = true, -- Whether to enable token counting. Default to true.
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
      retry_user_request = "r",
      edit_user_request = "e",
      switch_windows = "<Tab>",
      reverse_switch_windows = "<S-Tab>",
      remove_file = "d",
      add_file = "@",
      close = { "q", "<leader>q" }, -- default: close = { "<Esc>", "q" }
      close_from_input = nil,       -- e.g., { normal = "<Esc>", insert = "<C-d>" }
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
-- system_prompt as function ensures LLM always has latest MCP server state
-- This is evaluated for every message, even in existing chats
M.opts.system_prompt = function()
  local ok_mcphub, mcphub = pcall(require, "mcphub")
  if ok_mcphub then
    local hub = mcphub.get_hub_instance()
    return hub and hub:get_active_servers_prompt() or ""
  end
  return ""
end

-- Using function prevents requiring mcphub before it's loaded
local ok_avante_ext, avante_ext = pcall(require, "mcphub.extensions.avante")
if ok_avante_ext then
  M.opts.custom_tools = function()
    return {
      avante_ext.mcp_tool(),
    }
  end
end

-- add disabled tools in table and unique
local tools_to_disable = {
  "list_files", -- Built-in file operations
  "search_files",
  "read_file",
  "create_file",
  "rename_file",
  "delete_file",
  "create_dir",
  "rename_dir",
  "delete_dir",
  "bash", -- Built-in terminal access
}
for _, tool in ipairs(tools_to_disable) do
  if not vim.tbl_contains(M.opts.disabled_tools, tool) then
    table.insert(M.opts.disabled_tools, tool)
  end
end

return M
