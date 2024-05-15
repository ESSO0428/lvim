lvim.builtin.bufferline.options.show_tab_indicators = false
if lvim.builtin.bufferline.options.show_tab_indicators == false then
  --[[
  -- NOW DEPRECATED : bufferline.nvim and tabline.nvim are now perfectly integrated
  -- lvim.builtin.bufferline.options.offsets = {}
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
  --]]
  -- NOTE: NEW FEATURE: bufferline.nvim and tabline.nvim are now perfectly integrated
  require "user.integrated.bufferline.nvimTabline"
else
  require "user.integrated.bufferline.tabpages"
end
