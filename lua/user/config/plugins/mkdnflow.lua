local success, msg = pcall(function()
  require('mkdnflow').setup({
    new_file_template = {
      use_template = true,
      template = [[
---
title: {{ title }}
author: Andy6
date: {{ date }}
filename: {{ filename }}
---
]],
      placeholders = {
        before = {
          date = function()
            return os.date("%A, %B %d, %Y") -- Wednesday, March 1, 2023
          end
        },
        after = {
          filename = function()
            return vim.api.nvim_buf_get_name(0)
          end
        }
      }
    },
    to_do = {
      symbols = { ' ', 'x' },
      update_parents = true,
      not_started = ' ',
      complete = 'x'
    },
    create_dirs = false,
    hijack_dirs = true,
    mappings = {
      -- MkdnEnter = { { 'i', 'n', 'v' }, '<CR>' }, -- This monolithic command has the aforementioned
      MkdnEnter                   = false,
      -- insert-mode-specific behavior and also will trigger row jumping in tables. Outside
      -- of lists and tables, it behaves as <CR> normally does.
      MkdnNewListItem             = { 'i', '<CR>' }, -- Use this command instead if you only want <CR> in
      -- insert mode to add a new list item (and behave as usual outside of lists).
      MkdnFollowLink              = { 'n', '<a-o>' },
      MkdnDestroyLink             = false,
      MkdnCreateLinkFromClipboard = false,
      MkdnNextLink                = false,
      MkdnPrevLink                = false,
      MkdnToggleToDo              = { { 'n', 'v' }, 'gS' },
      MkdnNewListItemAboveInsert  = false,
      MkdnNewListItemBelowInsert  = { 'n', '<leader>oh' },
      MkdnIncreaseHeading         = { 'n', '<<' },
      MkdnDecreaseHeading         = { 'n', '>>' },
      -- MkdnNextHeading             = { 'n', '}' },
      MkdnNextHeading             = { 'n', 'gk' },
      -- MkdnPrevHeading             = { 'n', '{' },
      MkdnPrevHeading             = { 'n', 'gi' },
      -- MkdnFoldSection = false,
      MkdnFoldSection             = { 'n', '<tab>' },
      -- MkdnUnfoldSection = false,
      -- MkdnUnfoldSection           = { 'n', '<S-tab>' },
      MkdnFoldCycle               = { 'n', '<S-tab>' },
      MkdnYankFileAnchorLink      = false,
      MkdnYankAnchorLink          = false,
      MkdnMoveSource              = false,
      MkdnTableNextCell           = false,
      MkdnTablePrevCell           = false,
      MkdnTagSpan                 = false,
      MkdnTableNewRowBelow        = false,
      MkdnTableNewRowAbove        = false,
      MkdnTableNewColAfter        = false,
      MkdnTableNewColBefore       = false,
      -- MkdnUpdateNumbering = { 'n', '<leader>rr' }
    },
  })
end)
if not success then
  print("Error setting up mkdnflow")
end
vim.api.nvim_create_autocmd('FileType', {
  pattern = 'markdown',
  group = vim.api.nvim_create_augroup('markdown_only_keymap', { clear = true }),
  callback = function()
    vim.keymap.set('n', "<leader>uv", ':MarkdownHeadersClosest<cr>', { silent = true, buffer = true })
    vim.keymap.set('n', '<leader>o', '<Nop>', { silent = true, buffer = true })
    vim.keymap.set('n', '<leader>oo', 'za', { silent = true, buffer = true })
  end,
})
vim.api.nvim_create_user_command('Date', 'silent! r! date +"\\%A, \\%B, \\%d, \\%Y"', { nargs = "*" })
