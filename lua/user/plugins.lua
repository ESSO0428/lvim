lvim.plugins = {
  {
    "folke/lazydev.nvim",
    ft = "lua", -- only load on lua files
    opts = {
      library = {
        -- See the configuration section for more details
        -- Load luvit types when the `vim.uv` word is found
        { path = "luvit-meta/library", words = { "vim%.uv" } },
      },
    },
  },
  { "Bilal2453/luvit-meta",         lazy = true }, -- optional `vim.uv` typings
  --[[{                                        -- optional cmp completion source for require statements and module annotations
    "hrsh7th/nvim-cmp",
    opts = function(_, opts)
      opts.sources = opts.sources or {}
      table.insert(opts.sources, {
        name = "lazydev",
        group_index = 0, -- set group index to 0 to skip loading LuaLS completions
      })
    end,
  },--]]
  -- NOTE: make sure to uninstall or disable neodev.nvim for lazydev to work
  {
    "folke/neodev.nvim",
    enabled = false,
  },
  { import = "plugins" },
  { import = "plugins.language" },
  { import = "plugins.autocomplete" },
  -- NOTE: 使用我 fork 的版本，原先的版本對於 nvim-tree 上使用 telescopte 可能造成開檔錯誤 (這裡引入 exclude filetype 排除 telescope 中運行該代碼)
  {
    "ESSO0428/im-select.nvim",
    -- event = "BufReadPost",
    event = { "ModeChanged", "CursorHold" },
    config = function()
      -- Check if im-select.exe exists
      local has_im_select = os.execute('which im-select.exe > /dev/null 2>&1') == 0
      if has_im_select then
        require('im_select').setup({
          -- IM will be set to `default_im_select` in `normal` mode
          -- For Windows/WSL, default: "1033", aka: English US Keyboard
          -- For macOS, default: "com.apple.keylayout.ABC", aka: US
          -- For Linux, default:
          --               "keyboard-us" for Fcitx5
          --               "1" for Fcitx
          --               "xkb:us::eng" for ibus
          -- You can use `im-select` or `fcitx5-remote -n` to get the IM's name
          default_im_select                   = "1033",

          -- Can be binary's name or binary's full path,
          -- e.g. 'im-select' or '/usr/local/bin/im-select'
          -- For Windows/WSL, default: "im-select.exe"
          -- For macOS, default: "im-select"
          -- For Linux, default: "fcitx5-remote" or "fcitx-remote" or "ibus"
          default_command                     = 'im-select.exe',

          -- Restore the default input method state when the following events are triggered
          set_default_events                  = { "VimEnter", "InsertLeave" },

          -- Restore the default input method state (exclude filetype)
          set_default_events_exclude_filetype = { 'TelescopePrompt' },

          -- Restore the previous used input method state when the following events
          -- are triggered, if you don't want to restore previous used im in Insert mode,
          -- e.g. deprecated `disable_auto_restore = 1`, just let it empty
          -- as `set_previous_events = {}`
          set_previous_events                 = { "InsertEnter" },

          -- Show notification about how to install executable binary when binary missed
          keep_quiet_on_no_binary             = false,

          -- Async run `default_command` to switch IM or not
          async_switch_im                     = true
        })
      end
    end
  },
  {
    "rcarriga/nvim-notify",
    event = "VeryLazy",
    config = function()
      local notify = require("notify")
      notify.setup({
        -- "fade", "slide", "fade_in_slide_out", "static"
        stages = "static",
        on_open = nil,
        on_close = nil,
        timeout = 1000,
        fps = 1,
        render = "default",
        background_colour = "Normal",
        max_width = math.floor(vim.api.nvim_win_get_width(0) / 2),
        max_height = math.floor(vim.api.nvim_win_get_height(0) / 4),
        -- minimum_width = 50,
        -- ERROR > WARN > INFO > DEBUG > TRACE
        level = "TRACE"
      })

      -- vim.notify = notify
      local banned_messages = { "No information available" }
      ---@diagnostic disable-next-line: duplicate-set-field
      vim.notify = function(msg, ...)
        for _, banned in ipairs(banned_messages) do
          if msg == banned then
            return
          end
        end
        notify(msg, ...)
      end
    end
  },
  {
    "Eandrju/cellular-automaton.nvim",
    config = function()
      CellularAutomaton_make_it_rain = function()
        local status, err = pcall(function()
          vim.cmd("CellularAutomaton make_it_rain")
        end)
        if not status then
          print('CellularAutomaton : folding and wrapping is not supported')
        end
      end
    end,
    keys = {
      { "<leader>Tc", "<cmd>lua CellularAutomaton_make_it_rain()<cr>", desc = "CellularAutomaton Make It Rain" }
    }
  },
  {
    "kazhala/close-buffers.nvim",
    -- event = "BufReadPost",
    event = "User FileOpened",
    config = function()
      require("user.config.plugins.bufferlinekill").setup()
    end
  },
  {
    "ThePrimeagen/harpoon",
    event = "User FileOpened",
    config = function()
      require("harpoon").setup()
    end,
    dependencies = { "nvim-lua/plenary.nvim" }
  },
  {
    "stevearc/oil.nvim",
    cmd = "Oil", -- ★ command lazy
    opts = {
      default_file_explorer = false,
      keymaps = {
        ["g?"] = { "actions.show_help", mode = "n" },
        ["<cr>"] = { "actions.select", mode = "n" },
        ["<tab>"] = { "actions.select", mode = "n" },
        ["<a-l>"] = { "actions.select", opts = { vertical = true }, desc = "Open the entry in a vertical split", mode = "n" },
        ["<a-k>"] = { "actions.select", opts = { horizontal = true }, desc = "Open the entry in a horizontal split", mode = "n" },
        ["<C-t>"] = { "actions.select", opts = { tab = true }, desc = "Open the entry in new tab", mode = "n" },
        ["gh"] = { "actions.preview", mode = "n" },
        ["q"] = { "actions.close", mode = "n" },
        ["`"] = { "actions.refresh", mode = "n" },
        ["<"] = { "actions.parent", mode = "n" },
        [">"] = { "actions.select", mode = "n" },
        ["go"] = { "actions.open_cwd", mode = "n" },
        ["gc"] = { "actions.cd", mode = "n" },
        ["gC"] = { "actions.cd", opts = { scope = "tab" }, desc = ":tcd to the current oil directory", mode = "n" },
        ["gs"] = { "actions.change_sort", mode = "n" },
        ["gx"] = { "actions.open_external", mode = "n" },
        ["g."] = { "actions.toggle_hidden", mode = "n" },
        ["g\\"] = { "actions.toggle_trash", mode = "n" },
      },
      -- Set to false to disable all of the above keymaps
      use_default_keymaps = false,
    },
    -- Optional dependencies
    dependencies = { "nvim-tree/nvim-web-devicons" }
  },
  {
    "ESSO0428/calc.vim",
    cmd = { "Calc" },
  },
  {
    "nvimtools/hydra.nvim",
    event = "VeryLazy", -- 只有你真的用 hydra 的時候才會拖一點
    config = function()
      require("user.keymappings.hydra").setup()
    end,
  },
  {
    "Shatur/neovim-session-manager",
    config = function()
      vim.api.nvim_clear_autocmds {
        group = "SessionManager",
        event = "VimEnter",
      }
      local group = vim.api.nvim_create_augroup("SessionManager", { clear = false })
      vim.api.nvim_create_autocmd("User", {
        group = group,
        pattern = "VeryLazy",
        nested = true,
        callback = function()
          require("session_manager").autoload_session()
        end,
      })
    end
  },
  {
    "AckslD/nvim-neoclip.lua",
    deprecated = { 'nvim-telescope/telescope.nvim' },
    config = function()
      require('neoclip').setup()
      vim.api.nvim_create_autocmd('TextYankPost', {
        group = vim.api.nvim_create_augroup('NeoclipManualInsert', { clear = true }),
        pattern = '*',
        callback = function()
          if require('neoclip').stopped then
            return
          end
          if vim.v.event.regcontents == nil then
            require('neoclip.storage').insert({
              regtype = "l",
              contents = vim.fn.getreg('"', 1, true),
              filetype = vim.bo.filetype,
            }, 'yanks')
          end
        end,
      })
    end,
  },
  -- { "elijahmanor/export-to-vscode.nvim" },
  -- 已將其代碼自行 copy 到我的 lua dir 下了
  {
    "aznhe21/actions-preview.nvim",
    event = "User FileOpened",
    config = function()
      require("actions-preview").setup {
        diff = {
          algorithm = "patience",
          ignore_whitespace = true,
        },
        telescope = vim.tbl_extend(
          "force",
          -- telescope theme: https://github.com/nvim-telescope/telescope.nvim#themes
          require("telescope.themes").get_dropdown({ initial_mode = "normal" }),
          -- a table for customizing content
          {
            -- a function to make a table containing the values to be displayed.
            -- fun(action: Action): { title: string, client_name: string|nil }
            make_value = nil,

            -- a function to make a function to be used in `display` of a entry.
            -- see also `:h telescope.make_entry` and `:h telescope.pickers.entry_display`.
            -- fun(values: { index: integer, action: Action, title: string, client_name: string }[]): function
            make_make_display = nil,
          }
        ),
      }
    end
  },
  {
    "kosayoda/nvim-lightbulb",
    event = "LspAttach",
    opts = require("user.config.plugins.nvim_lightbulb").opt,
  },
  {
    "hedyhli/outline.nvim",
    cmd = { "Outline", "OutlineOpen" },
    opts = {
      -- Your setup opts here (leave empty to use defaults)
      preview_window = {
        auto_preview = true,
      },
      focus_on_open = false,
      keymaps = {
        close = { '<Esc>', 'q', '<leader>q' },
        fold = { 'h', '[f' },
        unfold = { 'l', ']f' },
        fold_toggle = { '<Tab>', '<leader>o' },
        fold_all = { 'W', '<leader>Oa', '[g' },
        unfold_all = { 'E', '<leader>Od', ']g' },
        hover_symbol = 'gh',
      }
    }
  },
  {
    "miversen33/netman.nvim",
    event = "User FileOpened",
  },
  {
    "nvim-neo-tree/neo-tree.nvim",
    -- event = "User DirOpened",
    cmd = "Neotree",
    branch = "v3.x",
    deprecated = {
      "miversen33/netman.nvim",
      "nvim-lua/plenary.nvim",
      "nvim-tree/nvim-web-devicons", -- not strictly required, but recommended
      "MunifTanjim/nui.nvim",
      "s1n7ax/nvim-window-picker",
    },
    config = function()
      require("user.neotree").setup()
    end
  },
}
