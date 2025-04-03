local got_hydra, hydra = pcall(require, "hydra")
lvim.builtin.which_key.setup.plugins.presets.h = false

local hint = [[
_(_/_)_: c previous/next
]]

hydra({
  name = "quickfix",
  mode = { "n" },
  hint = hint,
  config = {
    invoke_on_body = true,
    color = "pink",
    hint = { float_opts = {} },
  },
  body = "<leader>hq",
  heads = {
    { ')', ':cnext<cr>',     { desc = 'cnext' } },
    { '(', ':cprevious<CR>', { desc = 'cprevious' } }
  }
})

hint = [[
_<_/_>_: breakpint prev/next _S_: go to breakpint stop
]]

hydra({
  name = "debug",
  mode = { "n" },
  hint = hint,
  config = {
    invoke_on_body = true,
    color = "pink",
    hint = { float_opts = {} },
  },
  body = "<leader>hd",
  heads = {
    { '<', ":lua require('goto-breakpoints').next()<CR>",    { desc = 'next breakpoints' } },
    { '>', ":lua require('goto-breakpoints').prev()<CR>",    { desc = 'prev breakpoints' } },
    { 'S', ":lua require('goto-breakpoints').stopped()<CR>", { desc = 'go to breakpoints stop' } },
  }
})

hint = [[
_o_: Folding Code (Toggle) _u_: Folding Preview
]]

hydra({
  name = "FoldMode",
  mode = { "n" },
  hint = hint,
  config = {
    invoke_on_body = true,
    color = "pink",
    hint = { float_opts = {} },
  },
  body = "<leader>ho",
  heads = {
    { 'o', "za",                                    { desc = 'Folding Code (Toggle)' } },
    { 'u', ":lua PeekFoldedLinesUnderCursor()<cr>", { desc = "Folding Preview" } }
  }
})

hint = [[
_<_/_>_: bookmarks prev/next
]]

hydra({
  name = "bookmarks",
  mode = { "n" },
  hint = hint,
  config = {
    invoke_on_body = true,
    color = "pink",
    hint = { float_opts = {} },
  },
  body = "<leader>hm",
  heads = {
    { '>', ":lua require('bookmarks.actions').bookmark_next()<cr>", { desc = 'next bookmark' } },
    { '<', ":lua require('bookmarks.actions').bookmark_prev()<cr>", { desc = 'prev bookmark' } },
  }
})

hint = [[
_<_/_>_: spell prev/next
]]

hydra({
  name = "spell",
  mode = { "n" },
  hint = hint,
  config = {
    invoke_on_body = true,
    color = "pink",
    hint = { float_opts = {} },
  },
  body = "<leader>hs",
  heads = {
    { '>', "]s", { desc = 'next spell' } },
    { '<', "[s", { desc = 'prev spell' } },
  }
})
