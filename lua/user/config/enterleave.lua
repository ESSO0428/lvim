local autocmd = vim.api.nvim_create_autocmd
if vim.fn.argc() == 0 or vim.fn.argv(0) ~= "." then
  if lvim.builtin.nvimtree.active == false then
    autocmd({ "VimEnter" }, { callback = open_neo_tree })
  else
    autocmd({ "VimEnter" }, { callback = open_nvim_tree })
  end
end
autocmd({ "VimLeave" }, { pattern = "*", command = "set guicursor= | call chansend(v:stderr, \"\x1b[5 q\")" })
