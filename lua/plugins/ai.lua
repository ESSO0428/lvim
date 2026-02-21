return {
  {
    "github/copilot.vim",
    commit = "7097b09",
    event = "InsertEnter", -- 進入 Insert 才啟動 Copilot
  },
  {
    "hrsh7th/cmp-copilot",
    event = "InsertEnter",
  },
  {
    "CopilotC-Nvim/CopilotChat.nvim",
    cmd = { "CopilotChat", "CopilotChatToggle" },
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
    "gutsavgupta/nvim-gemini-companion",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "folke/snacks.nvim",
    },
    -- event = "VeryLazy",
    cmd = { "GeminiToggle", "GeminiClose", "GeminiAccept", "GeminiReject" },
    config = function()
      -- You can configure the plugin by passing a table to the setup function
      -- Example:
      -- require("gemini").setup({
      --   cmds = {"gemini"},
      --   win = {
      --     preset = "floating",
      --     width = 0.8,
      --     height = 0.8,
      --   }
      -- })

      -- Auto-reload when files are changed on disk.
      -- NOTE: :checktime will only auto-read if the buffer has no unsaved changes.
      vim.opt.autoread = true

      -- Treat "leaving the embedded Gemini/Qwen CLI terminal" as a pseudo FocusGained.
      -- Why: when the CLI writes patches to disk, returning from its terminal to any
      --       normal buffer should trigger a reload (similar to clicking back from tmux).
      local aug_term = vim.api.nvim_create_augroup("GeminiCliTermReload", { clear = true })
      vim.api.nvim_create_autocmd({ "BufLeave", "TermClose" }, {
        group = aug_term,
        pattern = { "term://*gemini*", "term://*qwen*" },
        callback = function()
          vim.schedule(function() pcall(vim.cmd, "checktime") end)
        end,
        desc = "Treat leaving Gemini CLI terminal as FocusGained and reload files",
      })
      require("gemini").setup({
        -- NOTE: Disable other LLM CLI providers to avoid <Tab> keymap overlap
        -- cmds = { 'gemini', 'qwen' },
        cmds = { 'gemini' },
      })
    end,
    -- keys = {
    --   { "<leader>ukl", "<cmd>GeminiToggle<cr>", desc = "Toggle Gemini CLI" },
    --   { "<leader>ukj", "<cmd>GeminiClose<cr>",  desc = "Close Gemini CLI process" },
    --   { "<leader>uky", "<cmd>GeminiAccept<cr>", desc = "Accept Gemini suggested changes" },
    --   { "<leader>ukn", "<cmd>GeminiReject<cr>", desc = "Reject Gemini suggested changes" },
    -- }
  },
  {
    "ravitemer/mcphub.nvim",
    -- event = { "ModeChanged", "CursorHold" },
    dependencies = {
      "nvim-lua/plenary.nvim",
    },
    cmd = "MCPHub",
    build =
    "command -v uvx >/dev/null || curl -LsSf https://astral.sh/uv/install.sh | sh && npm install -g shx && npm install -g mcp-hub@latest", -- Installs required mcp-hub npm module
    config = function()
      -- Check if mcpservers.json exists, if not copy the template
      local mcpservers_path = vim.fn.expand("~/.config/mcphub/servers.json")
      local mcpservers_dir = vim.fn.fnamemodify(mcpservers_path, ":h")

      local template_path = vim.fn.expand(vim.fn.stdpath("config") .. "/templates/mcphub/servers.json")

      if vim.fn.filereadable(mcpservers_path) == 0 then
        -- Check if template exists
        if vim.fn.filereadable(template_path) == 1 then
          -- Create directory if it doesn't exist
          if vim.fn.isdirectory(mcpservers_dir) == 0 then
            vim.fn.mkdir(mcpservers_dir, "p")
          end
          vim.fn.system("cp " .. template_path .. " " .. mcpservers_path)
          vim.notify("Not Found " .. mcpservers_path .. " (For mcphub.nvim) Created mcpservers.json from template",
            vim.log.levels.INFO)
        else
          vim.notify("Template file not found at: " .. template_path, vim.log.levels.WARN)
        end
      end
      require("mcphub").setup({
        --- `mcp-hub` binary related options-------------------
        config = mcpservers_path,                                                        -- Absolute path to MCP Servers config file (will create if not exists)
        port = 2284,                                                                     -- The port `mcp-hub` server listens to
        shutdown_delay = 60 * 10 * 000,                                                  -- Delay in ms before shutting down the server when last instance closes (default: 10 minutes)
        use_bundled_binary = false,                                                      -- Use local `mcp-hub` binary (set this to true when using build = "bundled_build.lua")
        mcp_request_timeout = 60000,                                                     --Max time allowed for a MCP tool or resource to execute in milliseconds, set longer for long running tasks
        global_env = {},                                                                 -- Global environment variables available to all MCP servers (can be a table or a function returning a table)
        workspace = {
          enabled = true,                                                                -- Enable project-local configuration files
          look_for = { ".mcphub/servers.json", ".vscode/mcp.json", ".cursor/mcp.json" }, -- Files to look for when detecting project boundaries (VS Code format supported)
          reload_on_dir_changed = true,                                                  -- Automatically switch hubs on DirChanged event
          port_range = { min = 40000, max = 41000 },                                     -- Port range for generating unique workspace ports
          get_port = nil,                                                                -- Optional function returning custom port number. Called when generating ports to allow custom port assignment logic
        },

        ---Chat-plugin related options-----------------
        auto_approve = false,           -- Auto approve mcp tool calls
        auto_toggle_mcp_servers = true, -- Let LLMs start and stop MCP servers automatically
        extensions = {
          avante = {
            make_slash_commands = true, -- make /slash commands from MCP server prompts
          }
        },

        --- Plugin specific options-------------------
        native_servers = {}, -- add your custom lua native servers here
        builtin_tools = {
          edit_file = {
            parser = {
              track_issues = true,
              extract_inline_content = true,
            },
            locator = {
              fuzzy_threshold = 0.8,
              enable_fuzzy_matching = true,
            },
            ui = {
              go_to_origin_on_complete = true,
              keybindings = {
                accept = ".",
                reject = ",",
                next = "n",
                prev = "p",
                accept_all = "ga",
                reject_all = "gr",
              },
            },
          },
        },
        ui = {
          window = {
            width = 0.8,      -- 0-1 (ratio); "50%" (percentage); 50 (raw number)
            height = 0.8,     -- 0-1 (ratio); "50%" (percentage); 50 (raw number)
            align = "center", -- "center", "top-left", "top-right", "bottom-left", "bottom-right", "top", "bottom", "left", "right"
            relative = "editor",
            zindex = 50,
            border = "rounded", -- "none", "single", "double", "rounded", "solid", "shadow"
          },
          wo = {                -- window-scoped options (vim.wo)
            winhl = "Normal:MCPHubNormal,FloatBorder:MCPHubBorder",
          },
        },
        on_ready = function(hub)
          -- Called when hub is ready
        end,
        on_error = function(err)
          -- Called on errors
        end,
        log = {
          level = vim.log.levels.WARN,
          to_file = false,
          file_path = nil,
          prefix = "MCPHub",
        },
      })
    end,
  },
  {
    "yetone/avante.nvim",
    -- event = "VeryLazy",
    event = { "ModeChanged", "CursorHold" },
    version = false, -- Never set this value to "*"! Never!
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
    config = function()
      require("user.avante").setup()
    end,
    -- if you want to download pre-built binary, then pass source=false. Make sure to follow instruction above.
    -- Also note that downloading prebuilt binary is a lot faster comparing to compiling from source.
    -- NOTE: Ensure that `nvim --version` >= 0.10.1
    -- NOTE: To use `avante.nvim`, ensure that `cargo --version` >= 1.80.0. You can update the version using `rustup update`.
    -- If the plugin was installed before this version, you must use the command `:Lazy` to clear `avante.nvim`.
    -- 1. Then, re-login to Linux or reload `.bashrc` or `.zshrc`, and restart nvim to reinstall the plugin.
    -- 2. Since the provider is copilot, ensure you have successfully logged in using `:Copilot auth` to avoid potential errors.
    -- if you want to build from source then do `make BUILD_FROM_SOURCE=true`
    -- ⚠️ must add this setting! ! !
    build = function()
      -- conditionally use the correct build system for the current OS
      if vim.fn.has("win32") == 1 then
        return "powershell -ExecutionPolicy Bypass -File Build.ps1 -BuildFromSource false"
      else
        return "make"
      end
    end,
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
    keys = {
      { "<leader>aa", "<cmd>AvanteAsk<cr>",    mode = { "n", "v" }, desc = "Avante: Ask" },
      { "<leader>ae", "<cmd>AvanteEdit<cr>",   mode = { "n", "v" }, desc = "Avante: Edit" },
      { "<leader>a?", "<cmd>AvanteModels<cr>", mode = { "n", "v" }, desc = "Avante: Select Models" },
    }
  },
}
