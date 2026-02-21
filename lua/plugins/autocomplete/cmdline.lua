return {
  {
    "gelguy/wilder.nvim",
    build = ":UpdateRemotePlugins",
    event = "CmdlineEnter",
    config = function()
      require("user.config.plugins.wilder").setup()
    end,
  },
}
