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
require('avante_lib').load()
require('avante').setup({
  ---@alias Provider "claude" | "openai" | "azure" | "gemini" | "cohere" | "copilot" | string
  provider = "copilot",       -- Recommend using Claude
  behaviour = {
    auto_suggestions = false, -- Experimental stage
    auto_set_highlight_group = true,
    auto_set_keymaps = true,
    auto_apply_diff_after_generation = false,
    support_paste_from_clipboard = false,
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
    },
  },
  hints = { enabled = true },
  windows = {
    ---@type "right" | "left" | "top" | "bottom"
    position = "right", -- the position of the sidebar
    wrap = true,        -- similar to vim.o.wrap
    width = 30,         -- default % based on available width
    sidebar_header = {
      align = "center", -- left, center, right for title
      rounded = true,
    },
    input = {
      prefix = "> ",
    },
    edit = {
      border = "rounded",
      start_insert = true, -- Start insert mode when opening the edit window
    },
    ask = {
      floating = false,    -- Open the 'AvanteAsk' prompt in a floating window
      start_insert = true, -- Start insert mode when opening the ask window, only effective if floating = true.
      border = "rounded",
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
  },
})
