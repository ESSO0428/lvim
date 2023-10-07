lvim.keys.normal_mode["<a-q>"] = { "<Cmd>copen<cr>" }
lvim.builtin.which_key.mappings.a = {
  name = "ASyncRun",
  r = { ":AsyncRun", "AsyncRun" },
  s = { "<Cmd>AsyncStop!<cr>", "AsyncStop" }
}
lvim.keys.visual_mode['<leader>a'] = { ":AsyncRun", silent = false }
