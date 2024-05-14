lvim.keys.normal_mode["<a-q>"] = { "<Cmd>copen<cr>" }
-- lvim core command <c-q>
--[[
vim.cmd [[
  function! QuickFixToggle()
    if empty(filter(getwininfo(), 'v:val.quickfix'))
      copen
    else
      cclose
    endif
  endfunction
]]
lvim.builtin.which_key.mappings.a = {
  name = "ASyncRun",
  r = { ":AsyncRun", "AsyncRun" },
  s = { "<Cmd>AsyncStop!<cr>", "AsyncStop" }
}
lvim.keys.visual_mode['<leader>a'] = { ":AsyncRun", silent = false }
