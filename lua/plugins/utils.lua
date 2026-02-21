return {
  {
    "folke/snacks.nvim",
    priority = 1000,
    event = "VeryLazy",
    ---@type snacks.Config
    opts = {
      -- your configuration comes here
      -- or leave it empty to use the default settings
      -- refer to the configuration section below
      terminal = {
        auto_insert = false,
      }
    },
  },
  {
    "echasnovski/mini.nvim",
    version = false,
    event = "VeryLazy",
    config = function()
      local MiniIcons = require('mini.icons')
      MiniIcons.setup({})
      _G.MiniIcons = nil
      local files = require('mini.files')
      files.setup({
        options = {
          -- Whether to delete permanently or move into module-specific trash
          permanent_delete = true,
          -- Whether to use for editing directories
          use_as_default_explorer = false,
        },
        mappings = {
          close       = '<leader>q',
          go_in       = 'l',
          go_in_plus  = 'L',
          go_out      = 'j',
          go_out_plus = 'J',
          reset       = '<BS>',
          reveal_cwd  = '@',
          show_help   = 'g?',
          synchronize = 'S',
          trim_left   = '<',
          trim_right  = '>',
        }
      })
      local minifiles_toggle = function(...)
        if not MiniFiles.close() then MiniFiles.open(...) end
      end

      local minicurrentfiles_toggle = function(...)
        if not MiniFiles.close() then
          local get_parent = vim.fs.dirname
          local exists = function(path) return vim.loop.fs_stat(path) ~= nil end
          local path = vim.api.nvim_buf_get_name(0)

          while not exists(path) do
            path = get_parent(path)
          end
          MiniFiles.open(path)
        end
      end
      vim.api.nvim_create_user_command('MiniFilesToggle', function() minifiles_toggle() end, {})
      vim.api.nvim_create_user_command('MiniCurrentFilesToggle', function() minicurrentfiles_toggle() end, {})
    end,
    keys = {
      { "<leader>-", "<cmd>MiniFilesToggle<cr>",        desc = "Toggle mini file explorer" },
      { "<leader>_", "<cmd>MiniCurrentFilesToggle<cr>", desc = "Toggle mini current file explorer" },
      { "<leader>+", "<cmd>MiniCurrentFilesToggle<cr>", desc = "Toggle mini current file explorer" }
    }
  },
}
