return {
  {
    "sindrets/winshift.nvim",
    cmd = "WinShift", -- 用到才載
    config = function()
      require("user.config.plugins.winshift").setup()
    end,
  },
  {
    "s1n7ax/nvim-window-picker",
    version = "2.*",
    opts = require("user.window_picker").opts
  },
}
