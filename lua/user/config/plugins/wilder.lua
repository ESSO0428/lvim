local success, msg = pcall(function()
  local wilder = require('wilder')
  wilder.setup({
    modes = { ':', '/', '?' },
    enable_cmdline_enter = 0,
  })
  wilder.set_option('pipeline', {
    wilder.branch(
      {
        wilder.check(function(_, x) return vim.fn.empty(x) end),
        wilder.history(15)
      },
      wilder.cmdline_pipeline({
        fuzzy = 1,
        fuzzy_filter = wilder.vim_fuzzy_filter()
      }),
      wilder.search_pipeline()
    ),
  })
  wilder.set_option('renderer',
    wilder.popupmenu_renderer(
      wilder.popupmenu_border_theme {
        winblend = 20,
        -- highlighter applies highlighting to the candidates
        highlighter = wilder.basic_highlighter(),
        highlights = {
          accent = wilder.make_hl('WilderAccent', 'Pmenu', { { a = 1 }, { a = 1 }, { foreground = '#f4468f' } }),
        },
        border = 'rounded',
        max_height = '20%',
        left = { ' ', wilder.popupmenu_devicons() },
        right = { ' ', wilder.popupmenu_scrollbar() },
      }
    )
  )
  vim.api.nvim_set_keymap('c', '<tab>', [[wilder#in_context() ? wilder#next() : '<tab>']],
    { noremap = true, expr = true })
  vim.api.nvim_set_keymap('c', '<Down>', [[wilder#in_context() ? wilder#next() : '<down>']],
    { noremap = true, expr = true })
  vim.api.nvim_set_keymap('c', '<up>', [[wilder#in_context() ? wilder#previous() : '<up>']],
    { noremap = true, expr = true })

  -- vim.api.nvim_set_keymap('c', '<cr>', [[wilder#in_context() ? wilder#accept_completion() : '<cr>']],
  --   { noremap = true, expr = true })

  vim.api.nvim_set_keymap('c', '<a-l>', [[wilder#in_context() ? wilder#accept_completion() : '<a-l>']],
    { noremap = true, expr = true })
  vim.api.nvim_set_keymap('c', '<a-j>', [[wilder#in_context() ? wilder#reject_completion() : '<a-j>']],
    { noremap = true, expr = true })
end)
if not success then
  print("Error setting up wilder")
end
