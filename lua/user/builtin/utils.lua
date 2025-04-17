Nvim.null_ls = {}
Nvim.DiffTool = {}
Nvim.Buffer_Manager = {}
Nvim.Buffer_check = {}
Nvim.Quickfix = {}
Nvim.DAP = {}
Nvim.DAPUI = {}


Nvim.Buffer_Manager.scratch_opener = require "user.builtin.apps.scratch_opener"

function Nvim.nvim_create_user_commands(command_names, command_function)
  for _, cmd_name in ipairs(command_names) do
    vim.api.nvim_create_user_command(cmd_name, command_function, {})
  end
end

-- compare two tables content
function Nvim.tables_equal(table1, table2)
  for key, value in pairs(table1) do
    if table2[key] ~= value then
      return false
    end
  end
  for key, value in pairs(table2) do
    if table1[key] ~= value then
      return false
    end
  end
  return true
end

-- Create a function to generate CLI format action
function Nvim.null_ls.create_cli_format_action(opts)
  local command = opts.command
  local args = opts.args or {}
  local name = opts.name or command

  -- Replace $FILENAME in args with actual file path
  local function get_formatted_args(file_path)
    local final_args = {}
    for _, arg in ipairs(args) do
      if arg == "$FILENAME" then
        table.insert(final_args, file_path)
      else
        table.insert(final_args, arg)
      end
    end
    return final_args
  end

  -- Format file function
  local function format_file()
    -- current file path
    local file_path = vim.fn.expand("%:p")

    -- prepare command arguments
    local formatted_args = get_formatted_args(file_path)
    local full_command = command .. " " .. table.concat(formatted_args, " ")

    -- execute command
    local result = vim.fn.system(full_command)

    -- if format failed, print error message
    if vim.v.shell_error ~= 0 then
      vim.notify(name .. " format failed: " .. result, vim.log.levels.WARN)
      return
    end

    -- refresh buffer content without breaking undo tree
    local bufnr = vim.api.nvim_get_current_buf()
    -- load formatted file
    local new_lines = vim.fn.readfile(file_path)
    -- save current content
    local old_lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
    -- update only if content changed
    if not Nvim.tables_equal(old_lines, new_lines) then
      -- update buffer
      vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, new_lines)
      -- save file
      vim.cmd('write!')
      vim.notify("File formatted and saved.", vim.log.levels.INFO)
    else
      vim.notify("No changes needed.", vim.log.levels.INFO)
    end
  end

  -- Return the action function
  return function()
    -- check if file is modified
    if vim.bo.modified then
      -- hint user to save file using vim.ui.select
      vim.ui.select(
        { "Yes", "No" },
        {
          prompt = "File is not saved. Save before formatting?",
          format_item = function(item) return item end,
        },
        function(choice)
          if choice == "Yes" then
            vim.api.nvim_command("w")
            format_file()
          else
            print("Formatting canceled.")
          end
        end
      )
      return
    end

    -- directly format file
    format_file()
  end
end

