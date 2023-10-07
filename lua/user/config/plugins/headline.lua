-- vim.cmd "au ColorScheme * highlight Headline1 guibg=#1e2718"
-- vim.cmd "au ColorScheme * highlight Headline2 guibg=#21262d"
vim.cmd "au ColorScheme * highlight Headline1 guibg=#2d421f gui=italic"

vim.cmd "au ColorScheme * highlight Headline2 guibg=#505429 gui=italic"

-- vim.cmd "au ColorScheme * highlight CodeBlock guibg=#1c1c1c"
vim.cmd "au ColorScheme * highlight Dash guifg=#D19A66 gui=bold"

-- orgmode link
vim.cmd "au ColorScheme * highlight org_hyperlink guifg=#3399FF gui=underline"

require("headlines").setup {
  markdown = {
    headline_highlights = {
      "Headline1",
      "Headline2"
    },
    dash_string = "—",
    fat_headlines = false,
    fat_headline_upper_string = "▃",
    fat_headline_lower_string = "▀",
  },
  org = {
    headline_highlights = {
      "Headline1",
      "Headline2"
    },
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
