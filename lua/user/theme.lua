lvim.transparent_window                               = true
---@diagnostic disable-next-line: duplicate-set-field
require("lvim.core.autocmds").enable_transparent_mode = function()
  vim.api.nvim_create_autocmd("ColorScheme", {
    pattern = "*",
    callback = function()
      local hl_groups = {
        "Normal",
        "SignColumn",
        "NormalNC",
        -- "TelescopeBorder",
        "NvimTreeNormal",
        "NvimTreeNormalNC",
        "EndOfBuffer",
        "MsgArea",
      }
      for _, name in ipairs(hl_groups) do
        vim.cmd(string.format("highlight %s ctermbg=none guibg=none", name))
      end
    end,
  })
  vim.opt.fillchars = "eob: "
end
vim.api.nvim_create_autocmd("BufWritePost", {
  pattern = get_config_dir():gsub("\\", "/") .. "/*.lua",
  callback = function()
    vim.defer_fn(function()
      vim.cmd("highlight link TelescopeBorder FloatBorder")
    end, 300)
  end,
})
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
  vim.cmd "au ColorScheme * hi WinBarNC cterm=bold guifg=NvimLightGrey4 guibg=none"
  vim.cmd "au ColorScheme * exec 'hi FoldColumn guibg=none guifg=' . synIDattr(synIDtrans(hlID('Folded')), 'fg', 'gui')"
  vim.cmd "au ColorScheme * hi NormalNC ctermbg=none guibg=none"
  vim.cmd "au ColorScheme * hi MsgArea ctermbg=none guibg=none"
  vim.cmd "au ColorScheme * hi TelescopeNormal ctermbg=none guibg=none"
  vim.cmd "au ColorScheme * hi NormalFloat ctermbg=none guibg=none"
  vim.cmd "au ColorScheme * hi FloatBorder ctermbg=none guibg=none guifg=#3d59a1"
  vim.cmd "au ColorScheme * hi Float ctermbg=none guibg=none"
  vim.cmd "au ColorScheme * hi NvimFloat ctermbg=none guibg=none"
  vim.cmd "au ColorScheme * hi Pmenu ctermbg=none guibg=none guifg=none"
  vim.cmd "au ColorScheme * hi WhichKeyFloat ctermbg=none guibg=none"
  vim.cmd "au ColorScheme * hi NvimTreeNormal ctermbg=none guibg=none"
  vim.cmd "au ColorScheme * hi NvimTreeNormalNC ctermbg=none guibg=none"
  -- vim.cmd "au ColorScheme * hi WinSeparator cterm=bold gui=bold guifg=#000000"
  vim.cmd "au ColorScheme * hi NvimTreeWinSeparator ctermbg=none guibg=none"
  vim.cmd "au ColorScheme * hi Navbuddy ctermbg=none guibg=none"
  vim.cmd "au ColorScheme * hi WindowPickerStatusLine ctermfg=15 guifg=#ededed guibg=#e35e4f"
  vim.cmd "au ColorScheme * hi WindowPickerStatusLineNC ctermfg=15 ctermbg=4 gui=bold guifg=#ededed guibg=#4493c8"
  vim.cmd "au ColorScheme * hi WindowPickerWinBar ctermfg=15 guifg=#ededed guibg=#e35e4f"
  vim.cmd "au ColorScheme * hi WindowPickerWinBarNC ctermfg=15 ctermbg=4 gui=bold guifg=#ededed guibg=#4493c8"
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
vim.cmd "au ColorScheme * hi pythonInclude guifg=#c586c0"
vim.cmd "au ColorScheme * hi @keyword.import guifg=#c586c0"
vim.cmd "au ColorScheme * hi @variable guifg=#9cdcfe"
vim.cmd "au ColorScheme * hi @conditional.python guifg=#c586c0"
vim.cmd "au ColorScheme * hi @exception.python guifg=#c586c0"
vim.cmd "au ColorScheme * hi @lsp.type.decorator.python guifg=none"
vim.cmd "au ColorScheme * hi @lsp.type.class.python guifg=#4ec9b0"
vim.cmd "au ColorScheme * hi link @lsp.type.namespace.python @type.python"
vim.cmd "au ColorScheme * hi link @lsp.mod.readonly.python Special"
vim.cmd "au ColorScheme * hi @method.call.python guifg=#daccaa"
vim.cmd "au ColorScheme * hi @function.method.call.python guifg=#daccaa"
vim.cmd "au ColorScheme * hi link @lsp.type.function.python @method.call.python"
vim.cmd "au ColorScheme * hi link @lsp.type.method.python @method.call.python"
vim.cmd "au ColorScheme * hi link @lsp.type.parameter.python @parameter.python"
vim.cmd "au ColorScheme * hi @function.python guifg=#daccaa"
vim.cmd "au ColorScheme * hi @function.call.python guifg=#daccaa"
vim.cmd "au ColorScheme * hi link @variable.parameter.python @parameter.python"
vim.cmd "au ColorScheme * hi link @function.builtin.python @function.call.python"
vim.cmd "au ColorScheme * hi link @function.method.python @function.call.python"
vim.cmd "au ColorScheme * hi link @lsp.typemod.function.defaultLibrary.python @function.call.python"
vim.api.nvim_create_autocmd("ColorScheme", {
  pattern = "*",
  callback = function()
    vim.api.nvim_set_hl(0, "@lsp.type.parameter.python", {})
  end,
})
vim.cmd "au ColorScheme * hi link @attribute.python @function.call.python"
vim.cmd "au ColorScheme * hi link @keyword.function.python @boolean.python"
vim.cmd "au ColorScheme * hi @field.python guifg=#d19a66"
vim.cmd "au ColorScheme * hi @boolean.python guifg=#3794FF"
vim.cmd "au ColorScheme * hi link @constant.builtin.python @boolean.python"
vim.cmd "au ColorScheme * hi @operator guifg=#ffffff"
vim.cmd "au ColorScheme * hi @text.reference guifg=#3794ff"
vim.cmd "au ColorScheme * hi link @spell.markdown Normal"
vim.cmd "au ColorScheme * hi @markup.strong cterm=bold gui=bold guifg=#daccaa"
vim.cmd "au ColorScheme * hi @punctuation.special.markdown guifg=#9d7cd8"
vim.cmd "au ColorScheme * hi link @text.title.2 Title"
vim.cmd "au ColorScheme * hi link @text.title.2.marker Title"
vim.cmd "au ColorScheme * hi link markdownH2Delimiter Title"
vim.cmd "au ColorScheme * hi link @text.title.3 Title"
vim.cmd "au ColorScheme * hi link @text.title.3.marker Title"
vim.cmd "au ColorScheme * hi link markdownH3Delimiter Title"
vim.cmd "au ColorScheme * hi link @text.title.4 Title"
vim.cmd "au ColorScheme * hi link @text.title.4.marker Title"
vim.cmd "au ColorScheme * hi link markdownH4Delimiter Title"
vim.cmd "au ColorScheme * hi link @text.title.5 Title"
vim.cmd "au ColorScheme * hi link @text.title.5.marker Title"
vim.cmd "au ColorScheme * hi link markdownH5Delimiter Title"
vim.cmd "au ColorScheme * hi link @text.title.4 Title"
vim.cmd "au ColorScheme * hi link @text.title.4.marker Title"
vim.cmd "au ColorScheme * hi link markdownH4Delimiter Title"
vim.cmd "au ColorScheme * hi @number.python guifg=#b5cea8"
vim.cmd "au ColorScheme * hi @float.python guifg=#b5cea8"
vim.cmd "au ColorScheme * hi @string.python guifg=#ce9178"
vim.cmd "au ColorScheme * hi @parameter.python guifg=#68b2c8"
vim.cmd "au ColorScheme * hi @field.python guifg=#4ec9b0"
vim.cmd "au ColorScheme * hi @type.python guifg=#4ec9b0"
vim.cmd "au ColorScheme * hi @constant.python guifg=#4fceff"
vim.cmd "au ColorScheme * hi LspInlayHint guifg=#a59669 guibg=#2d2d2d"
vim.cmd "au ColorScheme * hi TailwindConceal guifg=#38BDF8"

