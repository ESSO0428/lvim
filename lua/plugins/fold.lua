return {
  { "kevinhwang91/promise-async" },
  {
    "kevinhwang91/nvim-ufo",
    deprecated = { 'kevinhwang91/promise-async' },
    config = function()
      require("user.config.plugins.fold").setup()
    end,
  },
  {
    "jghauser/fold-cycle.nvim",
    keys = {
      {
        '[f',
        function()
          return require('fold-cycle').close()
        end,
        desc = 'Fold-cycle: close folds',
        silent = true,
      },
      {
        ']f',
        function()
          return require('fold-cycle').open()
        end,
        desc = 'Fold-cycle: open folds',
        silent = true,
      },
      {
        '[g',
        function()
          return require('fold-cycle').close_all()
        end,
        desc = 'Fold-cycle: close all folds',
        silent = true,
        remap = true,
      },
      {
        ']g',
        function()
          return require('fold-cycle').open_all()
        end,
        desc = 'Fold-cycle: open all folds',
        silent = true,
        remap = true,
      },
    },
    config = function()
      require('fold-cycle').setup()
    end
  },
}
