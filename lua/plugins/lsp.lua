return {
  -- WARNING: 這會造成 Nvim-tree 上運行 Telescope 出錯 (可能要壞成其他替代的套件)
  -- {
  --   'linrongbin16/lsp-progress.nvim',
  --   dependencies = { 'nvim-tree/nvim-web-devicons' },
  --   config = function()
  --     require('lsp-progress').setup()
  --   end
  -- },
  -- WARNING: 這會造成大量讀檔 (process too many files) lsof -p neovim_pid | wc -l 的問題，導致後續各種套件和 neovim 本身的功能失效 (待解決前先禁用)
  -- {
  --   "VidocqH/lsp-lens.nvim",
  --   config = function()
  --     require 'lsp-lens'.setup({})
  --   end
  -- },
  {
    "glepnir/lspsaga.nvim",
    branch = "main",
    -- commit = "4f07545",
    event = "LspAttach",
    opts = {
      finder = {
        max_height = 0.5,
        min_width = 30,
        force_max_height = false,
        keys = {
          shuttle = '<c-s>',
          toggle_or_open = { 'l', '<cr>' },
          vsplit = '<a-l>',
          split = '<a-k>',
          tabe = 't',
          tabnew = 'r',
          quit = { "q", "<ESC>", "<leader>q" },
          -- close = '<ESC>',
        },
      },
      outline = {
        enable = false,
        win_position = "right",
        win_with = "",
        win_width = 30,
        preview_width = 0.4,
        show_detail = true,
        auto_preview = true,
        auto_refresh = true,
        auto_close = true,
        auto_resize = false,
        custom_sort = nil,
        keys = {
          toggle_or_jump = 'l',
          jump = { '<cr>', 'o' },
          quit = { "q", "<ESC>", "<leader>q" }
        }
      },
      symbol_in_winbar = {
        enable = false,
        separator = " ",
        ignore_patterns = {},
        hide_keyword = true,
        show_file = true,
        folder_level = 2,
        respect_root = false,
        color_mode = true
      },
      lightbulb = {
        enable = false,
        enable_in_insert = true,
        sign = true,
        sign_priority = 40,
        virtual_text = false
      },
      callhierarchy = {
        enable = true,
        layout = "normal",
        keys = {
          edit = 'e',
          vsplit = '<a-l>',
          split = '<a-k>',
          tabe = 't',
          quit = { "q", "<ESC>", "<leader>q" },
          shuttle = '<c-s>',
          toggle_or_req = { 'l', '<cr>' },
          close = '<C-c>k'
        }
      }
    },
    deprecated = {
      { "nvim-tree/nvim-web-devicons" },
      --Please make sure you install markdown and markdown_inline parser
      { "nvim-treesitter/nvim-treesitter" }
    }
  },
  {
    "ray-x/lsp_signature.nvim",
    event = "InsertEnter",
    config = function()
      require "lsp_signature".on_attach()
      require "lsp_signature".setup({
        bind = true, -- This is mandatory, otherwise border config won't get registered.
        handler_opts = {
          border = "rounded"
        },
        hint_prefix = "🌟 ",
      })
    end
  },
  {
    "Davidyz/inlayhint-filler.nvim",
    event = "LspAttach",
  },
  {
    "antosha417/nvim-lsp-file-operations",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-tree/nvim-tree.lua",
      "nvim-neo-tree/neo-tree.nvim"
    },
    event = "LspAttach",
    config = function()
      require("lsp-file-operations").setup {
        -- used to see debug logs in file `vim.fn.stdpath("cache") .. lsp-file-operations.log`
        debug = false,
        -- select which file operations to enable
        operations = {
          willRenameFiles = true,
          didRenameFiles = true,
          willCreateFiles = true,
          didCreateFiles = true,
          willDeleteFiles = true,
          didDeleteFiles = true,
        },
        -- how long to wait (in milliseconds) for file rename information before cancelling
        timeout_ms = 10000,
      }
    end,
  },
  {
    "rmagatti/goto-preview",
    config = function()
      require('goto-preview').setup {
        post_open_hook = function(_, win)
          -- Close the current preview window with <Esc>
          vim.keymap.set(
            'n',
            'q',
            function()
              vim.api.nvim_win_close(win, true)
            end,
            { buffer = true, nowait = true }
          )
        end,
      }
    end
  },
}
