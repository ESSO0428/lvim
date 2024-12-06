local M = {}
M.view_side = "left"

M.config = {
  left = {}, ---@type (Edgy.View.Opts|string)[]
  bottom = {}, ---@type (Edgy.View.Opts|string)[]
  right = {}, ---@type (Edgy.View.Opts|string)[]
  top = {}, ---@type (Edgy.View.Opts|string)[]

  ---@type table<Edgy.Pos, {size:integer | fun():integer, wo?:vim.wo}>
  options = {
    left = { size = 30 },
    bottom = { size = 10 },
    right = { size = 30 },
    top = { size = 10 },
  },
  -- edgebar animations
  animate = {
    enabled = false,
    fps = 100, -- frames per second
    cps = 120, -- cells per second
    on_begin = function()
      vim.g.minianimate_disable = true
    end,
    on_end = function()
      vim.g.minianimate_disable = false
    end,
    -- Spinner for pinned views that are loading.
    -- if you have noice.nvim installed, you can use any spinner from it, like:
    -- spinner = require("noice.util.spinners").spinners.circleFull,
    spinner = {
      frames = { "⠋", "⠙", "⠹", "⠸", "⠼", "⠴", "⠦", "⠧", "⠇", "⠏" },
      interval = 80,
    },
  },
  -- enable this to exit Neovim when only edgy windows are left
  exit_when_last = false,
  -- close edgy when all windows are hidden instead of opening one of them
  -- disable to always keep at least one edgy split visible in each open section
  close_when_all_hidden = true,
  -- global window options for edgebar windows
  ---@type vim.wo
  wo = {
    -- Setting to `true`, will add an edgy winbar.
    -- Setting to `false`, won't set any winbar.
    -- Setting to a string, will set the winbar to that string.
    winbar = true,
    winfixwidth = true,
    winfixheight = false,
    winhighlight = "WinBar:EdgyWinBar,Normal:EdgyNormal",
    spell = false,
    signcolumn = "no",
  },
  -- buffer-local keymaps to be added to edgebar buffers.
  -- Existing buffer-local keymaps will never be overridden.
  -- Set to false to disable a builtin.
  ---@type table<string, fun(win:Edgy.Window)|false>
  keys = {
    -- close window
    ["q"] = function(win)
      win:close()
    end,
    -- hide window
    ["<leader>/"] = function(win)
      win:hide()
    end,
    -- close sidebar
    ["<leader>e"] = function(win)
      -- win.view.edgebar:close()
      vim.cmd('OutlineClose')
      require("edgy").close()
      require("edgy").goto_main()
    end,
    -- next open window
    ["]]"] = function(win)
      win:next({ visible = true, focus = true })
    end,
    -- previous open window
    ["[["] = function(win)
      win:prev({ visible = true, focus = true })
    end,
    -- next loaded window
    ["<leader>]"] = function(win)
      win:next({ pinned = false, focus = true })
    end,
    -- prev loaded window
    ["<leader>["] = function(win)
      win:prev({ pinned = false, focus = true })
    end,
    -- increase width
    ["<Right>"] = function(win)
      win:resize("width", 5)
    end,
    -- decrease width
    ["<left>"] = function(win)
      win:resize("width", -5)
    end,
    -- increase height
    ["<Down>"] = function(win)
      win:resize("height", 5)
    end,
    -- decrease height
    ["<Up>"] = function(win)
      win:resize("height", -5)
    end,
    -- reset all custom sizing
    ["<leader>="] = function(win)
      win.view.edgebar:equalize()
    end,
  },
  icons = {
    closed = " ",
    open = " ",
  },
  -- enable this on Neovim <= 0.10.0 to properly fold edgebar windows.
  -- Not needed on a nightly build >= June 5, 2023.
  fix_win_height = vim.fn.has("nvim-0.10.0") == 0,
  bottom = {
    -- toggleterm / lazyterm at the bottom with a height of 40% of the screen
    {
      ft = "toggleterm",
      size = { height = 0.4 },
      -- exclude floating windows
      filter = function(buf, win)
        return vim.api.nvim_win_get_config(win).relative == ""
      end,
    },
    {
      ft = "lazyterm",
      title = "LazyTerm",
      size = { height = 0.4 },
      filter = function(buf)
        return not vim.b[buf].lazyterm_cmd
      end,
    },
    "Trouble",
    { ft = "qf",            title = "QuickFix" },
    {
      ft = "help",
      size = { height = 20 },
      -- only show help buffers
      filter = function(buf)
        return vim.bo[buf].buftype == "help"
      end,
    },
    { ft = "spectre_panel", size = { height = 0.4 } },
  },
  -- File explorer configuration based on active plugin
  left =
      vim.list_extend(
        lvim.builtin.nvimtree.active and {
          {
            title = "Nvim-Tree",
            ft = "NvimTree",
            pinned = true,
            open = "NvimTreeOpen",
          }
        } or {
          {
            title = "Neo-Tree",
            ft = "neo-tree",
            filter = function(buf)
              return vim.b[buf].neo_tree_source == "filesystem"
            end,
            open = "Neotree reveal_force_cwd",
            pinned = true,
          },
        },
        {
          {
            title = "RemoteExplore",
            ft = "neo-tree",
            open = "Neotree remote",
            pinned = false,
            collapsed = false,
          },
          {
            title = "DBUI",
            ft = "dbui",
            open = "DBUI",
            pinned = false,
            collapsed = false,
            size = { height = 0.55 },
          },
          {
            title = function()
              local buf_name = vim.api.nvim_buf_get_name(0)

              local special_windows = { "NeoTree", "NvimTree", "OUTLINE" }
              local pattern = table.concat(special_windows, "\\|")
              local outline_file_name = vim.g.outline_laset_focuse_file_name or buf_name
              outline_file_name = outline_file_name or "[No Name]"
              if not vim.regex(pattern):match_str(buf_name) then
                vim.g.outline_laset_focuse_file_name = buf_name
              end
              return "Outline " .. "(" .. vim.fn.fnamemodify(outline_file_name, ":t") .. ")"
            end,
            ft = "Outline",
            open = "OutlineOpen",
            pinned = true,
            collapsed = false,
          },
        }
      )
}
require("edgy").setup(M.config)

-- Function to swap left and right layouts
function M.swap_layouts()
  -- NOTE: reload the plugin
  local plugin = require("lazy.core.config").plugins["edgy.nvim"]
  require("lazy.core.loader").reload(plugin)

  -- Store the left and right layouts temporarily
  local config = require("user.edgy").config

  -- Swap the layouts
  config.left, config.right = config.right, config.left
  config.options.left, config.options.right = config.options.right, config.options.left

  -- Reload the Edgy plugin with the updated configuration
  require("edgy").setup(config)
end

return M