--- Opens a conflict resolution diff tool in Neovim.
---
--- This function detects the Git conflict markers (`<<<<<<<`, `=======`, `>>>>>>>`)
--- surrounding the cursor position and splits the conflicting changes into two
--- separate buffers, displayed side by side in a diff view.
---
--- Features:
--- - Detects conflict regions based on the cursor's position.
--- - Creates two temporary buffers to store `OURS` and `THEIRS` versions.
--- - Automatically enables `diffthis` for easier comparison.
--- - Closes both buffers when either one is closed.
--- - Keeps the cursor position aligned to the corresponding line in the new buffers.
---
--- ---
--- Usage:
--- Call `:ConflictDiff` when inside a file with merge conflicts.
---
--- ---
--- Result
--- ```
--- |raw file--|
--- |  <<<<<   |
--- |  OURS    |
--- |  =====   |
--- |  THEIRS  |
--- |  >>>>>   |
--- |----------|
--- | OURS   | THEIRS |
--- | buf1   | buf2   |
--- |--------|--------|
--- ```
function Nvim.DiffTool.open_conflict_diff()
  local cursor_pos = vim.api.nvim_win_get_cursor(0)
  local ft = vim.api.nvim_get_option_value("filetype", { buf = 0 })
  local line_num = cursor_pos[1]

  local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)

  -- Find conflict markers within the file
  local start1, end1, start2, end2 = nil, nil, nil, nil
  local in_conflict = false

  -- Locate the start of the conflict (`<<<<<<<`)
  for i = line_num, 1, -1 do
    if lines[i]:match("^<<<<<<<") then
      start1 = i
      in_conflict = true
      break
    end
  end

  -- If no conflict markers are found, print a message and exit
  if not in_conflict then
    print("No Git conflict found!")
    return
  end

  -- Locate the middle (`=======`) and end (`>>>>>>>`) markers
  for i = start1 + 1, #lines do
    if lines[i]:match("^=======") then
      end1 = i - 1
      start2 = i + 1
    elseif lines[i]:match("^>>>>>>>") then
      end2 = i - 1
      break
    end
  end

  -- If any markers are missing, the conflict block is invalid
  if not (start1 and end1 and start2 and end2) then
    print("Invalid conflict block!")
    return
  end

  -- Determine the relative cursor position within the conflict block
  local relative_line
  local target_buffer = "ours"

  if line_num > start1 and line_num <= end1 then
    relative_line = line_num - (start1 + 1)
    target_buffer = "ours"
  elseif line_num >= start2 and line_num <= end2 then
    relative_line = line_num - start2
    target_buffer = "theirs"
  else
    relative_line = 0
  end

  -- Create two new buffers for OURS and THEIRS versions
  local buf1 = vim.api.nvim_create_buf(false, true)
  local buf2 = vim.api.nvim_create_buf(false, true)

  -- Populate the buffers with the corresponding conflict sections
  vim.api.nvim_buf_set_lines(buf1, 0, -1, false, vim.list_slice(lines, start1 + 1, end1))
  vim.api.nvim_buf_set_lines(buf2, 0, -1, false, vim.list_slice(lines, start2, end2))

  -- Set the buffers to automatically wipe when no longer used
  vim.api.nvim_set_option_value("bufhidden", "wipe", { buf = buf1 })
  vim.api.nvim_set_option_value("bufhidden", "wipe", { buf = buf2 })

  -- Function to close both buffers when either one is closed
  local function close_both_buffers()
    if not vim.api.nvim_buf_is_valid(buf1) and not vim.api.nvim_buf_is_valid(buf2) then
      return -- Avoid redundant buffer deletions
    end
    vim.schedule(function()
      if vim.api.nvim_buf_is_valid(buf1) then
        vim.api.nvim_buf_delete(buf1, { force = true })
      end
      if vim.api.nvim_buf_is_valid(buf2) then
        vim.api.nvim_buf_delete(buf2, { force = true })
      end
    end)
  end

  -- Set up autocommands to close both buffers when one is closed
  vim.api.nvim_create_autocmd("BufWinLeave", {
    buffer = buf1,
    callback = function()
      close_both_buffers()
    end,
  })
  vim.api.nvim_create_autocmd("BufWinLeave", {
    buffer = buf2,
    callback = function()
      close_both_buffers()
    end,
  })

  -- Split the window and load OURS into the left pane
  vim.cmd("split")
  local win1 = vim.api.nvim_get_current_win()
  vim.api.nvim_win_set_buf(win1, buf1)
  vim.api.nvim_set_option_value("winbar", "OURS", { win = win1 })

  -- Create a vertical split for THEIRS on the right side
  vim.cmd("belowright vsplit")
  local win2 = vim.api.nvim_get_current_win()
  vim.api.nvim_win_set_buf(win2, buf2)
  vim.api.nvim_set_option_value("winbar", "THEIRS", { win = win2 })

  -- Enable diff mode in both buffers
  if ft and ft ~= "" then
    vim.api.nvim_set_current_win(win1)
    vim.cmd("setlocal filetype=" .. ft)
    vim.cmd("diffthis")

    vim.api.nvim_set_current_win(win2)
    vim.cmd("setlocal filetype=" .. ft)
    vim.cmd("diffthis")
  else
    vim.api.nvim_set_current_win(win1)
    vim.cmd("diffthis")

    vim.api.nvim_set_current_win(win2)
    vim.cmd("diffthis")
  end

  -- Move the cursor to the corresponding line in OURS or THEIRS
  if target_buffer == "ours" then
    vim.api.nvim_set_current_win(win1)
    local target_line = math.max(0, relative_line)
    vim.api.nvim_win_set_cursor(win1, { target_line + 1, 0 })
  elseif target_buffer == "theirs" then
    vim.api.nvim_set_current_win(win2)
    local target_line = math.max(0, relative_line)
    vim.api.nvim_win_set_cursor(win2, { target_line + 1, 0 })
  end
