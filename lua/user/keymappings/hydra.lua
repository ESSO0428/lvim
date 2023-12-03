local got_hydra, hydra = pcall(require, "hydra")
lvim.builtin.which_key.setup.plugins.presets.h = false
local hint
hint = [[
_(_/_)_: c previous/next
]]
local hydra_config = {
  name = "quickfix",
  mode = { "n" },
  hint = hint,
  config = {
    invoke_on_body = true,
    color = "pink",
    hint = { border = "rounded" },
  },
  body = "<leader>hq",
  heads = {
    { ')', ':cnext<CR>',     { desc = 'cnext' } },
    { '(', ':cprevious<CR>', { desc = 'cprevious' } }
  }
}
hydra(hydra_config)

hint = [[
_[_/_]_: nreakpint prev/next _S_: go to brreakpint stop
]]
hydra_config = {
  name = "debug",
  mode = { "n" },
  hint = hint,
  config = {
    invoke_on_body = true,
    color = "pink",
    hint = { border = "rounded" },
  },
  body = "<leader>hd",
  heads = {
    { ']', ":lua require('goto-breakpoints').next()<CR>",    { desc = 'next breakpoints' } },
    { '[', ":lua require('goto-breakpoints').prev()<CR>",    { desc = 'prev breakpoints' } },
    { 'S', ":lua require('goto-breakpoints').stopped()<CR>", { desc = 'go to breakpoints stop' } },
  }
}
hydra(hydra_config)

hint = [[
_o_: Folding Code (Toggle) _u_: Folding Preview
]]
hydra_config = {
  name = "FoldMode",
  mode = { "n" },
  hint = hint,
  config = {
    invoke_on_body = true,
    color = "pink",
    hint = { border = "rounded" },
  },
  body = "<leader>ho",
  heads = {
    { 'o', "za",                                    { desc = 'Folding Code (Toggle)' } },
    { 'u', ":lua peekFoldedLinesUnderCursor()<cr>", { desc = "Folding Preview" } }
  }
}

hydra(hydra_config)
