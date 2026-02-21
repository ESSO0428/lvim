return {
  {
    "nvchad/volt",
    lazy = true,
  },
  {
    "nvchad/minty",
    cmd = { "Shades", "Huefy" },
  },
  {
    "nvchad/menu",
    event = "VeryLazy",
    config = function()
      require("user.mouse").setup()
    end,
  },
}
