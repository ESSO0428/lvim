require("dressing").setup({
  input = {
    -- enabled = false,
    get_config = function()
      if vim.g.dress_input ~= nil and vim.g.dress_input then
        vim.g.dress_input = nil
        return { enabled = true }
      else
        return { enabled = false }
      end
    end,
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
  select = {
    -- enabled = false,
    get_config = function()
      if vim.g.dress_input ~= nil and vim.g.dress_input then
        vim.g.dress_input = nil
        return { enabled = true }
      else
        return { enabled = false }
      end
    end
  }
})
