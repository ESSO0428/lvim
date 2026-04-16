local M = {}
M.view_side = "left"

function M.reload_edgy_if_error()
  -- Check edgy.nvim had an error or not (last)
  -- If it had an error, reload the plugin
  local history = require("notify").history()
  if not history or #history == 0 then
    return
  end

  local last_entry = history[#history]
  local last_message = table.concat(last_entry.message, "\n")

  if last_message:match("Edgy: Failed to layout windows") then
    require("notify")("Detected Edgebar layout error. Attempting to reload the plugin...", vim.log.levels.WARN)

    local plugin = require("lazy.core.config").plugins["edgy.nvim"]
    require("lazy.core.loader").reload(plugin)

    local success, config = pcall(require, "user.edgy")
    if success and config.config then
      require("edgy").setup(config.config)
      require("notify")("Edgebar plugin reloaded successfully.", vim.log.levels.INFO)
    else
      require("notify")("Failed to reload Edgebar plugin configuration.", vim.log.levels.ERROR)
    end
  end
end

M.title_memory = {
  help = "help",
  man = "man",
  CopilotChat = "CopilotChat"
}

local title_update_based_edgy_status = function(title_name, buftype, filetype)
  local suffix = ""
  if vim.b[0].edgy_disable == true then
    suffix = "( edgy)"
  end
  local title = table.concat({ title_name, suffix }, " ")
  if buftype and vim.bo[0].buftype == buftype or vim.bo[0].filetype == filetype then
    vim.b.edgy_winbar_title = title_name
    M.title_memory[title_name] = title
  end
  return M.title_memory[title_name] or title_name
end

M.init_winbar = function()
  if vim.b[0].edgy_disable and vim.b[0].edgy_winbar_title then
    vim.wo.winbar = string.format("%%#EdgyIconActive# %%#EdgyWinBar# %s %s", vim.b.edgy_winbar_title,
      "( edgy)")
  else
    vim.wo.winbar = "%!v:lua.require'edgy.window'.edgy_winbar()"
    vim.cmd("doautocmd VimResized")
  end
end

-- Tab restore helpers
local function view_key(view)
  return table.concat({ view.edgebar.pos, view.ft or "", view.get_title() }, "::")
end

local function get_view_state(view)
  local has_valid_win = false
  local has_visible_win = false

  for _, win in ipairs(view.wins or {}) do
    if win:is_valid() then
      has_valid_win = true
      if win.visible then
        has_visible_win = true
      end
    end
  end

  if not has_valid_win then
    return nil
  end

  return {
    key = view_key(view),
    pos = view.edgebar.pos,
    ft = view.ft,
    title = view.get_title(),
    visible = has_visible_win,
  }
end

local function restore_view(view)
  if type(view.restore) == "function" then
    pcall(view.restore, view)
  elseif view.pinned then
    view:open_pinned()
  elseif type(view.open) == "function" then
    pcall(view.open)
  elseif type(view.open) == "string" then
    pcall(vim.cmd, view.open)
  end
end

local function cleanup_view(view)
  if type(view.tab_leave_cleanup) == "function" then
    pcall(view.tab_leave_cleanup, view)
  elseif type(view.tab_leave_cleanup) == "string" then
    pcall(vim.cmd, view.tab_leave_cleanup)
  end
end

local function find_view(config, panel)
  local edgebar = config.layout[panel.pos]
  if not edgebar then
    return
  end

  for _, view in ipairs(edgebar.views) do
    if view_key(view) == panel.key then
      return view
    end
  end

  for _, view in ipairs(edgebar.views) do
    if view.ft == panel.ft and view.get_title() == panel.title then
      return view
    end
  end
end

local function has_runtime_reopen(view)
  return type(view.restore) == "function" or view.pinned or type(view.open) == "function" or type(view.open) == "string"
end

local function build_deferred_entries(view)
  if has_runtime_reopen(view) then
    return {}
  end

  if type(view.deferred) ~= "function" then
    return {}
  end

  local entries = {}

  for _, win in ipairs(view.wins or {}) do
    if win:is_valid() then
      local ok, entry = pcall(view.deferred, view, win.win)
      if ok and entry then
        if vim.islist(entry) then
          for _, item in ipairs(entry) do
            if item then
              item.key = item.key or view_key(view)
              table.insert(entries, item)
            end
          end
        else
          entry.key = entry.key or view_key(view)
          table.insert(entries, entry)
        end
      end
    end
  end

  return entries
end

local function run_deferred(state)
  for _, entry in ipairs(state.deferred or {}) do
    if type(entry.cmd) == "string" and entry.cmd ~= "" then
      pcall(vim.cmd, entry.cmd)
    end
  end
end

-- View-specific restore hooks
local function toggleterm_restore()
  local ok, toggleterm = pcall(require, "toggleterm")
  if ok then
    toggleterm.toggle(0)
  end
end

local function trouble_deferred(_, win)
  local info = vim.w[win].trouble
  if type(info) ~= "table" or not info.mode then
    return
  end

  local parts = {
    "Trouble",
    info.mode,
    "open",
    "focus=false",
    "open_no_results=true",
  }

  if info.type then
    table.insert(parts, "win.type=" .. info.type)
  end
  if info.position then
    table.insert(parts, "win.position=" .. info.position)
  end
  if info.relative then
    table.insert(parts, "win.relative=" .. info.relative)
  end

  return { cmd = table.concat(parts, " ") }
end

local function help_topic_from_win(win)
  local buf = vim.api.nvim_win_get_buf(win)
  local name = vim.api.nvim_buf_get_name(buf)
  if vim.bo[buf].buftype == "help" and name ~= "" then
    return vim.fn.fnamemodify(name, ":t:r")
  end
end

local function help_deferred(_, win)
  local topic = help_topic_from_win(win)
  if topic then
    return { cmd = "help " .. topic }
  end
end

local function man_deferred(_, win)
  local buf = vim.api.nvim_win_get_buf(win)
  local name = vim.api.nvim_buf_get_name(buf)
  if vim.bo[buf].buftype == "nofile" and name ~= "" then
    return { cmd = "Man " .. vim.fn.fnamemodify(name, ":t:r") }
  end
end

function M.save_tab_state(tab)
  local ok, config = pcall(require, "edgy.config")
  if not ok or not config.layout then
    return
  end

  tab = tab or vim.api.nvim_get_current_tabpage()
  local state = { panels = {}, deferred = {} }

  for _, pos in ipairs({ "left", "right", "bottom", "top" }) do
    local edgebar = config.layout[pos]
    if edgebar then
      for _, view in ipairs(edgebar.views) do
        local saved_view_state = get_view_state(view)
        if saved_view_state then
          table.insert(state.panels, saved_view_state)
          for _, deferred in ipairs(build_deferred_entries(view)) do
            table.insert(state.deferred, deferred)
          end
        end
      end
    end
  end

  vim.api.nvim_tabpage_set_var(tab, "edgy_state", state)
end

function M.cleanup_tab_views(tab)
  local ok, config = pcall(require, "edgy.config")
  if not ok or not config.layout then
    return
  end

  tab = tab or vim.api.nvim_get_current_tabpage()
  if tab ~= vim.api.nvim_get_current_tabpage() then
    return
  end

  for _, pos in ipairs({ "left", "right", "bottom", "top" }) do
    local edgebar = config.layout[pos]
    if edgebar then
      for _, view in ipairs(edgebar.views) do
        for _, win in ipairs(view.wins or {}) do
          if win:is_valid() then
            cleanup_view(view)
            break
          end
        end
      end
    end
  end
end

function M.restore_tab_state(tab)
  local ok, config = pcall(require, "edgy.config")
  if not ok or not config.layout then
    return
  end

  tab = tab or vim.api.nvim_get_current_tabpage()
  local ok_state, state = pcall(vim.api.nvim_tabpage_get_var, tab, "edgy_state")
  if not ok_state then
    return
  end
  if not state or vim.tbl_isempty(state.panels or {}) then
    return
  end

  local target_win = vim.api.nvim_get_current_win()
  local target_is_edgy = false
  if vim.api.nvim_win_is_valid(target_win) then
    local target_buf = vim.api.nvim_win_get_buf(target_win)
    target_is_edgy = vim.bo[target_buf].filetype == "edgy"
  end

  if target_is_edgy then
    local ok_editor, editor = pcall(require, "edgy.editor")
    if ok_editor then
      editor:goto_main()
      target_win = vim.api.nvim_get_current_win()
    end
  end

  vim.schedule(function()
    if not vim.api.nvim_tabpage_is_valid(tab) or tab ~= vim.api.nvim_get_current_tabpage() then
      return
    end

    for _, panel in ipairs(state.panels) do
      local view = find_view(config, panel)
      if view then
        restore_view(view)
      end
    end

    vim.schedule(function()
      run_deferred(state)
    end)

    vim.schedule(function()
      for _, panel in ipairs(state.panels) do
        if not panel.visible then
          local view = find_view(config, panel)
          if view then
            for _, win in ipairs(view.wins or {}) do
              if win:is_valid() and win.visible then
                win:hide()
                break
              end
            end
          end
        end
      end
    end)

    vim.schedule(function()
      if vim.api.nvim_win_is_valid(target_win) then
        vim.api.nvim_set_current_win(target_win)
      else
        local ok_editor, editor = pcall(require, "edgy.editor")
        if ok_editor then
          editor:goto_main()
        end
      end
    end)
  end)
end

function M.setup_tab_restore()
  local group = vim.api.nvim_create_augroup("user_edgy_tab_restore", { clear = true })

  vim.api.nvim_create_autocmd("TabLeave", {
    group = group,
    callback = function()
      if vim.v.exiting ~= vim.NIL then
        return
      end
      M.save_tab_state()
      M.cleanup_tab_views()
      pcall(require("edgy").close)
    end,
  })

  vim.api.nvim_create_autocmd("TabEnter", {
    group = group,
    callback = function()
      if vim.v.exiting ~= vim.NIL then
        return
      end
      M.restore_tab_state()
    end,
  })
end

M.config = {
  ---@type table<Edgy.Pos, {size:integer | fun():integer, wo?:vim.wo}>
  options = {
    left = { size = 30 },
    bottom = { size = 10 },
    right = { size = 70 },
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

      M.reload_edgy_if_error()
    end,
    ["sw"] = function(win)
      vim.b[0].edgy_disable = not vim.b[0].edgy_disable

      vim.keymap.set("n", "sw", function()
        vim.b[0].edgy_disable = not vim.b[0].edgy_disable
        M.init_winbar()
      end, { buffer = true })
      vim.keymap.set("n", "<up>", function()
        (vim.b[0].edgy_disable and function() vim.cmd("res -5") end or function()
          require("edgy").get_win()
              :resize("height", -5)
        end)()
      end, { buffer = true })

      vim.keymap.set("n", "<down>", function()
        (vim.b[0].edgy_disable and function() vim.cmd("res +5") end or function()
          require("edgy").get_win()
              :resize("height", 5)
        end)()
      end, { buffer = true })

      vim.keymap.set("n", "<left>", function()
        (vim.b[0].edgy_disable and function() vim.cmd("vertical resize-5") end or function()
          require("edgy").get_win():resize("width",
            -5)
        end)()
      end, { buffer = true })

      vim.keymap.set("n", "<right>", function()
        (vim.b[0].edgy_disable and function() vim.cmd("vertical resize+5") end or function()
          require("edgy").get_win():resize("width",
            5)
        end)()
      end, { buffer = true })
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
  top = {}, ---@type (Edgy.View.Opts|string)[]
  bottom = {
    { ft = "qf",            title = "QuickFix" },
    -- toggleterm / lazyterm at the bottom with a height of 40% of the screen
    {
      ft = "toggleterm",
      size = { height = 0.4 },
      restore = toggleterm_restore,
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
    {
      ft = "Trouble",
      deferred = trouble_deferred,
    },
    {
      ft = "help",
      size = { height = 20 },
      -- only show help buffers
      title = function()
        return title_update_based_edgy_status("help", "help", "")
      end,
      deferred = help_deferred,
      filter = function(buf)
        return vim.bo[buf].buftype == "help"
      end,
    },
    {
      ft = "man",
      size = { height = 20 },
      title = function()
        return title_update_based_edgy_status("man", "man", "")
      end,
      deferred = man_deferred,
    },
    {
      ft = "markdown",
      size = { height = 20 },
      -- only show help buffers
      title = function()
        return title_update_based_edgy_status("help", "help", "")
      end,
      filter = function(buf)
        return vim.bo[buf].buftype == "help"
      end,
    },
    { ft = "spectre_panel", size = { height = 0.4 } },
  }, ---@type (Edgy.View.Opts|string)[]
  -- File explorer configuration based on active plugin
  left =
  ---@type (Edgy.View.Opts|string)[]
      vim.list_extend(
        {
          {
            title = "DBUI",
            ft = "dbui",
            open = "DBUI",
            pinned = false,
            collapsed = false,
            size = { height = 0.55 },
          }
        },
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
                return vim.b[buf].neo_tree_source == "filesystem" and vim.b[buf].neo_tree_position ~= "current"
              end,
              open = "Neotree reveal_force_cwd",
              pinned = true,
            },
            {
              title = "Neo-Tree Buffers",
              ft = "neo-tree",
              filter = function(buf)
                return vim.b[buf].neo_tree_source == "buffers" and vim.b[buf].neo_tree_position ~= "current"
              end,
              open = "Neotree buffers reveal_force_cwd",
              pinned = false,
              collapsed = false,
            },
          },
          {
            {
              title = "RemoteExplore",
              ft = "neo-tree",
              open = "Neotree remote",
              filter = function(buf)
                return vim.b[buf].neo_tree_source == "remote"
              end,
              pinned = false,
              collapsed = false,
            },
            {
              title = function()
                local buf_name = vim.api.nvim_buf_get_name(0)

                local special_windows = { "NeoTree", "NvimTree", "OUTLINE" }
                local pattern = table.concat(special_windows, "\\|")
                local outline_file_name = vim.g.outline_laset_focuse_file_name or buf_name
                outline_file_name = outline_file_name or "[No Name]"
                if not vim.regex(pattern):match_str(buf_name) and vim.bo[0].buftype == "" then
                  vim.g.outline_laset_focuse_file_name = buf_name
                end
                if outline_file_name ~= "" then
                  return "Outline " .. "(" .. vim.fn.fnamemodify(outline_file_name, ":t") .. ")"
                end
                return "Outline"
              end,
              ft = "Outline",
              open = "OutlineOpen!",
              tab_leave_cleanup = "OutlineClose",
              pinned = true,
              collapsed = false,
            },
          }
        )),
  right = {
    {
      ft = "copilot-chat",
      title = function()
        return title_update_based_edgy_status("CopilotChat", "", "copilot-chat")
      end,
      open = "CopilotChatOpen",
    }
  } ---@type (Edgy.View.Opts|string)[]
}

