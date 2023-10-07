lvim.builtin.bufferline.options.show_tab_indicators = false
lvim.builtin.bufferline.options.offsets = {}
local autocommands = {
  {
    "VimEnter",          -- see `:h autocmd-events`
    {                    -- this table is passed verbatim as `opts` to `nvim_create_autocmd`
      pattern = { "*" }, -- see `:h autocmd-events`
      command = "lua vim.opt.tabline = \"%!v:lua.nvim_bufferline() .. v:lua.require'tabline'.tabline_tabs()\"",
    }
  },
  {
    "SessionLoadPost",   -- see `:h autocmd-events`
    {                    -- this table is passed verbatim as `opts` to `nvim_create_autocmd`
      pattern = { "*" }, -- see `:h autocmd-events`
      command = "lua vim.opt.tabline = \"%!v:lua.nvim_bufferline() .. v:lua.require'tabline'.tabline_tabs()\"",
    }
  },
}
for _, autocommand in pairs(autocommands) do
  table.insert(lvim.autocommands, autocommand)
end
