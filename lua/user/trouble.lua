require("trouble").setup {
  action_keys = {
    -- key mappings for actions in the trouble list
    -- map to {} to remove a mapping, for example:
    -- close = {},
    close = "<leader>q",             -- close the list
    cancel = "<esc>",                -- cancel the preview and get back to your last window / buffer / cursor
    refresh = "r",                   -- manually refresh
    jump = { "<cr>", "l" },          -- jump to the diagnostic or open / close folds
    open_split = { "<a-k>" },        -- open buffer in new split
    open_vsplit = { "<a-l>" },       -- open buffer in new vsplit
    open_tab = { "<a-m>", "<a-t>" }, -- open buffer in new tab
    jump_close = { "o" },            -- jump to the diagnostic and close the list
    toggle_mode = "m",               -- toggle between "workspace" and "document" diagnostics mode
    toggle_preview = "<tab>",        -- toggle auto_preview
    -- hover = "<a-s>",                 -- opens a small popup with the full multiline message
    hover = "gh",                    -- opens a small popup with the full multiline message
    preview = "p",                   -- preview the diagnostic location
    close_folds = { "zM", "zm" },    -- close all folds
    open_folds = { "zR", "zr" },     -- open all folds
    toggle_fold = { "zA", "za" },    -- toggle fold of current file
    previous = "i",                  -- previous item
    next = "k"                       -- next item
  }
}
lvim.builtin.which_key.mappings["t"] = {
  name = "Trouble",
  r = { "<cmd>Trouble lsp_references<cr>", "References" },
  f = { "<cmd>Trouble lsp_definitions<cr>", "Definitions" },
  d = { "<cmd>Trouble lsp_document_diagnostics<cr>", "Diagnostics" },
  q = { "<cmd>Trouble quickfix<cr>", "QuickFix" },
  l = { "<cmd>Trouble loclist<cr>", "LocationList" },
  w = { "<cmd>Trouble workspace_diagnostics<cr>", "Diagnostics" },
}
vim.keymap.set("n", "]t", function()
  local status_ok, trouble = pcall(require, 'trouble')
  if not status_ok then
    vim.notify('trouble ' .. trouble .. ' not found!')
    return
  else
    require("trouble").next({ skip_groups = true, jump = true })
  end
end, { desc = "Next trouble" })

vim.keymap.set("n", "[t", function()
  local status_ok, trouble = pcall(require, 'trouble')
  if not status_ok then
    vim.notify('trouble ' .. trouble .. ' not found!')
    return
  else
    require("trouble").previous({ skip_groups = true, jump = true })
  end
end, { desc = "Previous trouble" })
