return {
  {
    "soulis-1256/eagle.nvim",
    event = "VeryLazy",
    config = function()
      require("eagle").setup({
        -- override the default values found in config.lua
        render_delay = 200, -- default is 500
        detect_idle_timer = 50,
        border = "single",
        border_color = "#3d59a1",
      })
    end
  },
  {
    "roobert/hoversplit.nvim",
    event = "VeryLazy",
    config = function()
      require("hoversplit").setup({
        key_bindings = {
          -- sgh keymap 為我常用的但在這可能無效，
          -- 因此後面 lsp.lua 會再重設一次
          split_remain_focused = "sgh",
          -- 設定無效按鍵 <C-space> 以取消默認的 keymap
          split = "<C-space>",
          vsplit = "<C-space>",
        }
      })
    end
  },
}
