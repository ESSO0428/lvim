require("winshift").setup({
  highlight_moving_win = true, -- Highlight the window being moved
  focused_hl_group = "Visual", -- The highlight group used for the moving window
  moving_win_options = {
    -- These are local options applied to the moving window while it's
    -- being moved. They are unset when you leave Win-Move mode.
    wrap = false,
    cursorline = false,
    cursorcolumn = false,
    colorcolumn = "",
  },
  keymaps = {
    disable_defaults = false, -- Disable the default keymaps
    win_move_mode = {
      ["j"] = "left",
      ["k"] = "down",
      ["i"] = "up",
      ["l"] = "right",
      ["J"] = "far_left",
      ["K"] = "far_down",
      ["I"] = "far_up",
      ["L"] = "far_right",
      ["<left>"] = "left",
      ["<down>"] = "down",
      ["<up>"] = "up",
      ["<right>"] = "right",
      ["<S-left>"] = "far_left",
      ["<S-down>"] = "far_down",
      ["<S-up>"] = "far_up",
      ["<S-right>"] = "far_right",
    },
  },
})
lvim.keys.normal_mode['<a-w>'] = { '<cmd>WinShift swap<cr>' }
lvim.keys.normal_mode['<a-e>'] = { '<cmd>WinShift<cr>' }
