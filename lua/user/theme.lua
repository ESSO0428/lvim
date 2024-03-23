lvim.transparent_window               = true
-- vim.cmd "au ColorScheme * hi Visual cterm=reverse gui=reverse"
---[[
-- lvim.colorscheme = "tokyonight-night"
-- lvim.builtin.lualine.options.theme = "tokyonight-night"
vim.g.limelight_conceal_guifg         = '#545763'
lvim.keys.visual_mode['<leader>ta']   = { "<Plug>(Limelight)" }
lvim.builtin.which_key.mappings["ta"] = { "<cmd>Limelight<cr>", "Limelight Close" }
lvim.builtin.which_key.mappings["tA"] = { "<cmd>Limelight!<cr>", "Limelight Close (All)" }
if lvim.transparent_window == true then
  vim.cmd "au ColorScheme * hi Normal ctermbg=none guibg=none"
  vim.cmd "au ColorScheme * hi SignColumn ctermbg=none guibg=none"
  vim.cmd "au ColorScheme * hi NormalNC ctermbg=none guibg=none"
  vim.cmd "au ColorScheme * hi MsgArea ctermbg=none guibg=none"
  vim.cmd "au ColorScheme * hi TelescopeNormal ctermbg=none guibg=none"
  vim.cmd "au ColorScheme * hi NormalFloat ctermbg=none guibg=none"
  vim.cmd "au ColorScheme * hi FloatBorder ctermbg=none guibg=none"
  vim.cmd "au ColorScheme * hi Float ctermbg=none guibg=none"
  vim.cmd "au ColorScheme * hi NvimFloat ctermbg=none guibg=none"
  vim.cmd "au ColorScheme * hi WhichKeyFloat ctermbg=none guibg=none"
  vim.cmd "au ColorScheme * hi NvimTreeNormal ctermbg=none guibg=none"
  vim.cmd "au ColorScheme * hi NvimTreeNormalNC ctermbg=none guibg=none"
  -- vim.cmd "au ColorScheme * hi WinSeparator cterm=bold gui=bold guifg=#000000"
  vim.cmd "au ColorScheme * hi NvimTreeWinSeparator ctermbg=none guibg=none"
  vim.cmd "au ColorScheme * hi Navbuddy ctermbg=none guibg=none"
end
vim.cmd "let &fcs='eob: '"
-- vim.cmd "au ColorScheme * hi BufferLineSeparator guifg=#504945"
-- vim.cmd "au ColorScheme * hi BufferLineSeparatorSelected guifg=#504945"
-- vim.cmd "au ColorScheme * hi BufferLineSeparatorVisible guifg=#504945"

-- vim.cmd "au ColorScheme * hi BufferLineSeparator guifg=#000000"
-- vim.cmd "au ColorScheme * hi BufferLineSeparatorSelected guifg=#000000"
-- vim.cmd "au ColorScheme * hi BufferLineSeparatorVisible guifg=#000000"
-- vim.cmd "au ColorScheme * hi BufferLineTabSeparator guifg=#000000"

vim.cmd "au ColorScheme * hi @include.python guifg=#c586c0"
vim.cmd "au ColorScheme * hi @variable guifg=#9cdcfe"
vim.cmd "au ColorScheme * hi @conditional.python guifg=#c586c0"
vim.cmd "au ColorScheme * hi @exception.python guifg=#c586c0"
vim.cmd "au ColorScheme * hi @method.call.python guifg=#daccaa"
vim.cmd "au ColorScheme * hi @function.python guifg=#daccaa"
vim.cmd "au ColorScheme * hi @function.call.python guifg=#daccaa"
vim.cmd "au ColorScheme * hi @field.python guifg=#d19a66"
vim.cmd "au ColorScheme * hi @boolean.python guifg=#3ab6f0"
vim.cmd "au ColorScheme * hi @operator guifg=#ffffff"
vim.cmd "au ColorScheme * hi @text.reference guifg=#3794ff"
vim.cmd "au ColorScheme * hi @punctuation.special.markdown guifg=#9d7cd8"
vim.cmd "au ColorScheme * hi @number.python guifg=#b5cea8"
vim.cmd "au ColorScheme * hi @float.python guifg=#b5cea8"
vim.cmd "au ColorScheme * hi @string.python guifg=#ce9178"
vim.cmd "au ColorScheme * hi @parameter.python guifg=#68b2c8"
vim.cmd "au ColorScheme * hi @field.python guifg=#4ec9b0"
vim.cmd "au ColorScheme * hi @type.python guifg=#4ec9b0"
vim.cmd "au ColorScheme * hi @constant.python guifg=#4fceff"

if lvim.transparent_window == true then
  vim.cmd "au ColorScheme * hi BufferLineBufferSelected guifg=#3ab6f0"

  vim.cmd "au ColorScheme * hi BufferLineTabSelected guifg=#3ab6f0"
  vim.cmd "au ColorScheme * hi BufferLineNumbersSelected cterm=bold,italic gui=bold,italic guifg=#3ab6f0"
  vim.cmd "au ColorScheme * hi LineNr guifg=#71839b"
  vim.cmd "au ColorScheme * hi CursorLineNr cterm=bold gui=bold guifg=#dbc074"
  vim.cmd "au ColorScheme * hi IlluminatedWord guibg=none"
  vim.cmd "au ColorScheme * hi illuminatedCurWord guibg=none"
  vim.cmd "au ColorScheme * hi IlluminatedWordWrite guibg=none"
  vim.cmd "au ColorScheme * hi IlluminatedWordRead guibg=none"
  vim.cmd "au ColorScheme * hi IlluminatedWordText guibg=none"

  vim.cmd "au ColorScheme * highlight IndentBlanklineContextChar guifg=#A184FE gui=nocombine" -- #737aa2
end

vim.cmd "au ColorScheme * hi Todo cterm=bold gui=bold guifg=#71839b guibg=none"
vim.cmd "au BufEnter *.md setlocal syntax=markdown"

vim.g['semshi#filetypes'] = { 'python' }
vim.g['semshi#simplify_markup'] = false
vim.g['semshi#error_sign'] = false
-- pcall(vim.cmd, "au ColorScheme * highlight! semshiImported gui=bold guifg=#e0949e")
-- pcall(vim.cmd, "au ColorScheme * highlight! semshiImported gui=bold guifg=#ff6666")
pcall(vim.cmd, "au ColorScheme * highlight! semshiImported gui=bold guifg=#4ec9b0")
-- pcall(vim.cmd, "au ColorScheme * highlight! semshiGlobal gui=bold guifg=#9cdcfe")
pcall(vim.cmd, "au ColorScheme * highlight! semshiGlobal gui=bold")

pcall(vim.cmd, "au ColorScheme * highlight! link semshiParameter @parameter.python")
pcall(vim.cmd, "au ColorScheme * highlight! link semshiParameterUnused @parameter.python")
pcall(vim.cmd, "au ColorScheme * highlight! semshiParameterUnused gui=undercurl")
-- pcall(vim.cmd, "au ColorScheme * highlight! link semshiAttribute @attribute")
pcall(vim.cmd, "au ColorScheme * highlight! link semshiAttribute @field")
-- pcall(vim.cmd, "au ColorScheme * highlight! link semshiBuiltin @function.builtin")
pcall(vim.cmd, "au ColorScheme * highlight! semshiBuiltin guifg=#dcdcaa")
-- pcall(vim.cmd, "au ColorScheme * highlight! link semshiBuiltin @field")
pcall(vim.cmd, "au ColorScheme * highlight! link semshiUnresolved @text.warning")
pcall(vim.cmd, "au ColorScheme * highlight! link semshiSelf @variable.builtin")

-- vim.cmd "au ColorScheme * highlight! @variable guifg=#ba4351"

vim.cmd "au ColorScheme * hi Whitespace guifg=#504945"
if lvim.transparent_window == true then
  vim.cmd "au ColorScheme * hi Comment guifg=#71839b"
end
--]]

