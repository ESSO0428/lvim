lvim.plugins = {
  {
    "folke/trouble.nvim",
    cmd = "TroubleToggle"
  },
  { "skywind3000/asyncrun.vim" },
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
        end
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

      vim.notify = notify
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
      vim.keymap.set("n", "<leader>Tc", "<cmd>lua CellularAutomaton_make_it_rain()<CR>")
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
            highlight! semshiImported gui=bold guifg=#4ec9b0
            highlight! semshiGlobal gui=bold
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
    "NvChad/nvim-colorizer.lua",
    opts = {
      user_default_options = {
        mode = "virtualtext",
        tailwind = true
      }
    }
  },
  {
    'rmagatti/goto-preview',
    config = function()
      require('goto-preview').setup {}
    end
  },
  {
    "amrbashir/nvim-docs-view",
    config = function()
      require("docs-view").setup {
        position = "bottom",
        width = 60,
      }
      vim.keymap.set("n", "<leader>th", "<cmd>DocsViewToggle<CR>")
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
    "ESSO0428/NotebookNavigator.nvim",
    keys = {
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
  { "ESSO0428/bookmarks.nvim" },
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
        ensure_installed = { 'org' },
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
  { "f3fora/cmp-spell" },
  { "rcarriga/cmp-dap" },
  {
    "github/copilot.vim",
    commit = "7097b09"
  },
  { "hrsh7th/cmp-copilot" },
  {
    "CopilotC-Nvim/CopilotChat.nvim",
    branch = "canary",
    dependencies = {
      { "github/copilot.vim" },    -- or github/copilot.vim
      { "nvim-lua/plenary.nvim" }, -- for curl, log wrapper
    },
    opts = {
      debug = true, -- Enable debugging
      -- See Configuration section for rest
    },
    -- See Commands section for default commands if you want to lazy load on them
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
    event = { "BufRead", "BufNew" },
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
  -- {
  --   "tzachar/cmp-tabnine",
  --   run = "./install.sh",
  --   requires = "hrsh7th/nvim-cmp",
  --   event = "InsertEnter",
  -- },
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
  -- core plug : but too old (so change me control)
  {
    "SmiteshP/nvim-navic",
    commit = "27124a7",
    config = function()
      require("lvim.core.breadcrumbs").setup()
    end,
    event = "User FileOpened",
    enabled = lvim.builtin.breadcrumbs.active
  },
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
    event = "BufRead",
    config = function()
      require "lsp_signature".on_attach()
      require "lsp_signature".setup({
        bind = true, -- This is mandatory, otherwise border config won't get registered.
        handler_opts = {
          border = "rounded"
        }
      })
    end
  },
  { "SirVer/ultisnips" },
  { "theniceboy/vim-snippets" },
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
  { "nvim-telescope/telescope-dap.nvim" },
  { "ofirgall/goto-breakpoints.nvim" },
  {
    "mfussenegger/nvim-dap-python",
    build = "pip install debugpy"
  },
  { "theHamsta/nvim-dap-virtual-text" },
  { "LiadOz/nvim-dap-repl-highlights" },
  {
    'ESSO0428/persistent-breakpoints.nvim',
    config = function()
      require('persistent-breakpoints').setup {
        load_breakpoints_event = { "BufReadPost" }
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
  { "stevanmilic/nvim-lspimport" },
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
  {
    'laytan/tailwind-sorter.nvim',
    dependencies = { 'nvim-treesitter/nvim-treesitter', 'nvim-lua/plenary.nvim' },
    build = 'cd formatter && npm ci && npm run build',
    config = true
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
        enable = true,
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
      require("hoversplit").setup()
    end
  },
  {
    "hedyhli/outline.nvim",
    config = function()
      -- Example mapping to toggle outline
      vim.keymap.set("n", "<leader>o", "<cmd>Outline<CR>",
        { desc = "Toggle Outline" })

      require("outline").setup {
        -- Your setup opts here (leave empty to use defaults)
        preview_window = {
          auto_preview = true,
        }
      }
    end,
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
    "DougBeney/pickachu",
    build = 'pip install Zenity'
  },
  { "dhruvasagar/vim-table-mode" },
  {
    "miversen33/netman.nvim"
  },
  {
    "nvim-neo-tree/neo-tree.nvim",
    branch = "v3.x",
    deprecated = {
      "miversen33/netman.nvim",
      "nvim-lua/plenary.nvim",
      "nvim-tree/nvim-web-devicons", -- not strictly required, but recommended
      "MunifTanjim/nui.nvim"
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
  -- vim.keymap.set("n", "<leader>ta", "<cmd>Twilight<CR>")
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
      -- { "<leader><a-s>", "<Cmd>JupyterInspect<CR>", desc = "Inspect object in kernel" },
      { "<leader>gh", "<Cmd>JupyterInspect<CR>", desc = "Inspect object in kernel" }
    }
  },
}
