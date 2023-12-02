local got_hydra, hydra = pcall(require, "hydra")
lvim.builtin.which_key.setup.plugins.presets.h = false
local hydra_config = {
  name = "quickfix",
  mode = { "n" },
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

hydra_config = {
  name = "debug",
  mode = { "n" },
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

hydra_config = {
  name = "FoldMode",
  mode = { "n" },
  config = {
    invoke_on_body = true,
    color = "pink",
    hint = { border = "rounded" },
  },
  body = "<leader>ho",
  heads = {
    { 'o', "za", { desc = 'Folding Code (Toggle)' } },
  }
}

hydra(hydra_config)
