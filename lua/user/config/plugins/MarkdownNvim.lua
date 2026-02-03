local M = {}
local has_devicons, devicons = pcall(require, 'nvim-web-devicons')
vim.g.MarkdownNvim = 1
vim.treesitter.language.register('markdown', 'copilot-chat')
vim.treesitter.language.register('markdown', 'AvanteInput')

function M.setup()
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
      highlight = 'RenderMarkdownQuote',
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
      right_pad = 0,
      -- Highlight for the bullet icon
      -- highlight = 'RenderMarkdownBullet',
      highlight = 'Identifier'
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
      note = { raw = '[!NOTE]', rendered = '󰋽 Note', highlight = 'RenderMarkdownInfo' },
      tip = { raw = '[!TIP]', rendered = '󰌶 Tip', highlight = 'RenderMarkdownSuccess' },
      important = { raw = '[!IMPORTANT]', rendered = '󰅾 Important', highlight = 'Identifier' },
      warning = { raw = '[!WARNING]', rendered = '󰀪 Warning', highlight = 'RenderMarkdownWarn' },
      caution = { raw = '[!CAUTION]', rendered = '󰳦 Caution', highlight = 'RenderMarkdownError' },
      -- Obsidian: https://help.a.md/Editing+and+formatting/Callouts
      abstract = { raw = '[!ABSTRACT]', rendered = '󰨸 Abstract', highlight = 'RenderMarkdownInfo' },
      todo = { raw = '[!TODO]', rendered = '󰗡 Todo', highlight = 'RenderMarkdownInfo' },
      success = { raw = '[!SUCCESS]', rendered = '󰄬 Success', highlight = 'RenderMarkdownSuccess' },
      question = { raw = '[!QUESTION]', rendered = '󰘥 Question', highlight = 'RenderMarkdownWarn' },
      failure = { raw = '[!FAILURE]', rendered = '󰅖 Failure', highlight = 'RenderMarkdownError' },
      danger = { raw = '[!DANGER]', rendered = '󱐌 Danger', highlight = 'RenderMarkdownError' },
      bug = { raw = '[!BUG]', rendered = '󰨰 Bug', highlight = 'RenderMarkdownError' },
      example = { raw = '[!EXAMPLE]', rendered = '󰉹 Example', highlight = 'RenderMarkdownHint' },
      quote = { raw = '[!QUOTE]', rendered = '󱆨 Quote', highlight = 'RenderMarkdownQuote' },
    },
  })
end

return M
