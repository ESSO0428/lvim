return {
  -- { "tpope/vim-fugitive" },
  {
    "ESSO0428/vim-fugitive",
    cmd = { "Git", "G", "Gdiffsplit", "Gread", "Gwrite", "Gstatus" },
  },
  {
    "rbong/vim-flog",
    cmd = { "Flog", "Flogsplit" },
  },
  {
    "sindrets/diffview.nvim",
    cmd = { "DiffviewOpen", "DiffviewClose", "DiffviewFileHistory" },
    config = function()
      require("user.config.plugins.DiffView").setup()
    end,
  },
}