if lvim.transparent_window == true then
  -- NOTE: Neovim 0.11+ (commit: e049c6e) stacks highlight groups (e.g. TabLineFill + Normal),
  -- which can override 'guibg=none' with an unintended background color (e.g. black).
  -- This forces TabLineFill to stay transparent, and PanelHeading to keep solid bg.
  vim.cmd "au ColorScheme * hi TabLineFill guibg=none"
  vim.cmd "au ColorScheme * hi PanelHeading guibg=#000000 gui=nocombine"

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
  vim.cmd "au ColorScheme * hi DiagnosticUnderlineError guifg=#c0caf5"

  vim.cmd "au ColorScheme * hi IndentBlanklineContextChar guifg=#A184FE gui=nocombine" -- #737aa2
  vim.cmd "au ColorScheme * hi link TreesitterContextLineNumber Special"
end

vim.cmd "au ColorScheme * hi Todo cterm=bold gui=bold guifg=#71839b guibg=none"
vim.cmd "au BufEnter *.md setlocal syntax=markdown"

-- vim.cmd "au ColorScheme * highlight! @variable guifg=#ba4351"

vim.cmd "au ColorScheme * hi Whitespace guifg=#504945"
if lvim.transparent_window == true then
  vim.cmd "au ColorScheme * hi Comment guifg=#71839b"
