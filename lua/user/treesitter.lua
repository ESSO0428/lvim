-- This module contains a number of default definitions
-- NOTE: 與 treesitter regex 不兼融，請避免 TSInstall regex
local rainbow_delimiters = require 'rainbow-delimiters'

---@class rainbow_delimiters
vim.g.rainbow_delimiters = {
  strategy = {
    [''] = rainbow_delimiters.strategy['global'],
    vim = rainbow_delimiters.strategy['local'],
  },
  query = {
    [''] = 'rainbow-delimiters',
    lua = 'rainbow-blocks',
  },
  highlight = {
    'RainbowDelimiterRed',
    'RainbowDelimiterYellow',
    'RainbowDelimiterBlue',
    'RainbowDelimiterOrange',
    'RainbowDelimiterGreen',
    'RainbowDelimiterViolet',
    'RainbowDelimiterCyan',
  },
}
pcall(function()
  require('nvim-dap-repl-highlights').setup()
end)
require 'nvim-treesitter.install'.compilers    = { "clang", "gcc" }
lvim.builtin.treesitter.ensure_installed       = {
  "comment", "markdown", "markdown_inline",
  "python", "lua", "vim", "bash", "html", "css", "scss", "json", "javascript",
  "dap_repl"
  -- "regex"
}
lvim.builtin.treesitter.ignore_install         = { "regex" }
lvim.builtin.treesitter.highlight              = {
  enable = true,        -- false will disable the whole extension
  disable = { "rust" }, -- list of language that will be disabled
  -- Required for spellcheck, some LaTex highlights and
  -- code block highlights that do not have ts grammar
  additional_vim_regex_highlighting = { 'org' },
}
lvim.builtin.treesitter.rainbow.enable         = true
lvim.builtin.treesitter.playground.keybindings = {
  focus_language = "f",
  goto_node = "<cr>",
  show_help = "?",
  toggle_anonymous_nodes = "a",
  toggle_hl_groups = "l",
  toggle_injected_languages = "t",
  toggle_language_display = "L",
  toggle_query_editor = "o",
  unfocus_language = "F",
  update = "R"
}
--[[
lvim.builtin.treesitter.rainbow = {
  enable = true,
  -- disable = { "jsx", "cpp" }, list of languages you want to disable the plugin for
  extended_mode = true, -- Also highlight non-bracket delimiters like html tags, boolean or table: lang -> boolean
  max_file_lines = nil, -- Do not enable for files with more than n lines, int
  -- colors = {}, -- table of hex strings
  -- termcolors = {} -- table of colour name strings
}
]]
-- 启用增量选择
lvim.builtin.treesitter.incremental_selection = {
  enable = true,
  keymaps = {
    init_selection = '<CR>',
    node_incremental = '<CR>',
    node_decremental = '<BS>',
    -- scope_incremental = '.',
  }
}
-- 启用基于 Treesitter 的代码格式化(=)
-- 尊重 lvim 默認配置，故這裡註解以下
--[[
vim.builtin.treesitter.indent = {
  enable = true
}
]]
vim.api.nvim_create_autocmd('FileType', {
  pattern = 'mysql',
  callback = function(args)
    vim.treesitter.start(args.buf, 'sql')
    vim.bo[args.buf].syntax = 'on' -- only if additional legacy syntax is needed
  end
})
local ft = require('Comment.ft')
ft.set('mysql', '-- %s')
