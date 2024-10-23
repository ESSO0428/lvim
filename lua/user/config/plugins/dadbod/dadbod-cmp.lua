vim.api.nvim_create_autocmd('FileType', {
  pattern = { 'sql', 'mysql', 'plsql' },
  callback = function()
    local sources
    -- when vim-dadbod activated in buffer
    if vim.b.db then
      sources = {
        { name = "copilot" },
        { name = 'vim-dadbod-completion' }
      }
    else
      sources = {
        { name = "copilot" },
        { name = 'vim-dadbod-completion' },
        { name = "path" },
        {
          name = "buffer",
          option = {
            get_bufnrs = function()
              local max_size = 100000 -- 设置文件大小限制为 100,000 字节
              local bufs = {}

              -- 获取当前 Tab 中的所有窗口
              local windows = vim.api.nvim_tabpage_list_wins(0)
              for _, win in ipairs(windows) do
                -- 获取每个窗口的缓冲区编号
                local buf = vim.api.nvim_win_get_buf(win)
                -- 检查文件类型是否不是 neo-tree
                if vim.api.nvim_get_option_value("filetype", { buf = buf }) ~= 'neo-tree' then
                  -- 检查文件大小
                  local size = vim.fn.getfsize(vim.api.nvim_buf_get_name(buf))
                  if size > 0 and size < max_size then
                    bufs[buf] = true
                  end
                end
              end

              return vim.tbl_keys(bufs)
            end
          }
        }
      }
    end

    require('cmp').setup.buffer({
      sources = sources
    })
  end,
})

vim.api.nvim_create_autocmd('FileType', {
  pattern = 'dbui',
  callback = function()
    vim.api.nvim_buf_set_keymap(0, 'n', 'v', '<Plug>(DBUI_SelectLineVsplit)', { noremap = true, silent = true })
  end,
})

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
