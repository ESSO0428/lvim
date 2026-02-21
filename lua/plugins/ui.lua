return {
  {
    "ESSO0428/tabline.nvim",
    event = "User FileOpened",
    config = function()
      require 'tabline'.setup {
        enable = false,
        options = {
          show_tabs_always = true
        }
      }
      vim.cmd [[
        set guioptions-=e " Use showtabline in gui vim
        set sessionoptions+=tabpages,globals " store tabpages and globals in session
      ]]
    end,
    dependencies = { 'fgheng/winbar.nvim', 'nvim-lualine/lualine.nvim', 'nvim-tree/nvim-web-devicons' }
  },
  {
    "nvim-lua/popup.nvim",
    -- event = "VeryLazy", -- 很多 plugin 依賴，但不必一開始就載
    event = "User FileOpened", -- 很多 plugin 依賴，但不必一開始就載
  },
  {
    "petertriho/nvim-scrollbar",
    -- event = "BufReadPost",
    event = "User FileOpened",
    config = function()
      require("scrollbar").setup({
        show = true,
        handle = {
          text = " ",
          color = "#928374",
          hide_if_all_visible = true
        },
        marks = {
          Search = { color = "yellow" },
          Misc = { color = "purple" }
        },
      })
    end
  },
  {
    "kevinhwang91/nvim-hlslens",
    event = "CmdlineEnter",
    config = function()
      require('hlslens').setup({})
    end
  },
  {
    "stevearc/dressing.nvim",
    event = "VeryLazy",
    opts = require("user.config.plugins.dressing").opt,
  },
  {
    "folke/trouble.nvim",
    event = "VeryLazy",
    config = function()
      require("user.trouble").setup()
    end
  },
  {
    "folke/edgy.nvim",
    event = "VeryLazy",
    init = function()
      vim.opt.laststatus = 3
      vim.opt.splitkeep = "screen"
    end,
  },
}