end
--]]

-- Diff (tokyonight default colorscheme)
vim.cmd "au ColorScheme * hi @variable.parameter guifg=#e0af68"
vim.cmd "au ColorScheme * hi link @variable.parameter.diff @variable.parameter"
vim.cmd "au ColorScheme * hi link @diff.minus.diff DiffDelete"
vim.cmd "au ColorScheme * hi link @diff.plus.diff DiffAdd"

-- Reference : https://github.com/sindrets/diffview.nvim/issues/241
vim.cmd "au ColorScheme * hi DiffAdd gui=none guifg=none guibg=#2C6468"
vim.cmd "au ColorScheme * hi DiffChange gui=none guifg=none guibg=#272D43"
vim.cmd "au ColorScheme * hi DiffText gui=none guifg=none guibg=#4A5B80"
vim.cmd "au ColorScheme * hi DiffDelete gui=none guifg=none guibg=#5F3D4D"
vim.cmd "au ColorScheme * hi DiffviewDiffAddAsDelete gui=none guifg=none guibg=#5F3D4D"
vim.cmd "au ColorScheme * hi DiffviewDiffDelete gui=none guifg=#3B4252 guibg=none"

-- Left panel
-- "DiffChange:DiffAddAsDelete",
-- "DiffText:DiffDeleteText",
vim.cmd "au ColorScheme * hi DiffAddAsDelete gui=none guifg=none guibg=#5F3D4D"
vim.cmd "au ColorScheme * hi DiffDeleteText gui=none guifg=none guibg=#5A1D1D"

-- Right panel
-- "DiffChange:DiffAdd",
-- "DiffText:DiffAddText",
vim.cmd "au ColorScheme * hi DiffAddText gui=none guifg=none guibg=#2C6468"

