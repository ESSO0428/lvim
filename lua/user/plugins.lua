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
  { "Bilal2453/luvit-meta", lazy = true }, -- optional `vim.uv` typings
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
  {
    "folke/edgy.nvim",
    event = "VeryLazy",
    init = function()
      vim.opt.laststatus = 3
      vim.opt.splitkeep = "screen"
    end,
  },
  {
    "folke/trouble.nvim",
    cmd = "TroubleToggle"
  },
  { "kevinhwang91/rnvimr" },
  {
    "kevinhwang91/nvim-hlslens",
    config = function()
      require('hlslens').setup({})
    end
  },
  -- NOTE: 使用我 folk 的版本，原先的版本對於 nvim-tree 上使用 telescopte 可能造成開檔錯誤 (這裡引入 exclude filetpe 排除 telescope 中運行該代碼)
  {
    "ESSO0428/im-select.nvim",
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
    "nvim-treesitter/nvim-treesitter",
    -- run = ":TSUpdate",
    -- NOTE: cover the default config of lunarvim
    -- Current Update Time: 2024-09-12
    commit = "b6a6d89",
    config = function()
      local utils = require "lvim.utils"
      local path = utils.join_paths(get_runtime_dir(), "site", "pack", "lazy", "opt", "nvim-treesitter")
      vim.opt.rtp:prepend(path) -- treesitter needs to be before nvim's runtime in rtp
      require("lvim.core.treesitter").setup()
    end,
    cmd = {
      "TSInstall",
      "TSUninstall",
      "TSUpdate",
      "TSUpdateSync",
      "TSInstallInfo",
      "TSInstallSync",
      "TSInstallFromGrammar",
    },
    event = "User FileOpened",
  },
  {
    "ESSO0428/telescope-tabs",
    config = function()
      require("telescope-tabs").setup {
        entry_formatter = function(tab_id, buffer_ids, file_names, file_paths, is_current)
          if vim.g.Tabline_session_data == nil then
            return
          end
          local TablineData = vim.fn.json_decode(vim.g.Tabline_session_data)
          -- need require "user.tabpage" in config.lua
          local status_ok, tabpage_id = pcall(find_tabpage_index, tab_id)
          if not status_ok then
            print(table.concat(
              {
                "telescope-tabs Error : need require \"user.tabpage\" with function find_tabpage_index in config.lua",
                "telescope-tabs Error : or Not found correctly tab_id in nvim tab list"
              },
              "\n")
            )
            return
          end

          local tab_name = TablineData[tabpage_id].name
          -- require("tabby.feature.tab_name").get(tab_id)
          -- return string.format("%d: %s%s", tab_id, tab_id, is_current and " <" or "")

          -- Get the focused window's buffer ID for the current tab
          local focused_win = vim.fn.tabpagewinnr(tabpage_id)

          -- Iterate over file_names and add '<' if the corresponding buffer exists
          file_names[focused_win] = file_names[focused_win] .. " #"

          local entry_string = table.concat(file_names, ', ')
          return string.format('%d [%s]: %s%s', tabpage_id, tab_name, entry_string, is_current and ' <' or '')
        end,
        entry_ordinal = function(tab_id, buffer_ids, file_names, file_paths, is_current)
          -- return table.concat(file_names, ' ')
          if vim.g.Tabline_session_data == nil then
            return
          end
          local TablineData = vim.fn.json_decode(vim.g.Tabline_session_data)
          -- need require "user.tabpage" in config.lua
          local status_ok, tabpage_id = pcall(find_tabpage_index, tab_id)
          if not status_ok then
            return
          end

          -- return TablineData[tab_id].name
          local entry_string = table.concat(file_names, ', ')
          return string.format('%d %s %s', tabpage_id, TablineData[tabpage_id].name, entry_string)
          -- require("tabby.feature.tab_name").get(tab_id)
        end,
        close_tab_shortcut_i = '<C-d>', -- if you're in insert mode
        close_tab_shortcut_n = 'dd',    -- if you're in normal mode
      }
    end
  },
  {
    'ESSO0428/tabline.nvim',
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
    "rcarriga/nvim-notify",
    lazy = true,
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
      vim.keymap.set("n", "<leader>Tc", "<cmd>lua CellularAutomaton_make_it_rain()<cr>")
    end
  },
  -- WARNING: 這會造成 Nvim-tree 上運行 Telescope 出錯 (可能要壞成其他替代的套件)
  -- {
  --   'linrongbin16/lsp-progress.nvim',
  --   dependencies = { 'nvim-tree/nvim-web-devicons' },
  --   config = function()
  --     require('lsp-progress').setup()
  --   end
  -- },
  { "kazhala/close-buffers.nvim" },
  {
    "ThePrimeagen/harpoon",
    config = function()
      require("harpoon").setup()
    end,
    dependencies = { "nvim-lua/plenary.nvim" }
  },
  {
    "ThePrimeagen/refactoring.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-treesitter/nvim-treesitter",
    },
    config = function()
      require("refactoring").setup()
    end,
  },
  {
    'stevearc/oil.nvim',
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
    'echasnovski/mini.nvim',
    version = false,
    config = function()
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
  {
    "antosha417/nvim-lsp-file-operations",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-tree/nvim-tree.lua",
      "nvim-neo-tree/neo-tree.nvim"
    },
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
    "AckslD/muren.nvim",
    config = true
  },
  { "ESSO0428/calc.vim" },
  { "ESSO0428/bioSyntax-vim" },
  {
    "ESSO0428/semshi",
    ft = "python",
    build = ":UpdateRemotePlugins",
    init = function()
      --#region semshi colorscheme settings
      -- Disabled these features better provided by LSP or other more general plugins
      vim.g["semshi#error_sign"] = false
      vim.g["semshi#simplify_markup"] = false
      vim.g["semshi#update_delay_factor"] = 0.001

      -- This autocmd must be defined in init to take effect
      vim.api.nvim_create_autocmd({ "VimEnter", "ColorScheme" }, {
        group = vim.api.nvim_create_augroup("SemanticHighlight", {}),
        callback = function()
          -- Only add style, inherit or link to the LSP's colors
          -- vim.cmd "au ColorScheme * highlight! semshiImported gui=bold guifg=#e0949e"
          -- vim.cmd "au ColorScheme * highlight! semshiImported gui=bold guifg=#ff6666"
          -- vim.cmd "au ColorScheme * highlight! semshiGlobal gui=bold guifg=#9cdcfe"
          -- vim.cmd "au ColorScheme * highlight! link semshiAttribute @attribute"
          -- vim.cmd "au ColorScheme * highlight! link semshiBuiltin @function.builtin"
          -- vim.cmd "au ColorScheme * highlight! link semshiBuiltin @field"
          vim.cmd([[
            " highlight! semshiImported gui=bold guifg=#4ec9b0
            highlight! semshiImported gui=bold guifg=none
            " highlight! semshiGlobal gui=bold
            " highlight! semshiImported guifg=#4ec9b0
            highlight! link semshiGlobal cleared
            highlight! link semshiParameter @parameter.python
            highlight! link semshiParameterUnused @parameter.python
            highlight! semshiParameterUnused gui=undercurl
            highlight! link semshiAttribute @field
            highlight! semshiBuiltin guifg=#dcdcaa
            highlight! link semshiUnresolved @text.warning
            highlight! link semshiSelf @variable.builtin
            ]])
        end,
      })
      --#endregion
    end,
  },
  {
    "mechatroner/rainbow_csv",
    ft = {
      'csv',
      'csv_semicolon', 'csv_whitespace',
      'csv_pipe', 'rfc_csv', 'rfc_semicolon',
      'tsv'
    }
  },
  {
    "brenoprata10/nvim-highlight-colors",
    config = function()
      require("nvim-highlight-colors").setup {
        ---Render style
        ---@usage 'background'|'foreground'|'virtual'
        render = 'virtual',

        ---Set virtual symbol (requires render to be set to 'virtual')
        virtual_symbol = '■',

        ---Highlight named colors, e.g. 'green'
        enable_named_colors = false,

        ---Highlight tailwind colors, e.g. 'bg-blue-500'
        enable_tailwind = true,

        ---Set custom colors
        ---Label must be properly escaped with '%' to adhere to `string.gmatch`
        --- :help string.gmatch
        custom_colors = {
          { label = '%-%-theme%-primary%-color',   color = '#0f1219' },
          { label = '%-%-theme%-secondary%-color', color = '#5a5d64' },
        }
      }
    end
  },
  {
    'rmagatti/goto-preview',
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
  {
    "amrbashir/nvim-docs-view",
    config = function()
      require("docs-view").setup {
        position = "bottom",
        width = 60,
      }
      vim.keymap.set("n", "<leader>th", "<cmd>DocsViewToggle<cr>")
    end
  },
  -- WARNING: 這會造成大量讀檔 (process too many files) lsof -p neovim_pid | wc -l 的問題，導致後續各種套件和 neovim 本身的功能失效 (待解決前先禁用)
  -- {
  --   "VidocqH/lsp-lens.nvim",
  --   config = function()
  --     require 'lsp-lens'.setup({})
  --   end
  -- },
  {
    "soulis-1256/eagle.nvim",
    config = function()
      require("eagle").setup({
        -- override the default values found in config.lua
        render_delay = 200, -- default is 500
        detect_idle_timer = 50,
        border = "single",
        border_color = "#3d59a1",
      })
    end
  },
  {
    "ESSO0428/NotebookNavigator.nvim",
    keys = {
      { "gi", function() require("notebook-navigator").move_cell "u" end },
      { "gk", function() require("notebook-navigator").move_cell "d" end },
      { "[e", function() require("notebook-navigator").run_cells_above "" end },
      { "]e", function() require("notebook-navigator").run_cells_below "" end },
    },
    dependencies = {
      "echasnovski/mini.comment",
      -- "akinsho/toggleterm.nvim", -- alternative repl provider
      "anuvyklack/hydra.nvim",
    },
    event = "VeryLazy",
    config = function()
      local nn = require "notebook-navigator"
      nn.setup({
        activate_hydra_keys = "<leader>hj",
        show_hydra_hint = false,
        hydra_keys = {
          comment = "c",
          run = "e",
          run_and_move = "nil",
          move_up = "{",
          move_down = "}",
          split_cell = "sc",
          add_cell_before = "nil",
          add_cell_after = "nil",
        },
        repl_provider = "iron"
      })
    end
  },
  {
    "echasnovski/mini.ai",
    event = "VeryLazy",
    dependencies = { "ESSO0428/NotebookNavigator.nvim" },
    opts = function()
      local nn = require "notebook-navigator"

      local opts = { custom_textobjects = { h = nn.miniai_spec } }
      return opts
    end
  },
  {
    "echasnovski/mini.hipatterns",
    event = "VeryLazy",
    dependencies = { "ESSO0428/NotebookNavigator.nvim" },
    opts = function()
      local nn = require "notebook-navigator"

      local opts = { highlighters = { cells = nn.minihipatterns_spec } }
      return opts
    end
  },
  { "jbyuki/venn.nvim" },
  { "tomasky/bookmarks.nvim" },
  {
    "ESSO0428/vim-dadbod-ui",
    dependencies = { "tpope/vim-dadbod", "tpope/vim-dotenv" }
  },
  { "kristijanhusak/vim-dadbod-completion" },
  { "LinArcX/telescope-command-palette.nvim" },
  { "nvim-telescope/telescope-live-grep-args.nvim" },
  {
    "nvim-telescope/telescope-file-browser.nvim",
    dependencies = { "nvim-telescope/telescope.nvim", "nvim-lua/plenary.nvim" }
  },
  {
    'nvim-orgmode/orgmode',
    dependencies = {
      { 'nvim-treesitter/nvim-treesitter', lazy = true },
    },
    config = function()
      -- Setup treesitter
      require('nvim-treesitter.configs').setup({
        highlight = {
          enable = true,
        },
        ignore_install = { 'org' },
      })
    end,
  },
  {
    'akinsho/org-bullets.nvim',
    ft = { "org" },
    config = function()
      require('org-bullets').setup()
    end
  },
  {
    'lukas-reineke/headlines.nvim',
    dependencies = "nvim-treesitter/nvim-treesitter",
    config = true, -- or `opts = {}`
  },
  -- NOTE: because orgmode update and org.parser.files depend on orgmode, so I have to disable it
  -- {
  --   "joaomsa/telescope-orgmode.nvim"
  -- },
  {
    'gelguy/wilder.nvim',
    build = ":UpdateRemotePlugins",
    event = "CmdlineEnter"
  },
  { "rcarriga/cmp-dap" },
  {
    "github/copilot.vim",
    commit = "7097b09"
  },
  { "hrsh7th/cmp-copilot" },
  {
    "CopilotC-Nvim/CopilotChat.nvim",
    -- NOTE: If you can't activate the plugin, please check the following:
    -- 1. Check if the $XDG_RUNTIME_DIR directory exists.
    -- 2. Verify the permissions of $XDG_RUNTIME_DIR:
    --    - Use the command `ls -ld $XDG_RUNTIME_DIR` to check its existence and permissions.
    -- 3. If the directory does not exist, create it with: `mkdir -p $XDG_RUNTIME_DIR`.
    -- 4. Set appropriate permissions:
    --    - For example, you can use `chmod 755 $XDG_RUNTIME_DIR`
    --    - Alternatively, use `chmod 777 $XDG_RUNTIME_DIR`
    dependencies = {
      { "github/copilot.vim" },    -- or github/copilot.vim
      { "nvim-lua/plenary.nvim" }, -- for curl, log wrapper
    }
  },
  {
    "yetone/avante.nvim",
    event = "VeryLazy",
    version = false, -- Set this to "*" to always pull the latest release version, or set it to false to update to the latest code changes.
    -- NOTE: If you can't activate the plugin, please check the following (same as CopilotChat.nvim):
    -- 1. Check if the $XDG_RUNTIME_DIR directory exists.
    -- 2. Verify the permissions of $XDG_RUNTIME_DIR:
    --    - Use the command `ls -ld $XDG_RUNTIME_DIR` to check its existence and permissions.
    -- 3. If the directory does not exist, create it with: `mkdir -p $XDG_RUNTIME_DIR`.
    -- 4. Set appropriate permissions:
    --    - For example, you can use `chmod 755 $XDG_RUNTIME_DIR`
    --    - Alternatively, use `chmod 777 $XDG_RUNTIME_DIR`
    -- NOTE: my conifg is set in user/avante.lua
    -- and had required by config.lua
    --
    opts = require("user.avante").opts,
    -- if you want to download pre-built binary, then pass source=false. Make sure to follow instruction above.
    -- Also note that downloading prebuilt binary is a lot faster comparing to compiling from source.
    -- NOTE: Ensure that `nvim --version` >= 0.10.1
    -- NOTE: To use `avante.nvim`, ensure that `cargo --version` >= 1.80.0. You can update the version using `rustup update`.
    -- If the plugin was installed before this version, you must use the command `:Lazy` to clear `avante.nvim`.
    -- 1. Then, re-login to Linux or reload `.bashrc` or `.zshrc`, and restart nvim to reinstall the plugin.
    -- 2. Since the provider is copilot, ensure you have successfully logged in using `:Copilot auth` to avoid potential errors.
    build = "make",
    dependencies = {
      "stevearc/dressing.nvim",
      "nvim-lua/plenary.nvim",
      "MunifTanjim/nui.nvim",
      --- The below dependencies are optional,
      "echasnovski/mini.pick",         -- for file_selector provider mini.pick
      "nvim-telescope/telescope.nvim", -- for file_selector provider telescope
      "hrsh7th/nvim-cmp",              -- autocompletion for avante commands and mentions
      "nvim-tree/nvim-web-devicons",   -- or echasnovski/mini.icons
      "github/copilot.vim",            -- for providers='copilot'
      {
        -- support for image pasting
        "HakonHarnes/img-clip.nvim",
        event = "VeryLazy",
        opts = {
          -- recommended settings
          default = {
            embed_image_as_base64 = false,
            prompt_for_file_name = false,
            drag_and_drop = {
              insert_mode = true,
            },
            -- required for Windows users
            use_absolute_path = true,
          },
        },
      },
    },
  },
  -- { "HiPhish/nvim-ts-rainbow2" },
  { "HiPhish/rainbow-delimiters.nvim" },
  {
    "nvim-treesitter/playground",
    event = "BufRead",
  },
  -- WARNING: 使用此套件時請謹慎，因為它可能會導致在 nvim-tree 中結合使用 telescope 時出現開啟文件的錯誤。
  -- 當前的暫時解決方案是在 Neovim 配置文件中添加名為 handle_telescope_nvimtree_interaction (nvimtree.lua) 的函數，
  -- 並在 BufWinLeave 事件中觸發該函數。
  -- 這個解決方案主要處理了 NvimTreePicker 啟用前會先離開 NvimTree 的機制：
  -- 在啟用 window-picker 功能前，會先離開 filetype 為 NvimTree 和 buftype 為 nofile 的 buffer window，
  -- 在離開該窗口時，此函數將關閉所有疑似由 nvim-treesitter-context 插件創建的浮動窗口 (沒處理好的話會在 window-picker 前被讀取)，
  -- 這些窗口包含 filenam == '', filetype == '' 和 buftype == 'nofile 的屬性，可能會干擾文件正常的打開過程。
  -- NOTE: 這裡先固定 commit 後續 nvim 大改再考慮更新
  {
    "nvim-treesitter/nvim-treesitter-context",
    config = function()
      vim.keymap.set('n', '[a', function() require("treesitter-context").go_to_context() end,
        { silent = true, nowait = true })
      require("treesitter-context").setup {
        enable = true,            -- Enable this plugin (Can be enabled/disabled later via commands)
        max_lines = 0,            -- How many lines the window should span. Values <= 0 mean no limit.
        min_window_height = 0,    -- Minimum editor window height to enable context. Values <= 0 mean no limit.
        line_numbers = true,
        multiline_threshold = 20, -- Maximum number of lines to show for a single context
        trim_scope = 'outer',     -- Which context lines to discard if `max_lines` is exceeded. Choices: 'inner', 'outer'
        mode = 'cursor',          -- Line used to calculate context. Choices: 'cursor', 'topline'
        -- Separator between context and content. Should be a single character string, like '-'.
        -- When separator is set, the context will only show up when there are at least 2 lines above cursorline.
        separator = nil,
        zindex = 20,     -- The Z-index of the context window
        on_attach = nil, -- (fun(buf: integer): boolean) return false to disable attaching
      }
    end
  },
  {
    "windwp/nvim-ts-autotag",
    config = function()
      require("nvim-ts-autotag").setup()
    end
  },
  { "kevinhwang91/promise-async" },
  {
    'kevinhwang91/nvim-ufo',
    deprecated = { 'kevinhwang91/promise-async' }
  },
  {
    'luukvbaal/statuscol.nvim',
    opts = function()
      local builtin = require('statuscol.builtin')
      return {
        setopt = true,
        -- override the default list of segments with:
        -- number-less fold indicator, then signs, then line number & separator
        segments = {
          { text = { '%s' },                  click = 'v:lua.ScSa' },
          { text = { builtin.foldfunc, ' ' }, click = 'v:lua.ScFa' },
          {
            text = { builtin.lnumfunc, ' ' },
            condition = { true, builtin.not_empty },
            click = 'v:lua.ScLa',
          },
        },
      }
    end,
  },
  {
    'jghauser/fold-cycle.nvim',
    config = function()
      require('fold-cycle').setup()
      vim.keymap.set('n', '[f',
        function() return require('fold-cycle').close() end,
        { silent = true, desc = 'Fold-cycle: close folds' })
      vim.keymap.set('n', ']f',
        function() return require('fold-cycle').open() end,
        { silent = true, desc = 'Fold-cycle: open folds' })
      vim.keymap.set('n', '[g',
        function() return require('fold-cycle').close_all() end,
        { remap = true, silent = true, desc = 'Fold-cycle: close all folds' })
      vim.keymap.set('n', ']g',
        function() return require('fold-cycle').open_all() end,
        { remap = true, silent = true, desc = 'Fold-cycle: Open all folds' })
    end
  },
  {
    'junegunn/fzf',
  },
  {
    "kevinhwang91/nvim-bqf",
    ft = 'qf',
    config = function()
      require("bqf").setup({
        auto_enable = true,
        preview = {
          win_height = 12,
          win_vheight = 12,
          delay_syntax = 80,
          border_chars = { "┃", "┃", "━", "━", "┏", "┓", "┗", "┛", "█" }
        },
        func_map = {
          split = "<a-k>",
          vsplit = "<a-l>",
          ptogglemode = "z,",
          stoggleup = "",
          pscrollup = "<c-u>",
          pscrolldown = '<C-o>',
          fzffilter = '<c-f>'
        },
        filter = {
          fzf = {
            action_for = { ["ctrl-s"] = "split" },
            extra_opts = { "--bind", "ctrl-o:toggle-all", "--prompt", "> " }
          }
        }
      })
    end
  },
  {
    'stevearc/quicker.nvim',
    event = "FileType qf",
    ---@module "quicker"
    ---@type quicker.SetupOptions
    opts = {},
    config = function()
      require("quicker").setup({
        opts = {
          buflisted = false,
          number = false,
          relativenumber = false,
          signcolumn = "auto",
          winfixheight = true,
          wrap = false,
        },
        keys = {
          {
            ">",
            function()
              local win_info = vim.fn.getwininfo(vim.api.nvim_get_current_win())[1]
              local is_quickfix = win_info and win_info.quickfix == 1
              local is_loclist = win_info and win_info.loclist == 1
              if is_quickfix and not is_loclist then
                vim.cmd("cclose")
                require("quicker").collapse()
                require("quicker").expand({ before = 2, after = 2, add_to_existing = true })
                Nvim.Quickfix.open_quickfix_safety()
              else
                require("quicker").collapse()
                require("quicker").expand({ before = 2, after = 2, add_to_existing = true })
              end
            end,
            desc = "Expand quickfix context",
          },
          {
            "<",
            function()
              local win_info = vim.fn.getwininfo(vim.api.nvim_get_current_win())[1]
              local is_quickfix = win_info and win_info.quickfix == 1
              local is_loclist = win_info and win_info.loclist == 1
              if is_quickfix and not is_loclist then
                vim.cmd("cclose")
                require("quicker").collapse()
                Nvim.Quickfix.open_quickfix_safety()
              else
                require("quicker").collapse()
              end
            end,
            desc = "Collapse quickfix context",
          },
        },
      })
    end
  },
  {
    'ESSO0428/nvim-html-css',
    dependencies = {
      "nvim-lua/plenary.nvim",
      "hrsh7th/nvim-cmp"
    }
  },
  { "godlygeek/tabular" },
  -- { "mbbill/undotree" },
  { "mg979/vim-visual-multi" },
  { "matze/vim-move" },
  { "zirrostig/vim-schlepp" },
  { "theniceboy/antovim" },
  {
    'Wansmer/treesj',
    dependencies = { 'nvim-treesitter/nvim-treesitter' },
    config = function()
      require('treesj').setup({
        use_default_keymaps = false
      })
    end,
  },
  -- { "theniceboy/vim-snippets" },
  -- cmp-nvim-ultisnips 有可能造成補全失效
  -- { "quangnguyen30192/cmp-nvim-ultisnips" },
  { "lfv89/vim-interestingwords" },
  { "Shatur/neovim-session-manager" },
  { "stevearc/dressing.nvim" },
  {
    "folke/flash.nvim",
    event = "VeryLazy",
    ---@type Flash.Config
    opts = {
      config = nil,
      search = {
        mode = "fuzzy"
      },
      modes = {
        char = { enabled = false },
        search = {
          enabled = false
        }
      }
    },
    -- stylua: ignore
    keys = {
      { "<leader>f", mode = { "n", "o", "x" }, function() require("flash").jump() end,       desc = "Flash" },
      { "<leader>F", mode = { "n", "o", "x" }, function() require("flash").treesitter() end, desc = "Flash Treesitter" },
      -- { "r",         mode = "o",               function() require("flash").remote() end,     desc = "Remote Flash" },
      -- {
      --   "R",
      --   mode = { "o", "x" },
      --   function() require("flash").treesitter_search() end,
      --   desc =
      --   "Treesitter Search"
      -- },
      {
        "<a-f>",
        mode = { "c" },
        function() require("flash").toggle() end,
        desc =
        "Toggle Flash Search"
      }
    }
  },
  {
    "rhysd/clever-f.vim",
    config = function()
      vim.keymap.set("n", ";", "<Plug>(clever-f-repeat-forward)", {})
      vim.keymap.set("n", ",", "<Plug>(clever-f-repeat-back)", {})
    end
  },
  {
    "AckslD/nvim-neoclip.lua",
    deprecated = { 'nvim-telescope/telescope.nvim' },
    config = function()
      require('neoclip').setup()
    end,
  },
  { "MunifTanjim/nui.nvim" },
  --[[{ -- core plugin
    "SmiteshP/nvim-navic",
    config = function()
      require("lvim.core.breadcrumbs").setup()
    end,
    event = "User FileOpened",
    enabled = lvim.builtin.breadcrumbs.active
  },--]]
  {
    "SmiteshP/nvim-navbuddy",
    commit = "0db1d62",
    deprecated = {
      "neovim/nvim-lspconfig",
      "SmiteshP/nvim-navic",
      "MunifTanjim/nui.nvim"
    },
    keys = {
      { "<leader>uv", "<cmd>Navbuddy<cr>", desc = "Nav" }
    },
    config = function()
      local actions = require("nvim-navbuddy.actions")
      local navbuddy = require("nvim-navbuddy")
      navbuddy.setup({
        window = {
          border = "double"
        },
        mappings = {
          ["i"] = actions.previous_sibling(),
          ["k"] = actions.next_sibling(),
          ["j"] = actions.parent(),
          ["l"] = actions.children(),
          ["I"] = actions.previous_sibling(),
          ["K"] = actions.next_sibling(),
          ["<a-Up>"] = actions.move_up(),
          ["<a-Down>"] = actions.move_down(),
          ["h"] = actions.insert_name(),
          ["H"] = actions.insert_scope(),
          ["a"] = actions.append_name(),
          ["A"] = actions.append_scope()
        },
        lsp = { auto_attach = true }
      })
    end
  },
  -- { "elijahmanor/export-to-vscode.nvim" },
  -- 已將其代碼自行 copy 到我的 lua dir 下了
  {
    "petertriho/nvim-scrollbar",
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
    "zane-/howdoi.nvim",
    build = 'pip install howdoi'
  },
  {
    "folke/todo-comments.nvim",
    deprecated = "nvim-lua/plenary.nvim",
    config = function()
      --[[ require ]]
      require("todo-comments").setup {
        -- your configuration comes here
        -- or leave it empty to use the default settings
        -- refer to the configuration section below
      }
    end
  },
  { "sindrets/winshift.nvim" },
  { "quangnguyen30192/cmp-nvim-ultisnips" },
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
  { "SirVer/ultisnips" },
  { "ESSO0428/vim-snippets" },
  { "nvim-telescope/telescope-media-files.nvim" },
  {
    "Zane-/cder.nvim",
    -- build = 'cargo install exa'
    build = 'cargo install --list | grep -q "exa v" || cargo install exa'
  },
  {
    "ESSO0428/swenv.nvim",
    config = function()
      require('swenv').setup({
        post_set_venv = function()
          vim.cmd("LspRestart")
        end,
      })
    end
  },
  {
    'Joakker/lua-json5',
    -- if you're on windows
    -- run = 'powershell ./install.ps1'
    build = './install.sh'
  },
  { "nvim-telescope/telescope-dap.nvim" },
  { "ofirgall/goto-breakpoints.nvim" },
  {
    "mfussenegger/nvim-dap-python",
    build = "pip install debugpy"
  },
  { "theHamsta/nvim-dap-virtual-text" },
  { "LiadOz/nvim-dap-repl-highlights" },
  {
    'Weissle/persistent-breakpoints.nvim',
    config = function()
      require('persistent-breakpoints').setup {
        load_breakpoints_event = { "SessionLoadPost" }
      }
    end
  },
  {
    "nvim-neotest/neotest",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "antoinemadec/FixCursorHold.nvim",
      "nvim-treesitter/nvim-treesitter",
      "nvim-neotest/neotest-python",
      "nvim-neotest/nvim-nio"
    }
  },
  { "Davidyz/inlayhint-filler.nvim" },
  {
    "alexpasmantier/pymple.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "MunifTanjim/nui.nvim",
      -- optional (nicer ui)
      "stevearc/dressing.nvim",
      "nvim-tree/nvim-web-devicons",
    },
    -- NOTE: don't use build here, have some bug
    -- use pcall require pymple, when dependency not install,
    -- pymple will jump to `:PympleBuild` warning
    -- just execute `:PympleBuild` to install dependency
    config = function()
      pcall(function()
        --#region require("pymple").setup({})
        require("pymple").setup({
          -- automatically register the following keymaps on plugin setup
          keymaps = {
            -- Resolves import for symbol under cursor.
            -- This will automatically find and add the corresponding import to
            -- the top of the file (below any existing doctsring)
            resolve_import_under_cursor = {
              desc = "Resolve import under cursor",
              keys = "<leader>uL" -- feel free to change this to whatever you like
            }
          },
          -- logging options
          logging = {
            -- whether to log to the neovim console (only use this for debugging
            -- as it might quickly ruin your neovim experience)
            console = {
              enabled = false
            },
            -- whether or not to log to a file (default location is nvim's
            -- stdpath("data")/pymple.vlog which will typically be at
            -- `~/.local/share/nvim/pymple.vlog` on unix systems)
            file = {
              enabled = true,
              -- the maximum number of lines to keep in the log file (pymple will
              -- automatically manage this for you so you don't have to worry about
              -- the log file getting too big)
              max_lines = 1000,
              path = vim.fn.stdpath("data") .. "/pymple.vlog",
            },
            -- the log level to use
            -- (one of "trace", "debug", "info", "warn", "error", "fatal")
            level = "info"
          },
          -- python options
          python = {
            -- the names of root markers to look out for when discovering a project
            root_markers = {
              "pyproject.toml",
              "setup.py",
              ".git",
              "manage.py",
              "requirements.txt",
              "setup.cfg",
              "Pipfile",
              "pyrightconfig.json",
            },
            -- the names of virtual environment folders to look out for when
            -- discovering a project
            virtual_env_names = { ".venv" }
          }
        })
        --#endregion
      end)
    end,
  },
  {
    "aca/emmet-ls",
    config = function()
      local lspconfig = require("lspconfig")
      local configs = require("lspconfig/configs")

      local capabilities = vim.lsp.protocol.make_client_capabilities()
      capabilities.textDocument.completion.completionItem.snippetSupport = true
      capabilities.textDocument.completion.completionItem.resolveSupport = {
        properties = {
          "documentation",
          "detail",
          "additionalTextEdits"
        },
      }

      if not lspconfig.emmet_ls then
        configs.emmet_ls = {
          default_config = {
            cmd = { "emmet-ls", "--stdio" },
            filetypes = {
              "html",
              "css",
              "javascript",
              "typescript",
              "eruby",
              "typescriptreact",
              "javascriptreact",
              "svelte",
              "vue"
            },
            root_dir = function(fname)
              return vim.loop.cwd()
            end,
            settings = {}
          }
        }
      end
      lspconfig.emmet_ls.setup({ capabilities = capabilities })
    end
  },
  {
    "luckasRanarison/tailwind-tools.nvim",
    dependencies = { "nvim-treesitter/nvim-treesitter" },
    opts = {
      document_color = {
        enabled = true, -- can be toggled by commands
        kind = "foreground", -- "inline" | "foreground" | "background"
        inline_symbol = "󰝤 ", -- only used in inline mode
        debounce = 200, -- in milliseconds, only applied in insert mode
      },
      conceal = {
        enabled = false, -- can be toggled by commands
        symbol = "󱏿", -- only a single character is allowed
        highlight = { -- extmark highlight options, see :h 'highlight'
          fg = "#38BDF8",
        },
      },
      custom_filetypes = {} -- see the extension section to learn how it works
    }
  },
  { "nvim-lua/popup.nvim" },
  {
    "iamcco/markdown-preview.nvim",
    build = "cd app && npm install",
    ft = "markdown",
    config = function()
      vim.g.mkdp_auto_start = 1
    end
  },
  -- NOTE: The handling of `concealcursor` in LSP hover markdown rendering
  -- was changed after commit 0022a57. The previous behavior allowed
  -- concealed elements to be visible, but the new version hides them
  -- by default.
  -- If you prefer the old behavior in LSP hover windows, check issue #312
  -- for possible workarounds: [#312](https://github.com/MeanderingProgrammer/render-markdown.nvim/issues/312)
  {
    'MeanderingProgrammer/markdown.nvim',
    main = "render-markdown",
    opts = {},
    name = 'render-markdown', -- Only needed if you have another plugin named markdown.nvim
    -- dependencies = { 'nvim-treesitter/nvim-treesitter', 'echasnovski/mini.nvim' }, -- if you use the mini.nvim suite
    -- dependencies = { 'nvim-treesitter/nvim-treesitter', 'echasnovski/mini.icons' }, -- if you use standalone mini plugins
    dependencies = { 'nvim-treesitter/nvim-treesitter', 'nvim-tree/nvim-web-devicons' }, -- if you prefer nvim-web-devicons
    config = function()
      vim.g.MarkdownNvim = 1
      vim.treesitter.language.register('markdown', 'copilot-chat')
      vim.treesitter.language.register('markdown', 'AvanteInput')
      require('render-markdown').setup({
        file_types = { 'markdown', 'copilot-chat', 'Avante', 'AvanteInput' },
        overrides = {
          buftype = {
            nofile = {
              win_options = {
                conceallevel = {
                  default = 0,
                  rendered = 2,
                },
                concealcursor = {
                  default = 'nvic',
                  rendered = 'nvic',
                },
              },
            },
          },
        },
        heading = {
          sign = false,
          icons = { " ◉ ", " ○ ", " ✸ ", " ✿ ", " ◉ ", " ○ " },
        },
        quote = {
          -- Turn on / off block quote & callout rendering
          enabled = true,
          -- Replaces '>' of 'block_quote'
          icon = '▋',
          -- Highlight for the quote icon
          highlight = 'RenderMarkdownQuote',
        },
        code = {
          sign = false,
          border = "thick",
          highlight = 'RenderMarkdownCode',
          highlight_inline = '',
        },
        bullet = {
          icons = { '●', '○', '◆', '◇' },
          -- Padding to add to the right of bullet point
          right_pad = 0,
          -- Highlight for the bullet icon
          -- highlight = 'RenderMarkdownBullet',
          highlight = 'Identifier'
        },
        html = {
          -- Turn on / off all HTML rendering
          enabled = true,
          comment = {
            -- Turn on / off HTML comment concealing
            conceal = false,
            -- Optional text to inline before the concealed comment
            text = nil,
            -- Highlight for the inlined text
            highlight = 'RenderMarkdownHtmlComment',
          },
        },
        win_options = {
          -- See :h 'conceallevel'
          conceallevel = {
            -- Used when not being rendered, get user setting
            default = 0,
            -- Used when being rendered, concealed text is completely hidden
            rendered = 2,
          },
        },
        link = {
          -- Turn on / off inline link icon rendering
          enabled = true,
          -- Inlined with 'image' elements
          image = '󰥶 ',
          -- Inlined with 'email_autolink' elements
          email = '󰀓 ',
          -- Fallback icon for 'inline_link' elements
          hyperlink = '󰌹 ',
          -- Applies to the fallback inlined icon
          highlight = 'RenderMarkdownLink',
          -- Applies to WikiLink elements
          wiki = { icon = '󱗖 ', highlight = 'RenderMarkdownWikiLink' },
          -- Define custom destination patterns so icons can quickly inform you of what a link
          -- contains. Applies to 'inline_link' and wikilink nodes.
          -- Can specify as many additional values as you like following the 'web' pattern below
          --   The key in this case 'web' is for healthcheck and to allow users to change its values
          --   'pattern':   Matched against the destination text see :h lua-pattern
          --   'icon':      Gets inlined before the link text
          --   'highlight': Highlight for the 'icon'
          custom = {
            web = { pattern = '^http[s]?://', icon = '󰖟 ', highlight = 'RenderMarkdownLink' },
          },
        },
        callout = {
          note = { raw = '[!NOTE]', rendered = '󰋽 Note', highlight = 'RenderMarkdownInfo' },
          tip = { raw = '[!TIP]', rendered = '󰌶 Tip', highlight = 'RenderMarkdownSuccess' },
          important = { raw = '[!IMPORTANT]', rendered = '󰅾 Important', highlight = 'Identifier' },
          warning = { raw = '[!WARNING]', rendered = '󰀪 Warning', highlight = 'RenderMarkdownWarn' },
          caution = { raw = '[!CAUTION]', rendered = '󰳦 Caution', highlight = 'RenderMarkdownError' },
          -- Obsidian: https://help.a.md/Editing+and+formatting/Callouts
          abstract = { raw = '[!ABSTRACT]', rendered = '󰨸 Abstract', highlight = 'RenderMarkdownInfo' },
          todo = { raw = '[!TODO]', rendered = '󰗡 Todo', highlight = 'RenderMarkdownInfo' },
          success = { raw = '[!SUCCESS]', rendered = '󰄬 Success', highlight = 'RenderMarkdownSuccess' },
          question = { raw = '[!QUESTION]', rendered = '󰘥 Question', highlight = 'RenderMarkdownWarn' },
          failure = { raw = '[!FAILURE]', rendered = '󰅖 Failure', highlight = 'RenderMarkdownError' },
          danger = { raw = '[!DANGER]', rendered = '󱐌 Danger', highlight = 'RenderMarkdownError' },
          bug = { raw = '[!BUG]', rendered = '󰨰 Bug', highlight = 'RenderMarkdownError' },
          example = { raw = '[!EXAMPLE]', rendered = '󰉹 Example', highlight = 'RenderMarkdownHint' },
          quote = { raw = '[!QUOTE]', rendered = '󱆨 Quote', highlight = 'RenderMarkdownQuote' },
        },
      })
    end
  },
  {
    "aznhe21/actions-preview.nvim",
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
    'kosayoda/nvim-lightbulb',
    opts = require("user.config.plugins.nvim_lightbulb").opt,
  },
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
    "roobert/hoversplit.nvim",
    config = function()
      require("hoversplit").setup({
        key_bindings = {
          -- sgh keymap 為我常用的但在這可能無效，
          -- 因此後面 lsp.lua 會再重設一次
          split_remain_focused = "sgh",
          -- 設定無效按鍵 <C-space> 以取消默認的 keymap
          split = "<C-space>",
          vsplit = "<C-space>",
        }
      })
    end
  },
  {
    "hedyhli/outline.nvim",
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
    "danymat/neogen",
    dependencies = "nvim-treesitter/nvim-treesitter",
    config = true,
    -- Uncomment next line if you want to follow only stable versions
    -- version = "*"
  },
  {
    "ESSO0428/md-headers.nvim",
    deprecated = { 'nvim-lua/plenary.nvim' }
  },
  { "ESSO0428/mkdnflow.nvim", },
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
    lazy = true,
  },
  { "dhruvasagar/vim-table-mode" },
  {
    "miversen33/netman.nvim"
  },
  {
    "s1n7ax/nvim-window-picker",
    version = "2.*",
    config = function()
      require("window-picker").setup({
        -- type of hints you want to get
        -- following types are supported
        -- 'statusline-winbar' | 'floating-big-letter'
        -- 'statusline-winbar' draw on 'statusline' if possible, if not 'winbar' will be
        -- 'floating-big-letter' draw big letter on a floating window
        -- used
        hint = 'statusline-winbar',
        filter_rules = {
          include_current_win = false,
          autoselect_one = true,
          -- filter using buffer options
          bo = {
            -- if the file type is one of following, the window will be ignored
            filetype = { "NvimTree", "neo-tree", "neo-tree-popup", "notify", "Outline" },
            -- if the buffer type is one of following, the window will be ignored
            buftype = { "terminal", "quickfix" },
          },
        },
      })
    end,
  },
  {
    "nvim-neo-tree/neo-tree.nvim",
    branch = "v3.x",
    deprecated = {
      "miversen33/netman.nvim",
      "nvim-lua/plenary.nvim",
      "nvim-tree/nvim-web-devicons", -- not strictly required, but recommended
      "MunifTanjim/nui.nvim",
      "s1n7ax/nvim-window-picker",
    }
  },
  {
    'nyngwang/NeoZoom.lua',
    config = function()
      require('neo-zoom').setup {
        winopts = {
          offset = {
            -- NOTE: you can omit `top` and/or `left` to center the floating window.
            -- top = 0,
            -- left = 0.17,
            width = 150,
            height = 0.85,
          },
          -- NOTE: check :help nvim_open_win() for possible border values.
          -- border = 'double',
        },
        -- exclude_filetypes = { 'lspinfo', 'mason', 'lazy', 'fzf', 'qf' },
        exclude_buftypes = { 'terminal' },
        presets = {
          {
            filetypes = { 'dapui_.*', 'dap-repl' },
            config = {
              top = 0.25,
              left = 0.6,
              width = 0.4,
              height = 0.65,
            },
            callbacks = {
              function() vim.wo.wrap = true end
            }
          }
        },
        -- popup = {
        --   -- NOTE: Add popup-effect (replace the window on-zoom with a `[No Name]`).
        --   -- This way you won't see two windows of the same buffer
        --   -- got updated at the same time.
        --   enabled = true,
        --   exclude_filetypes = {},
        --   exclude_buftypes = {},
        -- },
      }
      vim.keymap.set('n', '<leader>tb', function() vim.cmd('NeoZoomToggle') end, { silent = true, nowait = true })
    end
  },
  -- {
  -- "folke/twilight.nvim",
  -- config = function()
  -- NOTE: dims `inactive` portions of the code you're editing
  -- vim.keymap.set("n", "<leader>ta", "<cmd>Twilight<cr>")
  -- end
  -- },
  {
    "ESSO0428/limelight.vim"
  },
  {
    "princejoogie/chafa.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "m00qek/baleia.nvim"
    }
  },
  -- { "tpope/vim-fugitive" },
  { "ESSO0428/vim-fugitive" },
  { "rbong/vim-flog" },
  { "sindrets/diffview.nvim" },
  {
    "kiyoon/jupynium.nvim",
    build = "pip install --user .",
    -- NOTE: The following steps ensure the installation of the latest version of Firefox.
    -- By installing it in the user directory, we can avoid conflicts with the default Firefox version on the server.
    -- 1. Navigate to your bin directory:
    --    cd ~/bin/
    -- 2. Download the latest Firefox version:
    --    wget https://download.mozilla.org/?product=firefox-latest-ssl&os=linux64&lang=en-US -O firefox.tar.bz2
    -- 3. Extract the downloaded file:
    --    tar xjf firefox.tar.bz2
    -- 4. In your shell configuration file (e.g., ~/.bashrc), add the following lines to set the path and browser environment variables:
    --    export PATH=$HOME/bin/firefox:$PATH
    --    export BROWSER=$HOME/bin/firefox/firefox
    -- NOTE: Ensure that geckodriver is installed and up-to-date, or this plugin will not work.
    -- To check, run: geckodriver --version
    -- If not installed or the version is outdated, you can download it with:
    --    npm install -g geckodriver
    -- NOTE: To avoid excessive delay in rendering Firefox via remote X11 forwarding, use ssh -Y -C instead of ssh -Y.
    -- The -C option enables compression, which can significantly improve rendering speed.
    -- NOTE: The current package only supports up to Jupyter Notebook version 6 and does not support version 7.
    -- If `jupyter notebook --version` returns version 7, you can install the classic mode with:
    --    pip install --upgrade notebook nbclassic
    -- To open the notebook, use `jupyter nbclassic` for version 7, or `jupyter notebook` for version 6.
    -- Optionally, to avoid opening an additional Firefox window, you can use the `--no-browser` option:
    --    jupyter nbclassic --no-browser  # for version 7
    --    jupyter notebook --no-browser  # for version 6
    -- After running, execute `JupyniumStartAndAttachToServer` in the .py file you want to sync.
    -- Once the browser connection is successfully established, run `JupyniumStartSync`.
    -- This will convert the .py file to Untitled.ipynb, and you can synchronously write and execute the .ipynb file in the browser from Neovim.
    -- NOTE: It is recommended to set a password using `jupyter notebook password` or `jupyter nbclassic password` to prevent unauthorized access.
    -- For root users, use `jupyter notebook --allow-root` or `jupyter nbclassic --allow-root` to open the notebook.
    opts = {
      default_notebook_URL = "localhost:8888/nbclassic",
      syntax_highlight = {
        enable = false,
      },
      use_default_keybindings = false,
      textobjects = {
        use_default_keybindings = false,
      },
    },
  },
  {
    "ESSO0428/jupyter-kernel.nvim",
    opts = {
      inspect = {
        -- opts for vim.lsp.util.open_floating_preview
        window = {
          max_width = 84,
        },
      },
      -- time to wait for kernel's response in seconds
      timeout = 0.5
    },
    cmd = { "JupyterAttach", "JupyterInspect", "JupyterExecute" },
    build = { "pip install -U pynvim jupyter_client", ":UpdateRemotePlugins" },
    keys = {
      -- { "<leader><a-s>", "<Cmd>JupyterInspect<cr>", desc = "Inspect object in kernel" },
      { "<leader>gh", "<Cmd>JupyterInspect<cr>", desc = "Inspect object in kernel" }
    }
  }
}