-- lvim.builtin.bufferline
vim.g.vim_pid                                          = vim.fn.getpid()
lvim.builtin.lualine.options                           = {
  globalstatus = true,
  component_separators = { left = '', right = '' },
  section_separators = { left = '', right = '' }
}
local components                                       = require "lvim.core.lualine.components"
lvim.builtin.lualine.sections                          = {
  lualine_a = { { 'mode' } },
  lualine_c = {
    components.diff,
    components.python_env,
    { 'b:jupyter_kernel' }
  },
  lualine_x = {
    { 'vim.api.nvim_call_function("getcwd", {0})' }, { 'encoding' },
    { 'fileformat' },
    { 'filetype',                                 icon_only = false },
    {
      'pid',
      fmt = function() return "pid:" .. vim.g.vim_pid end
    }
  },
}
lvim.builtin.telescope.pickers.find_files.find_command = { "fd", "--type", "f" }

lvim.builtin.telescope.defaults.layout_strategy        = "horizontal"
lvim.builtin.telescope.defaults.layout_config          = {
  scroll_speed = 1,
  width = 0.95,
  height = 0.65,
  prompt_position = "top",
  -- preview_width   = 0.50
  horizontal = {
    scroll_speed = 1,
    width = 0.95,
    height = 0.65,
  },
  vertical = {
    scroll_speed = 1,
    width = 0.95,
    height = 0.95,
    preview_height = 0.50,
    mirror = true
  }
}
vim.cmd "autocmd User TelescopePreviewerLoaded setlocal number"
local status_ok, PlugNotify = pcall(require, "notify")
if not status_ok then
  return
else
  local notify = require("notify")
  local message_notifications = {}
  local buffered_messages = {
    "Client %d+ quit",
  }
  vim.notify = function(msg, level, opts)
    opts = opts or {}
    for _, pattern in ipairs(buffered_messages) do
      if string.find(msg, pattern) then
        if message_notifications[pattern] then
          opts.replace = message_notifications[pattern]
        end
        opts.on_close = function()
          message_notifications[pattern] = nil
        end
        message_notifications[pattern] = notify.notify(msg, level, opts)
        return
      end
    end
    notify.notify(msg, level, opts)
  end
end
local autocommand = {
  "TextYankPost",      -- see `:h autocmd-events`
  {                    -- this table is passed verbatim as `opts` to `nvim_create_autocmd`
    pattern = { "*" }, -- see `:h autocmd-events`
    command = "silent! lua vim.highlight.on_yank{higroup='IncSearch', timeout=200}",
  }
}
table.insert(lvim.autocommands, autocommand)