-- Indent Blankline
lvim.builtin.indentlines.options.show_current_context_start = true
--[[
vim.cmd "au ColorScheme * hi IndentHighlightListBlank1 guifg= #291d29 guibg=#291d29 gui=nocombine"
vim.cmd "au ColorScheme * hi IndentHighlightListBlank2 guifg= #1f2b28 guibg=#1f2b28 gui=nocombine"
vim.cmd "au ColorScheme * hi IndentHighlightListBlank3 guifg= #2f2a3b guibg=#2f2a3b gui=nocombine"
vim.cmd "au ColorScheme * hi IndentHighlightListBlank4 guifg= #262933 guibg=#262933 gui=nocombine"
-- vim.cmd "au ColorScheme * hi IndentHighlightListBlank5 guifg= #291d29 guibg=#291d29 gui=nocombine"
vim.cmd "au ColorScheme * hi IndentBlanklineIndent1 guibg=#291d29 gui=nocombine"
vim.cmd "au ColorScheme * hi IndentBlanklineIndent2 guibg=#1f2b28 gui=nocombine"
vim.cmd "au ColorScheme * hi IndentBlanklineIndent3 guibg=#2f2a3b gui=nocombine"
vim.cmd "au ColorScheme * hi IndentBlanklineIndent4 guibg=#262933 gui=nocombine"
lvim.builtin.indentlines.options.space_char_blankline           = " "
lvim.builtin.indentlines.options.show_trailing_blankline_indent = true
lvim.builtin.indentlines.options.show_current_context           = true
lvim.builtin.indentlines.options.show_current_context_start     = true
lvim.builtin.indentlines.options.char_highlight_list            = {
  "IndentHighlightListBlank1",
  "IndentHighlightListBlank2",
  "IndentHighlightListBlank3",
  "IndentHighlightListBlank4",
  -- "IndentHighlightListBlank5",
  -- "IndentHighlightListBlank6",
}
lvim.builtin.indentlines.options.space_char_highlight_list      = {
  "IndentBlanklineIndent1",
  "IndentBlanklineIndent2",
  "IndentBlanklineIndent3",
  "IndentBlanklineIndent4",
}
--]]

-- lvim.builtin.bufferline
vim.g.vim_pid                = vim.fn.getpid()
lvim.builtin.lualine.options = {
  globalstatus = true,
  component_separators = { left = '', right = '' },
  section_separators = { left = '', right = '' }
}
local Path                   = require('plenary.path')
local conditions             = require "lvim.core.lualine.conditions"
local colors                 = require "lvim.core.lualine.colors"
local components             = require "lvim.core.lualine.components"
local function read_pyvenv_prompt(dir)
  local cfg = tostring(Path:new(dir):joinpath('pyvenv.cfg'))
  local f = io.open(cfg, "r")
  if not f then return nil end
  for line in f:lines() do
    local key, value = line:match("^%s*(%w+)%s*=%s*(.+)%s*$")
    if key == "prompt" then
      f:close()
      return vim.trim(value)
    end
  end
  f:close()
  return nil
