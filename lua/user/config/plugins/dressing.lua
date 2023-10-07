require("dressing").setup({
  input = {
    enabled = false,
    win_options = {
      -- Window transparency (0-100)
      winblend = 0,
      -- Disable line wrapping
      wrap = false,
      -- Indicator for when text exceeds window
      list = true,
      listchars = "precedes:…,extends:…",
      -- Increase this for more context when text scrolls off the window
      sidescrolloff = 0,
    },
  },
})
