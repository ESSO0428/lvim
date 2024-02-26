vim.cmd(
  "autocmd FileType sql,mysql,plsql lua require('cmp').setup.buffer({ sources = {{ name = 'vim-dadbod-completion' }} })")
vim.cmd('autocmd FileType dbui nmap <buffer> v <Plug>(DBUI_SelectLineVsplit)')

lvim.keys.normal_mode['<leader>de'] = "<Cmd>DBUIToggle<cr>"
lvim.keys.normal_mode['<leader>dE'] = "<Cmd>tab DBUI<cr>"
vim.api.nvim_create_autocmd('FileType', {
  pattern = 'dbui',
  group = vim.api.nvim_create_augroup('dbui_only_keymap', { clear = true }),
  callback = function()
    vim.keymap.set('n', 'gi', '<Plug>(DBUI_GotoPrevSibling)', { silent = true, buffer = true })
    vim.keymap.set('n', 'gk', '<Plug>(DBUI_GotoNextSibling)', { silent = true, buffer = true })
    vim.keymap.set('n', 'K', '5j', { silent = true, buffer = true })
    vim.keymap.set('n', 'I', '5k', { silent = true, buffer = true })
    vim.keymap.set('n', 'J', '0', { silent = true, buffer = true })
    vim.keymap.set('n', 'L', '$', { silent = true, buffer = true })
    vim.keymap.set('n', 'o', '<Plug>(DBUI_SelectLine)', { silent = true, buffer = true })
    vim.keymap.set('n', 'l', '<Plug>(DBUI_SelectLine)', { silent = true, buffer = true })
    vim.keymap.set('n', '<2-LeftMouse>', '<Plug>(DBUI_SelectLine)', { silent = true, buffer = true })
    vim.keymap.set('n', '<cr>', '<Plug>(DBUI_SelectLine)', { silent = true, buffer = true })
  end,
})
vim.api.nvim_create_autocmd('FileType', {
  pattern = 'dbout',
  group = vim.api.nvim_create_augroup('dbout_only_keymap', { clear = true }),
  callback = function()
    vim.keymap.set('n', '<a-o>', '<Plug>(DBUI_JumpToForeignKey)', { silent = true, buffer = true })
  end,
})

-- lvim.keys.normal_mode['gd'] = "<Plug>(DBUI_JumpToForeignKey)"
-- lvim.keys.normal_mode['gi'] = "<Plug>(DBUI_GotoPrevSibling)"
-- lvim.keys.normal_mode['gk'] = "<Plug>(DBUI_GotoNextSibling)"
