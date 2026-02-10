local M = {}
local has_devicons, devicons = pcall(require, 'nvim-web-devicons')
vim.g.MarkdownNvim = 1
vim.treesitter.language.register('markdown', 'copilot-chat')
vim.treesitter.language.register('markdown', 'AvanteInput')

function M.setup()
  vim.api.nvim_create_autocmd("ExitPre", {
    group = vim.api.nvim_create_augroup("DisableRenderMarkdownOnQuit", { clear = true }),
    callback = function()
      pcall(function()
        require('render-markdown').disable()
      end)
    end,
  })
  require("render-markdown.lib.icons").get = function(language)
    if has_devicons then
      return devicons.get_icon_by_filetype(language)
    else
      return nil, nil
    end
  end

  require('render-markdown').setup({
    file_types = { 'markdown', 'copilot-chat', 'Avante', 'AvanteInput' },
    overrides = {
      buftype = {
        nofile = {
          win_options = {
            conceallevel = {
              default = 0,
              rendered = 2,
            },
            concealcursor = {
              default = 'nvic',
              rendered = 'nvic',
            },
          },
        },
      },
    },
    heading = {
      sign = false,
      icons = { " ◉ ", " ○ ", " ✸ ", " ✿ ", " ◉ ", " ○ " },
    },
    quote = {
      -- Turn on / off block quote & callout rendering
      enabled = true,
      -- Replaces '>' of 'block_quote'
      icon = '▋',
      -- Highlight for the quote icon
      highlight = {
        'RenderMarkdownQuote1',
        'RenderMarkdownQuote2',
        'RenderMarkdownQuote3',
        'RenderMarkdownQuote4',
        'RenderMarkdownQuote5',
        'RenderMarkdownQuote6',
      },
    },
    code = {
      sign = false,
      border = "thick",
      highlight = 'RenderMarkdownCode',
      highlight_inline = '',
    },
    bullet = {
      icons = { '●', '○', '◆', '◇' },
      -- Padding to add to the right of bullet point
      -- Output is evaluated using the same logic as 'left_pad'.
      right_pad = 0,
      -- Highlight for the bullet icon.
      -- Output is evaluated using the same logic as 'icons'.
      highlight = 'Identifier',
    },
    html = {
      -- Turn on / off all HTML rendering
      enabled = true,
      comment = {
        -- Turn on / off HTML comment concealing
        conceal = false,
        -- Optional text to inline before the concealed comment
        text = nil,
        -- Highlight for the inlined text
        highlight = 'RenderMarkdownHtmlComment',
      },
    },
    win_options = {
      -- See :h 'conceallevel'
      conceallevel = {
        -- Used when not being rendered, get user setting
        default = 0,
        -- Used when being rendered, concealed text is completely hidden
        rendered = 2,
      },
    },
    link = {
      -- Turn on / off inline link icon rendering
      enabled = true,
      -- Inlined with 'image' elements
      image = '󰥶 ',
      -- Inlined with 'email_autolink' elements
      email = '󰀓 ',
      -- Fallback icon for 'inline_link' elements
      hyperlink = '󰌹 ',
      -- Applies to the fallback inlined icon
      highlight = 'RenderMarkdownLink',
      -- Applies to WikiLink elements
      wiki = { icon = '󱗖 ', highlight = 'RenderMarkdownWikiLink' },
      -- Define custom destination patterns so icons can quickly inform you of what a link
      -- contains. Applies to 'inline_link' and wikilink nodes.
      -- Can specify as many additional values as you like following the 'web' pattern below
      --   The key in this case 'web' is for healthcheck and to allow users to change its values
      --   'pattern':   Matched against the destination text see :h lua-pattern
      --   'icon':      Gets inlined before the link text
      --   'highlight': Highlight for the 'icon'
      custom = {
        web = { pattern = '^http[s]?://', icon = '󰖟 ', highlight = 'RenderMarkdownLink' },
      },
    },
    callout = {
      -- Callouts are a special instance of a 'block_quote' that start with a 'shortcut_link'.
      -- The key is for healthcheck and to allow users to change its values, value type below.
      -- | raw        | matched against the raw text of a 'shortcut_link', case insensitive |
      -- | rendered   | replaces the 'raw' value when rendering                             |
      -- | highlight  | highlight for the 'rendered' text and quote markers                 |
      -- | quote_icon | optional override for quote.icon value for individual callout       |
      -- | category   | optional metadata useful for filtering                              |

      note      = { raw = '[!NOTE]', rendered = '󰋽 Note', highlight = 'RenderMarkdownInfo', category = 'github' },
      tip       = { raw = '[!TIP]', rendered = '󰌶 Tip', highlight = 'RenderMarkdownSuccess', category = 'github' },
      important = { raw = '[!IMPORTANT]', rendered = '󰅾 Important', highlight = 'RenderMarkdownHint', category = 'github' },
      warning   = { raw = '[!WARNING]', rendered = '󰀪 Warning', highlight = 'RenderMarkdownWarn', category = 'github' },
      caution   = { raw = '[!CAUTION]', rendered = '󰳦 Caution', highlight = 'RenderMarkdownError', category = 'github' },
      -- Obsidian: https://help.obsidian.md/Editing+and+formatting/Callouts
      abstract  = { raw = '[!ABSTRACT]', rendered = '󰨸 Abstract', highlight = 'RenderMarkdownInfo', category = 'obsidian' },
      summary   = { raw = '[!SUMMARY]', rendered = '󰨸 Summary', highlight = 'RenderMarkdownInfo', category = 'obsidian' },
      tldr      = { raw = '[!TLDR]', rendered = '󰨸 Tldr', highlight = 'RenderMarkdownInfo', category = 'obsidian' },
      info      = { raw = '[!INFO]', rendered = '󰋽 Info', highlight = 'RenderMarkdownInfo', category = 'obsidian' },
      todo      = { raw = '[!TODO]', rendered = '󰗡 Todo', highlight = 'RenderMarkdownInfo', category = 'obsidian' },
      hint      = { raw = '[!HINT]', rendered = '󰌶 Hint', highlight = 'RenderMarkdownSuccess', category = 'obsidian' },
      success   = { raw = '[!SUCCESS]', rendered = '󰄬 Success', highlight = 'RenderMarkdownSuccess', category = 'obsidian' },
      check     = { raw = '[!CHECK]', rendered = '󰄬 Check', highlight = 'RenderMarkdownSuccess', category = 'obsidian' },
      done      = { raw = '[!DONE]', rendered = '󰄬 Done', highlight = 'RenderMarkdownSuccess', category = 'obsidian' },
      question  = { raw = '[!QUESTION]', rendered = '󰘥 Question', highlight = 'RenderMarkdownWarn', category = 'obsidian' },
      help      = { raw = '[!HELP]', rendered = '󰘥 Help', highlight = 'RenderMarkdownWarn', category = 'obsidian' },
      faq       = { raw = '[!FAQ]', rendered = '󰘥 Faq', highlight = 'RenderMarkdownWarn', category = 'obsidian' },
      attention = { raw = '[!ATTENTION]', rendered = '󰀪 Attention', highlight = 'RenderMarkdownWarn', category = 'obsidian' },
      failure   = { raw = '[!FAILURE]', rendered = '󰅖 Failure', highlight = 'RenderMarkdownError', category = 'obsidian' },
      fail      = { raw = '[!FAIL]', rendered = '󰅖 Fail', highlight = 'RenderMarkdownError', category = 'obsidian' },
      missing   = { raw = '[!MISSING]', rendered = '󰅖 Missing', highlight = 'RenderMarkdownError', category = 'obsidian' },
      danger    = { raw = '[!DANGER]', rendered = '󱐌 Danger', highlight = 'RenderMarkdownError', category = 'obsidian' },
      error     = { raw = '[!ERROR]', rendered = '󱐌 Error', highlight = 'RenderMarkdownError', category = 'obsidian' },
      bug       = { raw = '[!BUG]', rendered = '󰨰 Bug', highlight = 'RenderMarkdownError', category = 'obsidian' },
      example   = { raw = '[!EXAMPLE]', rendered = '󰉹 Example', highlight = 'RenderMarkdownHint', category = 'obsidian' },
      quote     = { raw = '[!QUOTE]', rendered = '󱆨 Quote', highlight = 'RenderMarkdownQuote', category = 'obsidian' },
      cite      = { raw = '[!CITE]', rendered = '󱆨 Cite', highlight = 'RenderMarkdownQuote', category = 'obsidian' },
    },
  })
end

return M
