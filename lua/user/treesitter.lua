---@type rainbow_delimiters.config
vim.g.rainbow_delimiters                       = {
  strategy = {
    [''] = 'rainbow-delimiters.strategy.global',
    vim = 'rainbow-delimiters.strategy.local',
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
require 'nvim-treesitter.install'.compilers    = { "clang", "gcc" }
lvim.builtin.treesitter.ensure_installed       = {
  "comment", "markdown", "markdown_inline",
  "python", "lua", "vim", "bash", "html", "css", "scss", "json", "javascript",
  "dap_repl"
  -- "regex"
}
lvim.builtin.treesitter.ignore_install         = { "regex", "org" }
lvim.builtin.treesitter.highlight              = {
  enable = true, -- false will disable the whole extension
  -- disable = { "rust" }, -- list of language that will be disabled
  disable = function(_, bufnr)
    local filetype = vim.bo[bufnr].filetype
    local disable_filetypes = {
      rust = true,
    }
    return disable_filetypes[filetype] or false
  end,
  -- Required for spellcheck, some LaTex highlights and
  -- code block highlights that do not have ts grammar
  additional_vim_regex_highlighting = { 'org', "python", "sql", "markdown" },
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

-- 启用增量选择
lvim.builtin.treesitter.incremental_selection  = {
  enable = true,
  disable = function(_, bufnr)
    local filetype = vim.bo[bufnr].filetype
    local disable_filetypes = {
      Avante = true,
      AvanteSelectedFiles = true,
      AvanteInput = true,
    }
    return disable_filetypes[filetype] or false
  end,
  keymaps = {
    init_selection = '<cr>',
    node_incremental = '<cr>',
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
    -- vim.bo[args.buf].syntax = 'on' -- only if additional legacy syntax is needed
  end
})
vim.api.nvim_create_autocmd("FileType", {
  pattern = "Avante",
  callback = function()
    require "rainbow-delimiters".disable(0)
  end
})

vim.api.nvim_create_autocmd("FileType", {
  pattern = { "sql", "mysql" },
  once = true,
  callback = function()
    local ft = require('Comment.ft')
    ft.set('mysql', '-- %s')
  end
})
