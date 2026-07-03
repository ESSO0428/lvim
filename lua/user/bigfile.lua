local function cmd_exists(cmd)
  return vim.fn.executable(cmd) == 1
end

local function is_table_like_file(fileName)
  local ext = vim.fn.fnamemodify(fileName, ":e"):lower()

  return vim.tbl_contains({
    "csv",
    "tsv",
    "xlsx",
    "xls",
    "json",
    "jsonl",
    "parquet",
    "sqlite",
    "db",
  }, ext)
end

local function build_bigfile_viewers(fileName)
  local escaped = vim.fn.shellescape(fileName)
  local viewers = {}

  local function add_bat()
    if cmd_exists("bat") then
      table.insert(viewers, {
        name = "bat",
        desc = "View with bat",
        cmd = "bat --paging=always --style=full --wrap=never " .. escaped,
      })
      return true
    end

    return false
  end

  local function add_visidata()
    if cmd_exists("vd") then
      table.insert(viewers, {
        name = "visidata",
        desc = "Open with VisiData",
        cmd = "vd " .. escaped,
      })
      return true
    elseif cmd_exists("visidata") then
      table.insert(viewers, {
        name = "visidata",
        desc = "Open with VisiData",
        cmd = "visidata " .. escaped,
      })
      return true
    end

    return false
  end

  local function add_fallback_pager()
    if cmd_exists("less") then
      table.insert(viewers, {
        name = "less",
        desc = "View with less",
        cmd = "less -S " .. escaped,
      })
      return true
    elseif cmd_exists("more") then
      table.insert(viewers, {
        name = "more",
        desc = "View with more",
        cmd = "more " .. escaped,
      })
      return true
    end

    return false
  end

  -- 表格型檔案優先給 VisiData
  if is_table_like_file(fileName) then
    add_visidata()
    add_bat()
    add_fallback_pager()
  else
    add_bat()
    add_visidata()
    add_fallback_pager()
  end

  return viewers
end

local function open_bigfile_viewer(fileName)
  local viewers = build_bigfile_viewers(fileName)

  if #viewers == 0 then
    vim.notify(
      "No available viewer found: bat, vd/visidata, less, or more",
      vim.log.levels.WARN
    )
    return
  end

  vim.ui.select(viewers, {
    prompt = "Open large file with:",
    format_item = function(item)
      return item.desc
    end,
  }, function(choice)
    if not choice then
      return
    end

    local Terminal = require("toggleterm.terminal").Terminal

    local viewer = Terminal:new {
      cmd = choice.cmd,
      hidden = true,
      direction = "float",
      close_on_exit = true,
      on_open = function(term)
        vim.cmd "startinsert!"

        vim.keymap.set({ "t", "n" }, "<C-\\>", "<cmd>bd!<cr>", {
          buffer = term.bufnr,
          noremap = true,
          silent = true,
        })
      end,
    }

    viewer:open()
  end)
end

lvim.builtin.bigfile.config = {
  filesize = 1,      -- size of the file in MiB, the plugin rounds file sizes to the closest MiB
  pattern = { "*" }, -- autocmd pattern or function

  features = {
    "indent_blankline",
    "illuminate",
    "lsp",
    "treesitter",
    "syntax",
    "matchparen",
    "vimopts",
    "filetype",

    {
      name = "mymatchparen",
      opts = {
        defer = false,
      },

      disable = function()
        vim.cmd("set nowrap")
        vim.cmd("set nofoldenable")
        vim.cmd("setlocal nospell")
        vim.cmd("setlocal cursorline")

        local ok_rainbow, rainbow = pcall(require, "rainbow-delimiters")
        if ok_rainbow then
          rainbow.disable(0)
        end

        local ok_session_utils, session_utils = pcall(require, "session_manager.utils")
        local is_session_loading = ok_session_utils and session_utils.session_loading

        if is_session_loading then
          return
        end

        if vim.g.vim_pid == nil then
          vim.g.vim_pid = vim.fn.getpid()
        end

        local pid_info = vim.g.vim_pid and ("(CURRENT PID: " .. vim.g.vim_pid .. ")") or ""
        local bufnr = vim.api.nvim_get_current_buf()
        local fileName = vim.api.nvim_buf_get_name(bufnr)

        local choice = vim.fn.input(
          table.concat({
            table.concat({
              pid_info,
              "File is large file, Do you want to continue loading?",
            }, " "),
            "[n]ot open",
            "[s]ecurity session save and open",
            "[y]es directly open",
            "[v]iew with external viewer",
            "choice(s/y/v/n): ",
          }, "\n")
        )

        if choice == "s" then
          vim.cmd("b#")
          vim.cmd("bd " .. bufnr)

          vim.defer_fn(function()
            vim.cmd("SessionManager save_current_session")
            vim.cmd("e " .. vim.fn.fnameescape(fileName))
          end, 50)
        elseif choice == "y" then
          -- Continue with default settings.
        elseif choice == "v" then
          vim.cmd("b#")
          vim.cmd("bd " .. bufnr)

          open_bigfile_viewer(fileName)
        else
          vim.cmd("b#")
          vim.cmd("bd " .. bufnr)
        end
      end,
    },
  },
}
