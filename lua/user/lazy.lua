-- NOTE: Here is rebinded keymaps for lazy.nvim
-- use require cover, because lunavim not builtin it's keymaps
require("lazy.view.config").keys = {
  hover = "gh",
  diff = "d",
  close = "q",
  details = "<cr>",
  profile_sort = "<C-s>",
  profile_filter = "<C-f>",
  abort = "<C-c>",
}

require("lazy.view.config").commands.install = {
  button = true,
  desc = "Install missing plugins",
  desc_plugin = "Install a plugin",
  id = 2,
  key = ">",
  key_plugin = ">",
  plugins = true,
}