end
components.python_env         = {
  function()
    local utils = require "lvim.core.lualine.utils"
    if vim.bo.filetype == "python" then
      local venv = os.getenv "CONDA_DEFAULT_ENV" or os.getenv "VIRTUAL_ENV"
      if os.getenv "VIRTUAL_ENV" and os.getenv "CONDA_DEFAULT_ENV" == "base" then
        venv = os.getenv "VIRTUAL_ENV"
      end
      if venv then
        local icons = require "nvim-web-devicons"
        local py_icon, _ = icons.get_icon ".py"
        local venv_name = read_pyvenv_prompt(venv) or utils.env_cleanup(venv)
        return string.format(" " .. py_icon .. " (%s)", venv_name)
      end
    end
    return ""
  end,
  color = { fg = colors.green },
  cond = conditions.hide_in_width,
}
lvim.builtin.lualine.sections = {
  lualine_a = { { 'mode' } },
  lualine_c = {
    components.diff,
    components.python_env,
    components.diagnostics,
    { 'b:CURRENT_REPL' },
    { 'b:jupyter_kernel' }
  },
  lualine_x = {
    { 'vim.api.nvim_call_function("getcwd", {0})' }, { 'encoding' },
    { 'fileformat' },
    { 'filetype',                                 icon_only = false },
    components.lsp,
    {
      function()
        local ok, conf = pcall(require, "avante.config")
        if ok and conf and conf.mode then
          return "Avante:" .. tostring(conf.mode)
        else
          return ""
        end
      end,
      color = { fg = "#9ece6a", gui = "bold" },
    },
    {
      function()
        -- Check if MCPHub is loaded
        if not vim.g.loaded_mcphub then
          return "󰐻 -"
        end

        local count = vim.g.mcphub_servers_count or 0
        local status = vim.g.mcphub_status or "stopped"
        local executing = vim.g.mcphub_executing

        -- Show "-" when stopped
        if status == "stopped" then
          return "󰐻 -"
        end

        -- Show spinner when executing, starting, or restarting
        if executing or status == "starting" or status == "restarting" then
          local frames = { "⠋", "⠙", "⠹", "⠸", "⠼", "⠴", "⠦", "⠧", "⠇", "⠏" }
          local frame = math.floor(vim.loop.now() / 100) % #frames + 1
          return "󰐻 " .. frames[frame]
        end

        return "󰐻 " .. count
      end,
      color = function()
        if not vim.g.loaded_mcphub then
          return { fg = "#6c7086" } -- Gray for not loaded
        end

        local status = vim.g.mcphub_status or "stopped"
        if status == "ready" or status == "restarted" then
          return { fg = "#50fa7b" } -- Green for connected
        elseif status == "starting" or status == "restarting" then
          return { fg = "#ffb86c" } -- Orange for connecting
        else
          return { fg = "#ff5555" } -- Red for error/stopped
        end
      end,
    },
    {
      'pid',
      fmt = function() return "pid:" .. vim.g.vim_pid end
    }
  }
}
-- theme.lua
local function auto_check_markdown_links_status()
  local filetype = vim.bo.filetype
  if filetype == 'markdown' or filetype == 'markdown' then
    if vim.b.auto_check_markdown_links or vim.b.auto_check_markdown_links == nil then
      return " Auto Check Link: true"
    else
      return " Auto Check Link: false"
    end
  end
  return ""
end
lvim.builtin.lualine.sections.lualine_c[#lvim.builtin.lualine.sections.lualine_c + 1] = {
  auto_check_markdown_links_status }


local function narrow_status()
  if vim.b.narrow_mode == true then
    return " Narrowing: true"
  end
  return ""
end
lvim.builtin.lualine.sections.lualine_c[#lvim.builtin.lualine.sections.lualine_c + 1] = { narrow_status }


lvim.builtin.telescope.pickers.find_files.find_command = { "fd", "--type", "f" }

lvim.builtin.telescope.defaults.layout_strategy        = "horizontal"
lvim.builtin.telescope.defaults.layout_config          = {
  -- scroll_speed = 1,
  width = 0.95,
  height = 0.65,
  prompt_position = "top",
  -- preview_width   = 0.50
  horizontal = {
    -- scroll_speed = 1,
    width = 0.95,
    height = 0.65,
  },
  vertical = {
    -- scroll_speed = 1,
    width = 0.95,
    height = 0.95,
    preview_height = 0.50,
    mirror = true
  }
}
vim.cmd "autocmd User TelescopePreviewerLoaded setlocal number"
local autocommands = {
  {
    "TextYankPost",      -- see `:h autocmd-events`
    {                    -- this table is passed verbatim as `opts` to `nvim_create_autocmd`
      pattern = { "*" }, -- see `:h autocmd-events`
      command = "silent! lua vim.highlight.on_yank{higroup='IncSearch', timeout=200}",
    }
  },
  {
    "ColorScheme",
    {
      pattern = { "*" },
      callback = function()
        vim.opt.fillchars = [[eob: ,fold: ,foldopen:,foldsep: ,foldclose:]]
        vim.opt.fillchars:append { diff = "╱" }
      end
    }
  },
  {
    { "BufWinEnter", "WinNew" },
    {
      callback = function(args)
        local b = args.buf
        if vim.bo[b].buftype == "nofile" and vim.bo[b].filetype == "markdown" then
          vim.opt_local.syntax = "markdown"
        end
      end,
    }
  },
}
for _, autocommand in pairs(autocommands) do
  table.insert(lvim.autocommands, autocommand)
end
