local ok, actions = pcall(require, "lir.actions")
if not ok then
  return
end
local utils               = require "lvim.utils.modules"
local clipboard_actions   = utils.require_on_exported_call "lir.clipboard.actions"
lvim.builtin.lir.mappings = {
  ["l"] = actions.edit,
  ["<CR>"] = actions.edit,
  ["<C-s>"] = actions.split,
  ["v"] = actions.vsplit,
  ["<C-t>"] = actions.tabedit,
  -- ["<BS>"] = actions.up,
  ["j"] = actions.up,
  ["q"] = actions.quit,
  ["A"] = actions.mkdir,
  ["a"] = actions.newfile,
  ["r"] = actions.rename,
  ["@"] = actions.cd,
  ["Y"] = actions.yank_path,
  ["h"] = actions.toggle_show_hidden,
  ["d"] = actions.delete,
  ["o"] = function()
    require("lir.mark.actions").toggle_mark()
    vim.cmd "normal! j"
  end,
  ["c"] = clipboard_actions.copy,
  ["x"] = clipboard_actions.cut,
  ["i"] = actions.prev_sibling,
  -- ["<cr>"] = actions.edit,
  -- ["l"] = actions.cd
}
