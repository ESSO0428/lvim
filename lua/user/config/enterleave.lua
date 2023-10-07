local autocmd = vim.api.nvim_create_autocmd
if lvim.builtin.nvimtree.active == false then
  autocmd({ "VimEnter" }, { callback = open_neo_tree })
else
  autocmd({ "VimEnter" }, { callback = open_nvim_tree })
end
autocmd({ "VimLeave" }, { pattern = "*", command = "set guicursor= | call chansend(v:stderr, \"\x1b[ q\")" })