function M.setup()
  local edgy = require("edgy")
  edgy.setup(M.config)

  local restricted_fts = {}
  local regions = { "bottom", "left", "right", "top" }

  -- 收集所有 ft
  for _, region in ipairs(regions) do
    if M.config[region] and type(M.config[region]) == "table" then
      for _, obj in ipairs(M.config[region]) do
        if obj.ft then
          table.insert(restricted_fts, obj.ft)
        end
      end
    end
  end

  -- **優化：改用 table 來存儲 ft，提升查找速度**
  local ok_floatwindow, floatwindow = pcall(require, "user.config.plugins.floatwindow")
  if ok_floatwindow and type(floatwindow.restricted_fts_set) == "table" then
    for _, ft in ipairs(restricted_fts) do
      floatwindow.restricted_fts_set[ft] = true
    end
  end

  M.setup_tab_restore()
end

-- Function to swap left and right layouts
function M.swap_layouts()
  local config = M.config

  -- Swap the layouts
  config.left, config.right = config.right, config.left
  config.options.left, config.options.right = config.options.right, config.options.left

  if not package.loaded["edgy"] then
    return false
  end

  local ok_lazy_config, lazy_config = pcall(require, "lazy.core.config")
  local ok_lazy_loader, lazy_loader = pcall(require, "lazy.core.loader")
  local ok_edgy, edgy = pcall(require, "edgy")
  if not (ok_lazy_config and ok_lazy_loader and ok_edgy) then
    return false
  end

  -- NOTE: reload the plugin
  local plugin = lazy_config.plugins["edgy.nvim"]
  if plugin then
    lazy_loader.reload(plugin)
  end

  -- Reload the Edgy plugin with the updated configuration
  edgy.setup(config)
  return true
end

return M