end

--- Opens a full conflict resolution diff tool in Neovim.
---
--- This function scans the entire buffer for Git conflict markers (`<<<<<<<`, `=======`, `>>>>>>>`)
--- and splits the conflicting changes into separate buffers, displayed side by side in a diff view.
---
--- Features:
--- - Detects all conflict regions across the entire buffer.
--- - Removes Git conflict markers while preserving non-conflicting content.
--- - Creates temporary buffers to store `OURS` and `THEIRS` versions.
--- - Automatically enables `diffthis` for easier comparison.
--- - Closes all buffers when any of them is closed.
--- - Supports both 2-way (`OURS | THEIRS`) and 3-way (`OURS | BASE | THEIRS`) diffs.
--- - Opens in a new tab to avoid disrupting the current workflow.
---
--- ---
--- Usage:
--- Call `:ConflictDiffAll` to resolve all conflicts in the file.
---
--- ---
--- Result:
--- ```
--- | Original file  |
--- |  <<<<< HEAD    |
--- |  OURS content  |
--- |  =======       |
--- |  THEIRS content|
--- |  >>>>>>> branch|
--- |--------------- |
--- | OURS    | THEIRS |
--- | buf1    | buf2   |
--- |---------|--------|
--- ```
---
--- If `|||||||` markers are found, `BASE` content is extracted, enabling a 3-way diff:
---
--- ```
--- | OURS    | BASE    | THEIRS |
--- | buf1    | buf3    | buf2   |
--- |---------|--------|--------|
--- ```
---
--- ---
--- Reference:
--- This implementation is inspired by [whiteinge/diffconflicts](https://github.com/whiteinge/diffconflicts).
function Nvim.DiffTool.open_all_conflict_diff()
  local bufnr = vim.api.nvim_get_current_buf()
  local original_buf = bufnr
  local original_win = vim.api.nvim_get_current_win()
  local original_tab = vim.api.nvim_get_current_tabpage()
  local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
  local ft = vim.api.nvim_get_option_value("filetype", { buf = bufnr })

  local ours_lines, theirs_lines, base_lines = {}, {}, {}
  local inside_ours, inside_theirs, inside_base = false, false, false
  local is_diff3 = false -- Default to `2-way` mode.

  local in_conflict = false

  -- Traverse the buffer, remove conflict markers, and extract OURS / THEIRS / BASE content.
  for _, line in ipairs(lines) do
    if line:match("^<<<<<<<") then
      inside_ours, inside_theirs, inside_base = true, false, false -- Enter OURS section.
      in_conflict = true
    elseif line:match("^|||||||") then
      inside_ours, inside_base = false, true -- Enter BASE section (diff3 mode).
      is_diff3 = true
      in_conflict = true
    elseif line:match("^=======") then
      inside_ours, inside_theirs, inside_base = false, true, false  -- Switch to THEIRS section.
    elseif line:match("^>>>>>>>") then
      inside_ours, inside_theirs, inside_base = false, false, false -- End of conflict block.
      in_conflict = true
    else
      if inside_ours then
        table.insert(ours_lines, line)   -- Keep OURS content.
      elseif inside_theirs then
        table.insert(theirs_lines, line) -- Keep THEIRS content.
      elseif inside_base then
        table.insert(base_lines, line)   -- Keep BASE content.
      else
        -- Preserve non-conflicting content in all buffers.
        table.insert(ours_lines, line)
        table.insert(theirs_lines, line)
        table.insert(base_lines, line)
      end
    end
  end
  if not in_conflict then
    print("No Git conflict found!")
    return
  end

  -- Create OURS / THEIRS / BASE buffers.
  local ours_buf = vim.api.nvim_create_buf(false, true)
  local theirs_buf = vim.api.nvim_create_buf(false, true)
  local base_buf = is_diff3 and vim.api.nvim_create_buf(false, true) or nil

  -- Populate the buffers with extracted content.
  vim.api.nvim_buf_set_lines(ours_buf, 0, -1, false, ours_lines)
  vim.api.nvim_buf_set_lines(theirs_buf, 0, -1, false, theirs_lines)
  if base_buf then
    vim.api.nvim_buf_set_lines(base_buf, 0, -1, false, base_lines)
  end

  -- Set buffers as temporary.
  local diff_buffers = {
    { buf = ours_buf,   role = "OURS" },
    { buf = theirs_buf, role = "THEIRS" },
    { buf = base_buf,   role = "BASE" },
  }
  for _, info in ipairs(diff_buffers) do
    if info.buf then
      vim.api.nvim_set_option_value("bufhidden", "wipe", { buf = info.buf })
      vim.api.nvim_buf_set_keymap(info.buf, "n", "g?", "", {
        noremap = true,
        silent = true,
        callback = function()
          Nvim.DiffTool.show_help_window()
        end,
      })
      vim.api.nvim_buf_set_keymap(info.buf, "n", "<c-y>", "", {
        noremap = true,
        silent = true,
        callback = function()
          local buf_content = vim.api.nvim_buf_get_lines(info.buf, 0, -1, false)
          vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, buf_content)
          vim.notify("Replaced buffer with " .. info.role .. " content.", vim.log.levels.INFO)
        end,
      })
    end
  end

  -- Auto-close all buffers when one is closed.
  local function close_all_buffers()
    vim.schedule(function()
      for _, buf in ipairs({ ours_buf, theirs_buf, base_buf }) do
        if buf and vim.api.nvim_buf_is_valid(buf) then
          vim.api.nvim_buf_delete(buf, { force = true })
        end
      end
    end)
  end

  for _, buf in ipairs({ ours_buf, theirs_buf, base_buf }) do
    if buf then
      vim.api.nvim_create_autocmd("BufWinLeave", {
        buffer = buf,
        callback = function()
          close_all_buffers()
          vim.defer_fn(function()
            -- Make sure the original buffer still exists
            if not vim.api.nvim_buf_is_valid(original_buf) then return end

            -- Try to jump back to the original window ID (if it's still valid)
            if vim.api.nvim_win_is_valid(original_win) then
              -- Check if the original tab is correct, and jump to it
              local current_tab = vim.api.nvim_get_current_tabpage()
              if current_tab ~= original_tab then
                vim.cmd("tabnext " .. vim.api.nvim_tabpage_get_number(original_tab))
              end
              vim.api.nvim_set_current_win(original_win)
              vim.api.nvim_win_set_buf(original_win, original_buf)
              return
            end

            -- If the original window ID doesn't exist, try to find the buffer from the tab
            if vim.api.nvim_tabpage_is_valid(original_tab) then
              local found = false
              for _, win in ipairs(vim.api.nvim_tabpage_list_wins(original_tab)) do
                if vim.api.nvim_win_get_buf(win) == original_buf then
                  vim.api.nvim_set_current_win(win)
                  found = true
                  break
                end
              end

              if found then
                vim.cmd("tabnext " .. vim.api.nvim_tabpage_get_number(original_tab))
              end
            end
          end, 10) -- 10ms delay to ensure other `BufWinLeave` events complete first
        end,
      })
    end
  end

  -- Open a new tab for the diff view.
  vim.cmd("tab split")
  vim.cmd("vsplit") -- Split THEIRS on the right.
  local win_theirs = vim.api.nvim_get_current_win()
  vim.api.nvim_win_set_buf(win_theirs, theirs_buf)

  local help_hint = "(Apply: <c-y>, Help: g?)"
  local win_base = nil
  if base_buf then
    vim.cmd("split") -- Split BASE below.
    win_base = vim.api.nvim_get_current_win()
    vim.api.nvim_win_set_buf(win_base, base_buf)
    -- Set window titles.
    vim.api.nvim_set_option_value("winbar", "BASE " .. help_hint, { win = win_base })
  end

  vim.cmd("wincmd h") -- Move back to the left window.
  local win_ours = vim.api.nvim_get_current_win()
  vim.api.nvim_win_set_buf(win_ours, ours_buf)

  -- Set window titles.
  vim.api.nvim_set_option_value("winbar", "OURS " .. help_hint, { win = win_ours })
  vim.api.nvim_set_option_value("winbar", "THEIRS " .. help_hint, { win = win_theirs })

  local diff_wins = { win_ours, win_theirs }
  if win_base then
    table.insert(diff_wins, win_base)
  end
  -- Enable `diffthis` for all buffers.
  for _, win in ipairs(diff_wins) do
    if win and vim.api.nvim_win_is_valid(win) then
      vim.api.nvim_set_current_win(win)
      if ft and ft ~= "" then
        vim.cmd("setlocal filetype=" .. ft)
      end
      vim.cmd("diffthis")
    end
  end

  -- Set focus back to OURS window.
  vim.api.nvim_set_current_win(win_ours)
  print("Opened conflict diff view for all conflicts (mode: " .. (is_diff3 and "diff3" or "2way") .. ").")
end

function Nvim.DiffTool.show_help_window()
  local help_buf = vim.api.nvim_create_buf(false, true)
  local help_text = {
    "Git Conflict Resolution Help",
    "----------------------------",
    "g?   - Show this help window",
    "<c-y> - Apply OURS content to original file",
    "do   - Obtain (get) changes from the other side",
    "dp   - Put (apply) changes to the other side",
    "<Esc> - Close this window",
  }

  vim.api.nvim_buf_set_lines(help_buf, 0, -1, false, help_text)
  vim.bo[help_buf].modifiable = false

  local help_width = 50
  local help_height = #help_text + 2
  local row = math.floor((vim.o.lines - help_height) / 2)
  local col = math.floor((vim.o.columns - help_width) / 2)

  local help_opts = {
    style = "minimal",
    relative = "editor",
    width = help_width,
    height = help_height,
    row = row,
    col = col,
    border = "rounded",
  }

  local help_win = vim.api.nvim_open_win(help_buf, true, help_opts)

  vim.keymap.set("n", "<Esc>", function()
    vim.api.nvim_win_close(help_win, true)
  end, { noremap = true, silent = true, buffer = help_buf })
end

vim.api.nvim_create_user_command("ConflictDiff", Nvim.DiffTool.open_conflict_diff, {})
vim.api.nvim_create_user_command("ConflictAllDiff", Nvim.DiffTool.open_all_conflict_diff, {})

--- Check if filetype window exists
--- @return boolean true if filetype window is found, false otherwise
function Nvim.Buffer_check.is_current_tab_filetype_win_exists(filetype)
  for _, win_nr in ipairs({ 1, 2 }) do
    local buf_nr = vim.fn.winbufnr(win_nr)
    if buf_nr ~= -1 then
      local ft = vim.api.nvim_get_option_value("filetype", { buf = buf_nr })
      if ft == filetype then
        return true
      end
    end
  end
  return false
end

-- HACK: Avoid edgy.nvim layout conflict
function Nvim.Quickfix.open_quickfix_safety()
  vim.cmd("rightbelow copen")
  vim.cmd("wincmd J")
  vim.schedule(function()
    vim.cmd("resize 10")
  end)
end

function Nvim.Quickfix.open_loclist_safety()
  vim.cmd("rightbelow lopen")
  vim.cmd("wincmd J")
  vim.schedule(function()
    vim.cmd("resize 10")
  end)
end

function Nvim.Quickfix.toggle_quickfix_safety()
  local quickfix_open = false

  for _, win in ipairs(vim.fn.getwininfo()) do
    if win.quickfix == 1 then
      quickfix_open = true
      break
    end
  end

  if quickfix_open then
    vim.cmd("cclose")
  else
    Nvim.Quickfix.open_quickfix_safety()
  end
end

function Nvim.Quickfix.toggle_loclist_safety()
  local quickfix_open = false

  for _, win in ipairs(vim.fn.getwininfo()) do
    if win.quickfix == 1 then
      quickfix_open = true
      break
    end
  end

  if quickfix_open then
    vim.cmd("lclose")
  else
    Nvim.Quickfix.open_loclist_safety()
  end
end

function Nvim.DAP.insert_dap_configs(lang, configs)
  local dap = require("dap")
  if next(configs) then
    dap.configurations[lang] = dap.configurations[lang] or {}
    for _, config in ipairs(configs) do
      table.insert(dap.configurations[lang], config)
    end
  end
end

function Nvim.DAPUI.with_layout_handling_when_dapui_open(fn)
  return function(...)
    local dapui_scope_found = Nvim.Buffer_check.is_current_tab_filetype_win_exists("dapui_scopes")
    local current_side = require("user.edgy").view_side
    -- local current_side = vim.builtin.nvimtree.setup.view.side
    local new_side = dapui_scope_found and "right" or "left"

    -- Pre-execution layout handling
    if current_side ~= new_side then
      require("user.edgy").view_side = new_side
      require("user.edgy").swap_layouts()
    end

    -- Execute the wrapped function
    fn(current_side, new_side, ...)

    -- Post-execution dapui handling
    if dapui_scope_found then
      require("dapui").open({ reset = true })
    end
  end
end
