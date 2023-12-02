lvim.plugins = {
  {
    "folke/trouble.nvim",
    cmd = "TroubleToggle",
  },
  { "skywind3000/asyncrun.vim" },
  { "kevinhwang91/rnvimr" },
  {
    "kevinhwang91/nvim-hlslens",
    config = function()
      require('hlslens').setup({})
    end
  },
  {
    "keaising/im-select.nvim",
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
          default_im_select       = "com.apple.keylayout.ABC",

          -- Can be binary's name or binary's full path,
          -- e.g. 'im-select' or '/usr/local/bin/im-select'
          -- For Windows/WSL, default: "im-select.exe"
          -- For macOS, default: "im-select"
          -- For Linux, default: "fcitx5-remote" or "fcitx-remote" or "ibus"
          default_command         = 'im-select.exe',

          -- Restore the default input method state when the following events are triggered
          -- set_default_events      = { "VimEnter", "FocusGained", "InsertLeave", "CmdlineLeave" },
          set_default_events      = { "VimEnter", "FocusGained", "InsertLeave" },

          -- Restore the previous used input method state when the following events
          -- are triggered, if you don't want to restore previous used im in Insert mode,
          -- e.g. deprecated `disable_auto_restore = 1`, just let it empty
          -- as `set_previous_events = {}`
          set_previous_events     = { "InsertEnter" },

          -- Show notification about how to install executable binary when binary missed
          keep_quiet_on_no_binary = false,

          -- Async run `default_command` to switch IM or not
          async_switch_im         = true
        })
      end
    end,
  },
  {
    "LukasPietzschmann/telescope-tabs",
    config = function()
      require("telescope-tabs").setup {
        entry_formatter = function(tab_id, buffer_ids, file_names, file_paths, is_current)
          if vim.g.Tabline_session_data == nil then
            return
          end
          local TablineData = vim.fn.json_decode(vim.g.Tabline_session_data)

          local tab_name = TablineData[tab_id].name
          -- require("tabby.feature.tab_name").get(tab_id)
          -- return string.format("%d: %s%s", tab_id, tab_id, is_current and " <" or "")
          local entry_string = table.concat(file_names, ', ')
          return string.format('%d [%s]: %s%s', tab_id, tab_name, entry_string, is_current and ' <' or '')
        end,
        entry_ordinal = function(tab_id, buffer_ids, file_names, file_paths, is_current)
          -- return table.concat(file_names, ' ')
          if vim.g.Tabline_session_data == nil then
            return
          end
          local TablineData = vim.fn.json_decode(vim.g.Tabline_session_data)

          -- return TablineData[tab_id].name
          local entry_string = table.concat(file_names, ', ')
          return string.format('%d %s %s', tab_id, TablineData[tab_id].name, entry_string)
          -- require("tabby.feature.tab_name").get(tab_id)
        end
      }
    end
  },
  {
    'kdheepak/tabline.nvim',
    config = function()
      require 'tabline'.setup {
        enable = false,
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
        level = "TRACE",
      })

      vim.notify = notify
    end,
  },
  {
    'linrongbin16/lsp-progress.nvim',
    dependencies = { 'nvim-tree/nvim-web-devicons' },
    config = function()
      require('lsp-progress').setup()
    end
  },
  { "kazhala/close-buffers.nvim" },
  {
    "AckslD/muren.nvim",
    config = true,
  },
  { "ESSO0428/calc.vim" },
  { "ESSO0428/bioSyntax-vim" },
  {
    "wookayin/semshi",
    build = ":UpdateRemotePlugins",
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
    'rmagatti/goto-preview',
    config = function()
      require('goto-preview').setup {}
    end
  },
  {
    "GCBallesteros/NotebookNavigator.nvim",
    keys = {
      { "]h",        function() require("notebook-navigator").move_cell "d" end },
      { "[h",        function() require("notebook-navigator").move_cell "u" end },
      { "<leader>X", "<cmd>lua require('notebook-navigator').run_cell()<cr>" },
      { "<leader>x", "<cmd>lua require('notebook-navigator').run_and_move()<cr>" },
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
          move_up = "i",
          move_down = "k",
          add_cell_before = "a",
          add_cell_after = "b",
        },
        repl_provider = "iron",
      })
    end,
  },
  {
    "echasnovski/mini.ai",
    event = "VeryLazy",
    dependencies = { "GCBallesteros/NotebookNavigator.nvim" },
    opts = function()
      local nn = require "notebook-navigator"

      local opts = { custom_textobjects = { h = nn.miniai_spec } }
      return opts
    end,
  },
  {
    "echasnovski/mini.hipatterns",
    event = "VeryLazy",
    dependencies = { "GCBallesteros/NotebookNavigator.nvim" },
    opts = function()
      local nn = require "notebook-navigator"

      local opts = { highlighters = { cells = nn.minihipatterns_spec } }
      return opts
    end,
  },
  { "jbyuki/venn.nvim" },
  { "ESSO0428/bookmarks.nvim" },
  { "tpope/vim-dadbod" },
  { "kristijanhusak/vim-dadbod-ui" },
  { "kristijanhusak/vim-dadbod-completion" },
  { "LinArcX/telescope-command-palette.nvim" },
  { "nvim-telescope/telescope-live-grep-args.nvim" },
  {
    "nvim-telescope/telescope-file-browser.nvim",
    dependencies = { "nvim-telescope/telescope.nvim", "nvim-lua/plenary.nvim" }
  },
  {
    "nvim-orgmode/orgmode",
    branch = "master",
    ft = { "org" },
    build = ":lua require('orgmode').setup_ts_grammar()",
    config = function()
      require("orgmode").setup {}
    end,
  },
  {
    'akinsho/org-bullets.nvim',
    ft = { "org" },
    config = function()
      require('org-bullets').setup()
    end
  },
  -- {
  --   'ESSO0428/org-bullets-markdown.nvim',
  --   ft = { "markdown" },
  --   config = function()
  --     require('org-bullets-markdown').setup()
  --   end
  -- },
  {
    'lukas-reineke/headlines.nvim',
    dependencies = "nvim-treesitter/nvim-treesitter",
    config = true, -- or `opts = {}`
  },
  {
    "joaomsa/telescope-orgmode.nvim"
  },
  {
    "karb94/neoscroll.nvim",
    event = "WinScrolled",
    config = function()
      require('neoscroll').setup({
        -- All these keys will be mapped to their corresponding default scrolling animation
        -- mappings = { '<C-u>', '<C-d>', '<C-b>', '<C-f>',
        --   '<C-y>', '<C-e>', 'zt', 'zz', 'zb' },
        mappings = {},
        hide_cursor = true,          -- Hide cursor while scrolling
        stop_eof = true,             -- Stop at <EOF> when scrolling downwards
        use_local_scrolloff = false, -- Use the local scope of scrolloff instead of the global scope
        respect_scrolloff = false,   -- Stop scrolling when the cursor reaches the scrolloff margin of the file
        cursor_scrolls_alone = true, -- The cursor will keep on scrolling even if the window cannot scroll further
        easing_function = nil,       -- Default easing function
        pre_hook = nil,              -- Function to run before the scrolling animation starts
        post_hook = nil,             -- Function to run after the scrolling animation ends
      })
    end
  },
  -- { "hrsh7th/cmp-vsnip" },
  -- { "hrsh7th/vim-vsnip" },
  {
    "github/copilot.vim",
  },
  { "f3fora/cmp-spell" },
  {
    "hrsh7th/cmp-copilot",
    -- config = function()
    --   lvim.builtin.cmp.formatting.source_names["copilot"] = "( )"
    --   table.insert(lvim.builtin.cmp.sources, 2, { name = "copilot" })
    -- end,
  },
  -- { "HiPhish/nvim-ts-rainbow2" },
  { "HiPhish/rainbow-delimiters.nvim" },
  -- { "p00f/nvim-ts-rainbow" },
  {
    "nvim-treesitter/playground",
    event = "BufRead",
  },
  {
    "romgrk/nvim-treesitter-context",
    config = function()
      require("treesitter-context").setup {
        enable = true,   -- Enable this plugin (Can be enabled/disabled later via commands)
        throttle = true, -- Throttles plugin updates (may improve performance)
        max_lines = 0,   -- How many lines the window should span. Values <= 0 mean no limit.
        patterns = {
          -- Match patterns for TS nodes. These get wrapped to match at word boundaries.
          -- For all filetypes
          -- Note that setting an entry here replaces all other patterns for this entry.
          -- By setting the 'default' entry below, you can control which nodes you want to
          -- appear in the context window.
          default = {
            'class',
            'function',
            'method',
          },
        },
      }
    end
  },
  {
    "windwp/nvim-ts-autotag",
    config = function()
      require("nvim-ts-autotag").setup()
    end,
  },
  { "kevinhwang91/promise-async" },
  {
    'kevinhwang91/nvim-ufo',
    deprecated = { 'kevinhwang91/promise-async' },
  },
  -- { "tmhedberg/SimpylFold" },
  -- { "Konfekt/FastFold" },
  {
    "simrat39/symbols-outline.nvim",
    config = function()
      require('symbols-outline').setup()
    end
  },
  { "EdenEast/nightfox.nvim" },
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
          border_chars = { "┃", "┃", "━", "━", "┏", "┓", "┗", "┛", "█" },
        },
        func_map = {
          vsplit = "",
          ptogglemode = "z,",
          stoggleup = "",
        },
        filter = {
          fzf = {
            action_for = { ["ctrl-s"] = "split" },
            extra_opts = { "--bind", "ctrl-o:toggle-all", "--prompt", "> " },
          },
        },
      })
    end,
  },
  -- {
  --   "tzachar/cmp-tabnine",
  --   run = "./install.sh",
  --   requires = "hrsh7th/nvim-cmp",
  --   event = "InsertEnter",
  -- },
  {
    'ESSO0428/nvim-html-css',
    -- dependencies = { 'nvim-treesitter/nvim-treesitter' },
    -- commit = '6f256a5',
    dependencies = {
      "nvim-lua/plenary.nvim",
      "hrsh7th/nvim-cmp"
    },
    event = { "VeryLazy" },
    config = function()
      if vim.fn.getcwd() ~= vim.fn.expand("$HOME") then
        require("html-css"):setup()
      end
    end
    -- init = function()
    --   require('html-css'):setup()
    -- end,
  },
  { "junegunn/vim-peekaboo" },
  { "godlygeek/tabular" },
  -- { "mbbill/undotree" },
  { "mg979/vim-visual-multi" },
  { "matze/vim-move" },
  { "theniceboy/antovim" },
  -- { "theniceboy/vim-snippets" },
  -- cmp-nvim-ultisnips 有可能造成補全失效
  -- { "quangnguyen30192/cmp-nvim-ultisnips" },
  { "lfv89/vim-interestingwords" },
  { "Shatur/neovim-session-manager" },
  { "stevearc/dressing.nvim",
  },
  -- { "ggandor/leap.nvim" },
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
      },
    },
  },
  { "rhysd/clever-f.vim" },
  {
    "AckslD/nvim-neoclip.lua",
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
    enabled = lvim.builtin.breadcrumbs.active,
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
      { "<leader>uv", "<cmd>Navbuddy<cr>", desc = "Nav" },
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
          ["A"] = actions.append_scope(),
        },
        lsp = { auto_attach = true }
      })
    end
  },
  -- { "elijahmanor/export-to-vscode.nvim" },
  -- 已將其代碼自行 copy 到我的 lua dir 下了
  { "petertriho/nvim-scrollbar" },
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
    end,
  },
  { "SirVer/ultisnips" },
  { "theniceboy/vim-snippets" },
  { "nvim-telescope/telescope-media-files.nvim" },
  {
    "Zane-/cder.nvim",
    -- build = 'cargo install exa'
    build = 'cargo install --list | grep -q "exa v" || cargo install exa'
  },
  { "IllustratedMan-code/telescope-conda.nvim" },
  { "nvim-telescope/telescope-dap.nvim" },
  { "ofirgall/goto-breakpoints.nvim" },
  {
    "mfussenegger/nvim-dap-python",
    build = "pip install debugpy"
  },
  { "theHamsta/nvim-dap-virtual-text" },
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
          "additionalTextEdits",
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
              "vue",
            },
            root_dir = function(fname)
              return vim.loop.cwd()
            end,
            settings = {},
          },
        }
      end
      lspconfig.emmet_ls.setup({ capabilities = capabilities })
    end,
  },
  { "nvim-lua/popup.nvim" },
  {
    "RishabhRD/lspactions",
    commit = "0ea962f",
  },
  {
    "iamcco/markdown-preview.nvim",
    build = "cd app && npm install",
    ft = "markdown",
    config = function()
      vim.g.mkdp_auto_start = 1
    end,
  },
  {
    "glepnir/lspsaga.nvim",
    branch = "main",
    commit = "4f07545",
    event = "LspAttach",
    opts = {
      finder = {
        max_height = 0.5,
        min_width = 30,
        force_max_height = false,
        keys = {
          jump_to = 'l',
          expand_or_jump = '<cr>',
          vsplit = '<a-l>',
          split = '<a-k>',
          tabe = 't',
          tabnew = 'r',
          quit = { 'q', '<ESC>' },
          close_in_preview = '<ESC>',
        },
      },
      outline = {
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
          expand_or_jump = '<cr>',
          quit = "q",
        },
      },
      symbol_in_winbar = {
        enable = false,
        separator = " ",
        ignore_patterns = {},
        hide_keyword = true,
        show_file = true,
        folder_level = 2,
        respect_root = false,
        color_mode = true,
      },
      lightbulb = {
        enable = true,
        enable_in_insert = true,
        sign = true,
        sign_priority = 40,
        virtual_text = false,
      },
    },
    deprecated = {
      { "nvim-tree/nvim-web-devicons" },
      --Please make sure you install markdown and markdown_inline parser
      { "nvim-treesitter/nvim-treesitter" }
    },
  },
  {
    "roobert/hoversplit.nvim",
    config = function()
      require("hoversplit").setup({
        key_bindings = {
          split = "<leader>tgh",
          vsplit = "<leader>tvgh",
        },
      })
    end,
  },
  {
    "ESSO0428/md-headers.nvim",
    deprecated = { 'nvim-lua/plenary.nvim' }
  },
  {
    "ESSO0428/mkdnflow.nvim",
  },
  {
    "DougBeney/pickachu",
    build = 'pip install Zenity'
  },
  { "dhruvasagar/vim-table-mode" },
  {
    "miversen33/netman.nvim",
  },
  {
    "nvim-neo-tree/neo-tree.nvim",
    branch = "v2.x",
    deprecated = {
      "miversen33/netman.nvim",
      "nvim-lua/plenary.nvim",
      "nvim-tree/nvim-web-devicons", -- not strictly required, but recommended
      "MunifTanjim/nui.nvim",
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
              function() vim.wo.wrap = true end,
            },
          },
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
  {
    "princejoogie/chafa.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "m00qek/baleia.nvim"
    },
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
      timeout = 0.5,
    },
    cmd = { "JupyterAttach", "JupyterInspect", "JupyterExecute" },
    build = { "pip install -U pynvim jupyter_client", ":UpdateRemotePlugins" },
    keys = {
      -- { "<leader><a-s>", "<Cmd>JupyterInspect<CR>", desc = "Inspect object in kernel" },
      { "<leader>gh", "<Cmd>JupyterInspect<CR>", desc = "Inspect object in kernel" },
    }
  },
}
