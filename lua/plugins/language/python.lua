return {
  { "GCBallesteros/jupytext.vim" },
  {
    "ESSO0428/swenv.nvim",
    ft = "python",
    config = function()
      require('swenv').setup({
        post_set_venv = function()
          local client = vim.lsp.get_clients({ name = "basedpyright" })[1]
          if not client then
            return
          end
          local venv = require("swenv.api").get_current_venv()
          if not venv then
            return
          end
          local venv_python = venv.path .. "/bin/python"
          if client.settings then
            client.settings = vim.tbl_deep_extend("force", client.settings, { python = { pythonPath = venv_python } })
          else
            client.config.settings =
                vim.tbl_deep_extend("force", client.config.settings, { python = { pythonPath = venv_python } })
          end
          client.notify("workspace/didChangeConfiguration", { settings = nil })
        end,
      })
    end
  },
  {
    "alexpasmantier/pymple.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "MunifTanjim/nui.nvim",
      -- optional (nicer ui)
      "stevearc/dressing.nvim",
      "nvim-tree/nvim-web-devicons",
    },
    ft = { "NvimTree", "neo-tree", "Oil", "minifiles" },
    -- NOTE: don't use build here, have some bug
    -- use pcall require pymple, when dependency not install,
    -- pymple will jump to `:PympleBuild` warning
    -- just execute `:PympleBuild` to install dependency
    build = ":PympleBuild",
    config = function()
      --#region require("pymple").setup({})
      require("pymple").setup({
        -- options for the update imports feature
        update_imports = {
          -- the filetypes on which to run the update imports command
          -- NOTE: this should at least include "python" for the plugin to
          -- actually do anything useful
          filetypes = { "python", "markdown" }
        },
        -- options for the add import for symbol under cursor feature
        add_import_to_buf = {
          -- whether to autosave the buffer after adding the import (which will
          -- automatically format/sort the imports if you have on-save autocommands)
          autosave = true
        },
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
    end,
    keys = {
      { "<leader>uL", function() require('pymple.api').resolve_import_under_cursor() end, desc = "Resolve import under cursor" },
    }
  },
  {
    "ESSO0428/NotebookNavigator.nvim",
    ft = "python",
    keys = {
      { "gi", function() require("notebook-navigator").move_cell "u" end },
      { "gk", function() require("notebook-navigator").move_cell "d" end },
      { "[e", function() require("notebook-navigator").run_cells_above "" end },
      { "]e", function() require("notebook-navigator").run_cells_below "" end },
    },
    dependencies = {
      "echasnovski/mini.comment",
      -- "akinsho/toggleterm.nvim", -- alternative repl provider
      -- "nvimtools/hydra.nvim", -- we had setup hydra separately
      "echasnovski/mini.ai",
      "echasnovski/mini.hipatterns"
    },
    config = function()
      vim.api.nvim_create_autocmd({ "ModeChanged", "CursorHold" }, {
        once = true,
        callback = function()
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
          require("mini.ai").setup({
            custom_textobjects = { h = nn.miniai_spec },
          })

          require("mini.hipatterns").setup({
            highlighters = { cells = nn.minihipatterns_spec },
          })
        end,
      })
    end
  },
  {
    "kiyoon/jupynium.nvim",
    build = "pip install --user .",
    cmd = {
      "JupyniumStartSync",
      "JupyniumStopSync",
      "JupyniumStartAndAttachToServer",
      "JupyniumAttach",
    },
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
  },
}
