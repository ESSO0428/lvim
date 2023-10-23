lvim.builtin.terminal.execs = {
  { nil, "<C-8>", "Horizontal Terminal", "horizontal", 0.3 },
  { nil, "<C-9>", "Vertical Terminal",   "vertical",   0.4 },
  { nil, "<C-0>", "Float Terminal",      "float",      nil },
}
require "user.integrated.Term"
lvim.builtin.which_key.mappings["<M-1>"] = { "<Cmd>lua ToggleTermExec('horizontal')<CR>", "Horizontal Terminal" }
lvim.builtin.which_key.mappings["<M-2>"] = { "<Cmd>lua ToggleTermExec('vertical')<CR>", "Vertical Terminal" }
lvim.builtin.which_key.mappings["<M-3>"] = { "<Cmd>lua ToggleTermExec('float')<CR>", "Float Terminal" }

lvim.builtin.which_key.mappings["<M-f>"] = { "<Cmd>lua ToggleTermExecFzfRg('horizontal')<CR>", "Horizontal Terminal" }

-- 設置切換快捷鍵
-- lvim.builtin.which_key.mappings['tn'] = { "<cmd>ToggleTerm<cr>", "ToggleTerm" }
-- vim.api.nvim_set_keymap("n", "<leader>tn", "<cmd>ToggleTerm<CR>", { noremap = true })

-- { lvim.builtin.terminal.shell .. " -c 'conda env list; exec" .. lvim.builtin.terminal.shell .. "'", "<leader><M-1>",
--   "Horizontal Terminal", "horizontal", 0.3 },
