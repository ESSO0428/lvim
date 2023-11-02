lvim.transparent_window = true
---[[
-- lvim.colorscheme = "tokyonight-night"
-- lvim.builtin.lualine.options.theme = "tokyonight-night"
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

vim.cmd "let &fcs='eob: '"
-- vim.cmd "au ColorScheme * hi BufferLineSeparator guifg=#504945"
-- vim.cmd "au ColorScheme * hi BufferLineSeparatorSelected guifg=#504945"
-- vim.cmd "au ColorScheme * hi BufferLineSeparatorVisible guifg=#504945"

-- vim.cmd "au ColorScheme * hi BufferLineSeparator guifg=#000000"
-- vim.cmd "au ColorScheme * hi BufferLineSeparatorSelected guifg=#000000"
-- vim.cmd "au ColorScheme * hi BufferLineSeparatorVisible guifg=#000000"
-- vim.cmd "au ColorScheme * hi BufferLineTabSeparator guifg=#000000"

vim.cmd "au ColorScheme * hi BufferLineBufferSelected guifg=#3ab6f0"
vim.cmd "au ColorScheme * hi @include guifg=#a184fe"
vim.cmd "au ColorScheme * hi @variable guifg=#87ceeb"
vim.cmd "au ColorScheme * hi @field guifg=#d19a66"
vim.cmd "au ColorScheme * hi @boolean guifg=#3ab6f0"
vim.cmd "au ColorScheme * hi @operator guifg=#ffffff"

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
vim.cmd "au ColorScheme * hi Todo cterm=bold gui=bold guifg=#71839b guibg=none"
vim.cmd "au BufEnter *.md setlocal syntax=markdown"

vim.g['semshi#filetypes'] = { 'python' }
vim.g['semshi#simplify_markup'] = false
vim.g['semshi#error_sign'] = false
-- pcall(vim.cmd, "au ColorScheme * highlight! semshiImported gui=bold guifg=#e0949e")
pcall(vim.cmd, "au ColorScheme * highlight! semshiImported gui=bold guifg=#ff6666")
pcall(vim.cmd, "au ColorScheme * highlight! semshiGlobal gui=bold guifg=#87ceeb")

pcall(vim.cmd, "au ColorScheme * highlight! link semshiParameter @parameter")
pcall(vim.cmd, "au ColorScheme * highlight! link semshiParameterUnused @parameter")
pcall(vim.cmd, "au ColorScheme * highlight! semshiParameterUnused gui=undercurl")
-- pcall(vim.cmd, "au ColorScheme * highlight! link semshiAttribute @attribute")
pcall(vim.cmd, "au ColorScheme * highlight! link semshiAttribute @field")
-- pcall(vim.cmd, "au ColorScheme * highlight! link semshiBuiltin @function.builtin")
pcall(vim.cmd, "au ColorScheme * highlight! semshiBuiltin guifg=#dbc074")
-- pcall(vim.cmd, "au ColorScheme * highlight! link semshiBuiltin @field")
pcall(vim.cmd, "au ColorScheme * highlight! link semshiUnresolved @text.warning")
pcall(vim.cmd, "au ColorScheme * highlight! link semshiSelf @variable.builtin")

-- vim.cmd "au ColorScheme * highlight! @variable guifg=#ba4351"


vim.cmd "au ColorScheme * hi Comment guifg=#71839b"
vim.cmd "au ColorScheme * hi Whitespace guifg=#504945"
--]]

-- lvim.builtin.bufferline

local function LspStatus()
  return require("lsp-progress").progress({
    format = function(messages)
      return #messages > 0 and " LSP " .. table.concat(messages, " ") or ""
    end,
  })
end


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
    { 'b:jupyter_kernel' },
    LspStatus
  },
  lualine_x = {
    { 'vim.api.nvim_call_function("getcwd", {0})' }, { 'encoding' },
    { 'fileformat' },
    { 'filetype',                                 icon_only = false }
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
require("scrollbar").setup()
require("scrollbar").setup({
  show = true,
  handle = {
    text = " ",
    color = "#928374",
    hide_if_all_visible = true,
  },
  marks = {
    Search = { color = "yellow" },
    Misc = { color = "purple" },
  },
})
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
