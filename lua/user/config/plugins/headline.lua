-- vim.cmd "au ColorScheme * highlight Headline1 guibg=#1e2718"
-- vim.cmd "au ColorScheme * highlight Headline2 guibg=#21262d"
vim.cmd "au ColorScheme * highlight Headline1 guibg=#2d421f gui=italic"

vim.cmd "au ColorScheme * highlight Headline2 guibg=#505429 gui=italic"

-- vim.cmd "au ColorScheme * highlight CodeBlock guibg=#1c1c1c"
vim.cmd "au ColorScheme * highlight Dash guifg=#D19A66 gui=bold"

-- orgmode link
vim.cmd "au ColorScheme * highlight @org.hyperlink guifg=#3794FF gui=underline"

vim.cmd "au ColorScheme * highlight link @text.title.1 Title"
vim.cmd "au ColorScheme * highlight link @text.title.2 Constant"
vim.cmd "au ColorScheme * highlight link @text.title.3 Identifier"
vim.cmd "au ColorScheme * highlight link @text.title.4 Statement"
vim.cmd "au ColorScheme * highlight link @text.title.5 PreProc"
vim.cmd "au ColorScheme * highlight link @text.title.6 Type"

vim.cmd "au ColorScheme * highlight link markdownH1Delimiter Title"
vim.cmd "au ColorScheme * highlight link markdownH2Delimiter Constant"
vim.cmd "au ColorScheme * highlight link markdownH3Delimiter Identifier"
vim.cmd "au ColorScheme * highlight link markdownH4Delimiter Statement"
vim.cmd "au ColorScheme * highlight link markdownH5Delimiter PreProc"
vim.cmd "au ColorScheme * highlight link markdownH6Delimiter Type"


require("headlines").setup {
  markdown = {
    query = vim.treesitter.query.parse(
      "markdown",
      [[
            (atx_heading [
                (atx_h1_marker)
                (atx_h2_marker)
                (atx_h3_marker)
                (atx_h4_marker)
                (atx_h5_marker)
                (atx_h6_marker)
            ] @headline)

            (thematic_break) @dash

            (fenced_code_block) @codeblock

            (block_quote_marker) @quote

            (block_quote (paragraph (inline (block_continuation) @quote)))
            (block_quote (paragraph (block_continuation) @quote))
            (block_quote (block_continuation) @quote)
      ]]
    ),
    headline_highlights = {
      "Headline1",
      "Headline2"
    },
    bullet_highlights = {
      "@text.title.1.marker.markdown",
      "@text.title.2.marker.markdown",
      "@text.title.3.marker.markdown",
      "@text.title.4.marker.markdown",
      "@text.title.5.marker.markdown",
      "@text.title.6.marker.markdown",
    },
    bullets = { "◉", "○", "✸", "✿" },
    dash_highlight = "Dash",
    dash_string = "—",
    fat_headlines = false,
    codeblock_highlight = "CodeBlock",
    fat_headline_upper_string = "▃",
    fat_headline_lower_string = "▀",
  },
  org = {
    headline_highlights = {
      "Headline1",
      "Headline2"
    },
    bullets = {},
    dash_string = "—",
    fat_headlines = false,
    fat_headline_upper_string = "▃",
    fat_headline_lower_string = "▀",
  },
}
-- vim.api.nvim_create_autocmd('BufRead', {
--   pattern = '*.md',
--   group = vim.api.nvim_create_augroup('markdown_header_custom', { clear = true }),
--   callback = function()
--     vim.cmd([[
--       syntax match markdownHeader1 /^\s*#\ze\s/ conceal cchar=◉
--       syntax match markdownHeader2 /^\s*##\ze\s/ conceal cchar=○
--       syntax match markdownHeader3 /^\s*###\ze\s/ conceal cchar=✸
--       syntax match markdownHeader4 /^\s*####\ze\s/ conceal cchar=✿
--     ]])
--   end
-- })
