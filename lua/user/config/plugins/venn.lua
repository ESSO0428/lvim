function _G.Toggle_venn(command)
  if command == "close" then
    vim.b.venn_enabled = nil
    vim.cmd [[setlocal ve=]]
    vim.cmd [[mapclear <buffer>]]
    print('clear all setting of venn and set ve=NONE')
    return
  end
  local venn_enabled = vim.inspect(vim.b.venn_enabled)
  if venn_enabled == "true" then
    vim.b.venn_enabled = nil
    vim.cmd [[setlocal ve=all]]
    print('open venn and set ve=all')
    -- draw a line on HJKL keystokes
    vim.api.nvim_buf_set_keymap(0, "n", "K", "<C-v>j:VBox<CR>", { noremap = true })
    vim.api.nvim_buf_set_keymap(0, "n", "I", "<C-v>k:VBox<CR>", { noremap = true })
    vim.api.nvim_buf_set_keymap(0, "n", "L", "<C-v>l:VBox<CR>", { noremap = true })
    vim.api.nvim_buf_set_keymap(0, "n", "J", "<C-v>h:VBox<CR>", { noremap = true })
    -- draw a box by pressing "f" with visual selection
    vim.api.nvim_buf_set_keymap(0, "v", "f", ":VBox<CR>", { noremap = true })
  else
    vim.b.venn_enabled = true
    -- vim.cmd [[setlocal ve=]]
    vim.cmd [[setlocal ve=all]]
    vim.cmd [[mapclear <buffer>]]
    -- vim.b.venn_enabled = nil
    vim.api.nvim_buf_set_keymap(0, "n", "L", "g$", { noremap = true })
    vim.api.nvim_buf_set_keymap(0, "n", "J", "g0", { noremap = true })
    print('map g0, g$ and set ve=all (press <leader>tv to open venn)')
  end
end

-- toggle keymappings for venn using <leader>v
-- vim.api.nvim_set_keymap('n', '<leader>tv', ":lua Toggle_venn()<CR>", { noremap = true })
lvim.keys.normal_mode['<leader>tv'] = "<cmd>lua Toggle_venn('toggle')<cr>"
lvim.keys.normal_mode['<leader>tc'] = "<cmd>lua Toggle_venn('close')<cr>"
