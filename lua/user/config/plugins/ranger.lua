vim.g.rnvimr_pick_enable = 1
vim.g.rnvimr_draw_border = 0
-- vim.g.rnvimr_bw_enable = 1  -- 將這行註解掉，Lua 不需要使用 vim.g
-- vim.cmd "au ColorScheme * highlight link RnvimrNormal CursorLine"
vim.g.rnvimr_action = {
  ['<C-t>'] = 'NvimEdit tabedit',
  ['<a-l>'] = 'NvimEdit vsplit',
  ['<a-k>'] = 'NvimEdit split',
  ['gw'] = 'JumpNvimCwd',
  ['yw'] = 'EmitRangerCwd'
}
