return {
  {
    "Joakker/lua-json5",
    -- if you're on windows
    -- run = 'powershell ./install.ps1'
    build = './install.sh'
  },
  {
    "ofirgall/goto-breakpoints.nvim",
    event = "User FileOpened",
  },
  {
    "Weissle/persistent-breakpoints.nvim",
    -- event = "BufReadPost",
    event = "User FileOpened",
    config = function()
      require('persistent-breakpoints').setup {
        load_breakpoints_event = { "SessionLoadPost" }
      }
    end
  },
  {
    "LiadOz/nvim-dap-repl-highlights",
    -- event = "VeryLazy",
    ft = "dap-repl",
    config = function()
      require('nvim-dap-repl-highlights').setup()
    end
  },
  {
    "theHamsta/nvim-dap-virtual-text",
    -- event = "VeryLazy",
    event = "User FileOpened",
    config = function(_, opts)
      require "nvim-dap-virtual-text".setup(opts)
    end
  },
  { "rcarriga/cmp-dap" },
  { "nvim-telescope/telescope-dap.nvim" },
  {
    "mfussenegger/nvim-dap-python",
    ft = "python",
    build = "pip install debugpy"
  },
}
