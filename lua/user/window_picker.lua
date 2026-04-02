local M = {}

local avante_filtypes = { "Avante", "AvanteSelectedFiles", "AvanteInput", "AvantePromptInput" }
local ignore_filetype = vim.list_extend({ "NvimTree", "neo-tree", "neo-tree-popup", "notify", "Outline", "edgy" },
  avante_filtypes)
local ignore_buftype = { "terminal", "quickfix" }
local edgy_views = { bottom = {}, left = {}, right = {} }

do
  local ok, edgy = pcall(require, "user.edgy")
  if ok and type(edgy.config) == "table" then
    for _, layout_pos in ipairs({ "bottom", "left", "right" }) do
      if type(edgy.config[layout_pos]) == "table" then
        edgy_views[layout_pos] = edgy.config[layout_pos]
      end
    end
  end
end

-- NOTE: Integrate with edgy
for i_pos, layout_pos in ipairs({ "bottom", "left", "right" }) do
  for _, view in ipairs(edgy_views[layout_pos] or {}) do
    if view.ft and view.ft ~= "markdown" and not vim.tbl_contains(ignore_filetype, view.ft) then
      table.insert(ignore_filetype, view.ft)
    end
  end
  if vim.tbl_contains(ignore_buftype, "help") then
    table.insert(ignore_buftype, "help")
  end
end

-- type of hints you want to get
M.opts = {
  -- following types are supported
  -- 'statusline-winbar' | 'floating-big-letter'
  -- 'statusline-winbar' draw on 'statusline' if possible, if not 'winbar' will be
  -- 'floating-big-letter' draw big letter on a floating window
  -- used
  hint = 'statusline-winbar',
  filter_rules = {
    include_current_win = false,
    autoselect_one = true,
    -- filter using buffer options
    bo = {
      -- if the file type is one of following, the window will be ignored
      filetype = ignore_filetype,
      -- if the buffer type is one of following, the window will be ignored
      buftype = ignore_buftype,
    },
  },
}

return M
