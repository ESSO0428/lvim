-- Snacks
-- Scratch File
-- raw toggle that supports count slots
vim.keymap.set("n", "<Plug>(snacks-scratch-raw)", function()
  Snacks.scratch()
end, { desc = "Snacks scratch raw toggle" })
local function open_scratch_manager()
  local scratches = Snacks.scratch.list()
  local unpack_items = table.unpack or unpack

  local function format_scratch_line(sc)
    local ft_label = sc.ft or "txt"
    local line = string.format("[%s] %s", ft_label, sc.name or "Scratch")
    if sc.cwd then line = line .. "  @ " .. vim.fn.fnamemodify(sc.cwd, ":~") end
    if sc.branch then line = line .. "  # " .. sc.branch end
    return line
  end

  local buf_lines = {}
  for _, sc in ipairs(scratches) do
    table.insert(buf_lines, format_scratch_line(sc))
  end

  local buf = vim.api.nvim_create_buf(false, true)
  pcall(vim.api.nvim_buf_set_name, buf, "Scratch_Manager")

  -- If no files exist, add a placeholder line to start input
  if #buf_lines == 0 then
    table.insert(buf_lines, "[markdown] new_scratch")
  end

  vim.api.nvim_buf_set_lines(buf, 0, -1, false, buf_lines)
  vim.bo[buf].modifiable = true
  vim.bo[buf].buftype = "acwrite"
  vim.bo[buf].bufhidden = "wipe"
  vim.bo[buf].modified = false

  local width = 80
  local height = math.min(20, math.max(10, #buf_lines + 2))
  local win = vim.api.nvim_open_win(buf, true, {
    relative = "editor",
    width = width,
    height = height,
    col = (vim.o.columns - width) / 2,
    row = (vim.o.lines - height) / 2,
    style = "minimal",
    border = "rounded",
    title = " Manage Scratches (<CR>: open, gh: preview toggle, edit freely, undo/redo, :w: apply) ",
    title_pos = "center",
  })

  local build_buffer_plan
  local parse_line

  local preview_enabled = false
  local preview_win = nil
  local preview_file = nil

  local function close_preview()
    preview_file = nil
    if preview_win then
      pcall(preview_win.hide, preview_win)
      preview_win = nil
    end
  end

  local function preview_target_at_cursor()
    local row = vim.api.nvim_win_get_cursor(win)[1]
    local current_lines, rows = build_buffer_plan()
    local line = current_lines[row] or ""
    local current_name = parse_line(line)
    if current_name == "" then
      return nil
    end
    local row_plan = rows[row]
    return row_plan and row_plan.kind == "existing" and row_plan.scratch or nil
  end

  local function preview_win_opts()
    local cfg = vim.api.nvim_win_get_config(win)
    local manager_width = cfg.width or width
    local manager_height = cfg.height or height
    local manager_col = math.floor(tonumber(cfg.col) or ((vim.o.columns - manager_width) / 2))
    local manager_row = math.floor(tonumber(cfg.row) or ((vim.o.lines - manager_height) / 2))
    local gap = 2
    local preview_col = manager_col + manager_width + gap
    local max_preview_width = math.min(100, math.max(20, vim.o.columns - 4))
    local right_space = vim.o.columns - preview_col - 2
    local preview_width = math.min(max_preview_width, math.max(20, right_space))
    preview_col = math.max(0, math.min(preview_col, vim.o.columns - preview_width - 2))

    local max_preview_height = math.max(8, vim.o.lines - 4)
    local desired_preview_height = math.max(manager_height + 6, math.floor(vim.o.lines * 0.7))
    local preview_height = math.min(desired_preview_height, max_preview_height)
    local preview_row = math.max(0, math.min(manager_row, vim.o.lines - preview_height - 2))

    return {
      style = "scratch",
      buf = nil,
      position = "float",
      enter = false,
      focusable = true,
      footer_keys = false,
      width = preview_width,
      height = preview_height,
      row = preview_row,
      col = preview_col,
    }
  end

  local function ensure_preview_buffer(scratch)
    local preview_buf = vim.fn.bufadd(scratch.file)
    if not vim.api.nvim_buf_is_loaded(preview_buf) then
      vim.fn.bufload(preview_buf)
    end

    vim.bo[preview_buf].buftype = ""
    vim.bo[preview_buf].bufhidden = "hide"
    vim.bo[preview_buf].buflisted = false
    vim.bo[preview_buf].swapfile = false
    vim.bo[preview_buf].modifiable = true
    vim.bo[preview_buf].readonly = false
    if scratch.ft and scratch.ft ~= "" then
      vim.bo[preview_buf].filetype = scratch.ft
    end

    if not vim.b[preview_buf].snacks_scratch_preview_autowrite then
      vim.b[preview_buf].snacks_scratch_preview_autowrite = true
      vim.api.nvim_create_autocmd("BufHidden", {
        group = vim.api.nvim_create_augroup("snacks_scratch_preview_autowrite_" .. preview_buf, { clear = true }),
        buffer = preview_buf,
        callback = function(ev)
          vim.api.nvim_buf_call(ev.buf, function()
            vim.cmd("silent! write")
            vim.bo[ev.buf].buflisted = false
          end)
        end,
      })
    end

    return preview_buf
  end

  local function update_preview()
    if not preview_enabled then
      return
    end

    local scratch = preview_target_at_cursor()
    if not scratch then
      close_preview()
      return
    end

    if preview_file == scratch.file and preview_win and preview_win:valid() then
      return
    end

    close_preview()
    preview_file = scratch.file
    local opts = preview_win_opts()
    opts.buf = ensure_preview_buffer(scratch)
    opts.title = string.format(" Scratch Preview: %s [%s] ", scratch.name or "Scratch", scratch.ft or "txt")
    preview_win = Snacks.win(opts):show()
  end

  local function scroll_preview(preview_keys, fallback_keys)
    local target_win = preview_win and preview_win:valid() and preview_win.win or nil
    local keys = preview_keys

    if not (target_win and vim.api.nvim_win_is_valid(target_win)) then
      target_win = win
      keys = fallback_keys or preview_keys
    end

    local termcodes = vim.api.nvim_replace_termcodes(keys, true, false, true)
    vim.api.nvim_win_call(target_win, function()
      vim.cmd.normal({ bang = true, args = { termcodes } })
    end)
  end

  local original_entries = {}
  for _, sc in ipairs(scratches) do
    table.insert(original_entries, { scratch = sc, line = format_scratch_line(sc) })
  end

  build_buffer_plan = function()
    local current_lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
    if #current_lines == 1 and vim.trim(current_lines[1]) == "" then
      current_lines = {}
    end
    local original_lines = {}
    for _, entry in ipairs(original_entries) do
      table.insert(original_lines, entry.line)
    end

    local original_text = #original_lines > 0 and (table.concat(original_lines, "\n") .. "\n") or ""
    local current_text = #current_lines > 0 and (table.concat(current_lines, "\n") .. "\n") or ""
    local hunks = vim.diff(original_text, current_text, { result_type = "indices" })

    local rows = {}
    local deleted = {}
    local original_row = 1
    local current_row = 1

    for _, hunk in ipairs(hunks) do
      local start_original, count_original, start_current, count_current = unpack_items(hunk)
      local hunk_original_row = math.max(start_original, 1)
      local hunk_current_row = math.max(start_current, 1)

      while original_row < hunk_original_row and current_row < hunk_current_row do
        rows[current_row] = { kind = "existing", scratch = original_entries[original_row].scratch }
        original_row = original_row + 1
        current_row = current_row + 1
      end

      local paired = math.min(count_original, count_current)
      for i = 0, paired - 1 do
        rows[hunk_current_row + i] = { kind = "existing", scratch = original_entries[hunk_original_row + i].scratch }
      end

      for i = paired, count_original - 1 do
        table.insert(deleted, original_entries[hunk_original_row + i].scratch)
      end

      for i = paired, count_current - 1 do
        rows[hunk_current_row + i] = { kind = "new" }
      end

      original_row = hunk_original_row + count_original
      current_row = hunk_current_row + count_current
    end

    while original_row <= #original_entries and current_row <= #current_lines do
      rows[current_row] = { kind = "existing", scratch = original_entries[original_row].scratch }
      original_row = original_row + 1
      current_row = current_row + 1
    end

    while original_row <= #original_entries do
      table.insert(deleted, original_entries[original_row].scratch)
      original_row = original_row + 1
    end

    while current_row <= #current_lines do
      rows[current_row] = { kind = "new" }
      current_row = current_row + 1
    end

    return current_lines, rows, deleted
  end

  -- Parse a line string to extract [filetype] and filename
  parse_line = function(line)
    line = vim.trim(line)
    local at_pos = line:find("  @ ")
    local hash_pos = line:find("  # ")
    local end_pos = #line

    if at_pos then end_pos = math.min(end_pos, at_pos - 1) end
    if hash_pos then end_pos = math.min(end_pos, hash_pos - 1) end

    local name_part = vim.trim(line:sub(1, end_pos))
    local ft = "markdown" -- default to markdown if [ft] not specified
    local ft_match = name_part:match("^%[(%w+)%]")
    if ft_match then
      ft = ft_match
      name_part = name_part:gsub("^%[%w+%]%s*", "")
    end

    return vim.trim(name_part), ft
  end

  -- Rename or change filetype
  local function do_rename(scratch, new_name, new_ft)
    if scratch.name == new_name and scratch.ft == new_ft then return scratch end

    local old_file = scratch.file
    local old_meta = scratch.file .. ".meta"
    local root_dir = vim.fn.fnamemodify(old_file, ":h")

    scratch.name = new_name
    scratch.ft = new_ft
    scratch.id = nil

    local key = { scratch.name }
    key[#key + 1] = scratch.count and tostring(scratch.count) or nil
    key[#key + 1] = scratch.cwd and scratch.cwd or nil
    key[#key + 1] = scratch.branch and scratch.branch or nil

    local hash = vim.fn.sha256(table.concat(key, "|")):sub(1, 8)
    local new_file = vim.fs.normalize(("%s/%s.%s"):format(root_dir, hash, scratch.ft))
    local new_meta = new_file .. ".meta"

    pcall(os.rename, old_file, new_file)
    pcall(os.rename, old_meta, new_meta)

    scratch.file = new_file
    local encoded = vim.json.encode(scratch)
    if type(encoded) == "string" then
      vim.fn.writefile(vim.split(encoded, "\n"), new_meta)
    end

    return scratch
  end

  -- Create a brand new scratch
  local function create_new_scratch(name, ft)
    -- Use the directory of existing scratches, or fall back to the default data dir
    local root_dir = original_entries[1] and vim.fn.fnamemodify(original_entries[1].scratch.file, ":h") or
        (vim.fn.stdpath("data") .. "/scratch")
    vim.fn.mkdir(root_dir, "p")

    local cwd = vim.fn.getcwd()
    local branch = nil
    if vim.fn.isdirectory(".git") == 1 then
      local out = vim.trim(vim.fn.systemlist("git branch --show-current")[1] or "")
      if vim.v.shell_error == 0 and out ~= "" then branch = out end
    end

    local key = { name, cwd, branch }
    local hash = vim.fn.sha256(table.concat(key, "|")):sub(1, 8)
    local new_file = vim.fs.normalize(("%s/%s.%s"):format(root_dir, hash, ft))
    local new_meta = new_file .. ".meta"

    local new_scratch = { name = name, ft = ft, file = new_file, cwd = cwd, branch = branch }

    -- Create the physical file and meta file
    if vim.fn.filereadable(new_file) == 0 then vim.fn.writefile({ "" }, new_file) end
    local encoded = vim.json.encode(new_scratch)
    if type(encoded) == "string" then vim.fn.writefile(vim.split(encoded, "\n"), new_meta) end

    return new_scratch
  end

  -- Keymap: <CR>
  vim.keymap.set("n", "<CR>", function()
    local row = vim.api.nvim_win_get_cursor(0)[1]
    local current_lines, rows = build_buffer_plan()
    local line = current_lines[row] or ""
    local current_name, current_ft = parse_line(line)

    if current_name == "" then return end

    local row_plan = rows[row]
    local scratch = row_plan and row_plan.kind == "existing" and row_plan.scratch or nil

    preview_enabled = false
    close_preview()
    vim.api.nvim_win_close(win, true)

    if scratch then
      scratch = do_rename(scratch, current_name, current_ft)
      Snacks.scratch.open({ file = scratch.file, ft = scratch.ft, name = scratch.name })
    else
      -- New line: hand directly to Snacks to open and create
      Snacks.scratch.open({ name = current_name, ft = current_ft })
    end
  end, { buffer = buf, desc = "Open Scratch" })

  vim.keymap.set("n", "gh", function()
    preview_enabled = not preview_enabled
    if preview_enabled then
      update_preview()
    else
      close_preview()
    end
  end, { buffer = buf, desc = "Toggle Scratch Preview" })

  vim.keymap.set("n", "<C-u>", function()
    scroll_preview("<C-u>")
  end, { buffer = buf, desc = "Scroll Preview Up" })

  vim.keymap.set("n", "<C-o>", function()
    scroll_preview("<C-d>", "<C-o>")
  end, { buffer = buf, desc = "Scroll Preview Down" })

  vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI", "TextChanged", "TextChangedI" }, {
    buffer = buf,
    callback = update_preview,
  })

  -- Event: :w batch save/create
  vim.api.nvim_create_autocmd("BufWriteCmd", {
    buffer = buf,
    callback = function()
      local lines, rows, deleted = build_buffer_plan()
      local saved_entries = {}
      local display_lines = {}

      for row, line in ipairs(lines) do
        local new_name, new_ft = parse_line(line)
        if new_name ~= "" then
          local row_plan = rows[row]
          local scratch = row_plan and row_plan.kind == "existing" and row_plan.scratch or nil
          if scratch then
            scratch = do_rename(scratch, new_name, new_ft)
          else
            scratch = create_new_scratch(new_name, new_ft)
          end

          table.insert(saved_entries, { scratch = scratch, line = format_scratch_line(scratch) })
          table.insert(display_lines, format_scratch_line(scratch))
        end
      end

      local deleted_count = 0
      for _, scratch in ipairs(deleted) do
        pcall(os.remove, scratch.file)
        pcall(os.remove, scratch.file .. ".meta")
        deleted_count = deleted_count + 1
      end

      original_entries = saved_entries

      if #display_lines == 0 then
        vim.api.nvim_buf_set_lines(buf, 0, -1, false, {})
      else
        vim.api.nvim_buf_set_lines(buf, 0, -1, false, display_lines)
      end

      vim.bo[buf].modified = false
      update_preview()
      if deleted_count > 0 then
        vim.notify(string.format("Scratch panel saved! Deleted %d scratch(es).", deleted_count), vim.log.levels.INFO)
      else
        vim.notify("Scratch panel saved!", vim.log.levels.INFO)
      end
    end
  })

  local close_ui = function()
    preview_enabled = false
    close_preview()
    vim.bo[buf].modified = false
    vim.cmd("close")
  end
  vim.keymap.set("n", "q", close_ui, { buffer = buf, desc = "Close" })
  vim.keymap.set("n", "<Esc>", close_ui, { buffer = buf, desc = "Close" })

  vim.api.nvim_create_autocmd("WinClosed", {
    pattern = tostring(win),
    once = true,
    callback = function()
      preview_enabled = false
      close_preview()
    end,
  })

  vim.api.nvim_create_autocmd("BufWipeout", {
    buffer = buf,
    callback = function()
      preview_enabled = false
      close_preview()
    end
  })
end

lvim.keys.normal_mode["<leader>r."] = {
  function()
    Snacks.scratch.open({
      name = vim.fn.expand("%:."),
      ft = "markdown",
    })

    vim.schedule(function()
      pcall(vim.cmd, "FloatIntoCurrent")
    end)

    vim.schedule(function()
      local ft = vim.bo.filetype
      local marker = Nvim.builtin.FtFoldMarker[ft]
      if marker and type(marker) == "string" and marker:find(",") then
        vim.opt_local.foldmarker = marker
      end
    end)
  end,
  desc = "Quick Note (current window)",
}

lvim.keys.normal_mode["<leader>."] = {
  function()
    local function prompt_key(lines)
      vim.cmd("redraw!")
      return Nvim.Menu.menu_getkeys(lines)
    end

    local function prompt_text(prompt, default)
      vim.cmd("redraw!")
      local value = vim.fn.input(prompt, default or "")
      vim.cmd("redraw!")
      return vim.trim(value)
    end

    local lines = {
      "Scratch Command:",
      "----------------------------------",
      "  .   → note to current",
      "  d   → NOTE scratch to current",
      "  <   → quick note (float)",
      "  w   → manage scratches UI",
      "  i/j/k/l → top/bottom/left/right",
      "  n/<CR> → new scratch",
      "  q → cancel",
      "----------------------------------",
      "Press key: ",
    }

    local cmd = prompt_key(lines)
    local pos = { i = "top", k = "bottom", j = "left", l = "right" }

    -- normalize <CR>
    if cmd == "" then cmd = "n" end

    if cmd == "q" then
      return
    end

    if cmd == "w" then
      open_scratch_manager()
      return
    end

    if cmd == "d" then
      Snacks.scratch.open({
        name = "NOTE",
        ft = "markdown",
        win = { position = "float" },
      })

      vim.schedule(function()
        pcall(vim.cmd, "FloatIntoCurrent")
      end)

      vim.schedule(function()
        local ft = vim.bo.filetype
        local marker = Nvim.builtin.FtFoldMarker[ft]
        if marker and type(marker) == "string" and marker:find(",") then
          vim.opt_local.foldmarker = marker
        end
      end)

      return
    end

    -- quick note
    if cmd == "." or cmd == "<" or pos[cmd] then
      local position = "float"

      if cmd == "<" then
        position = "float" -- 先 float，再 dock
      elseif pos[cmd] then
        position = pos[cmd]
      end

      Snacks.scratch.open({
        name = vim.fn.expand("%:."),
        ft = "markdown",
        win = { position = position },
      })

      if cmd == "." then
        vim.schedule(function()
          pcall(vim.cmd, "FloatIntoCurrent")
        end)
      end

      vim.schedule(function()
        local ft = vim.bo.filetype
        local marker = Nvim.builtin.FtFoldMarker[ft]
        if marker and type(marker) == "string" and marker:find(",") then
          vim.opt_local.foldmarker = marker
        end
      end)

      return
    end

    -- only "n" goes to the create/new flow
    if cmd ~= "n" then
      return
    end
    local name = prompt_text("Scratch name (number/name/%/./>/</nothing): ")

    if name == "%" or name == "." then
      -- expand % early so all branches see final name
      name = vim.fn.expand("%:.")
    end

    local ExecuteSnackOpen = function(_) end

    if name:match("^%d+$") then
      -- number -> count slot scratch
      ExecuteSnackOpen = function(filename)
        local count = tonumber(filename)
        local keys = tostring(count) .. "<Plug>(snacks-scratch-raw)"
        vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes(keys, true, false, true), "n", false)
      end
    elseif name == "" then
      -- empty -> default toggle
      ExecuteSnackOpen = function(_)
        Snacks.scratch()
      end
    elseif name == "<" or name == ">" then
      ExecuteSnackOpen = function(mark)
        local filename = vim.fn.expand("%:.")
        local mode = {
          ["<"] = "float",
          [">"] = "n"
        }
        local choice = mode[mark]
        local position = (choice == "n" or choice == ".") and "float" or (pos[choice] or "float")
        Snacks.scratch.open({
          name = filename,
          win = { position = position },
        })
        return choice
      end
    else
      -- named scratch (ask ft)
      ExecuteSnackOpen = function(filename)
        local ft = prompt_text("Filetype (markdown/lua/python/./...): ")
        local mode = prompt_key({ "Window? [Enter]=float, [n/.]=current, i,k,j,l:top/bottom/left/right: " })
        mode = vim.trim(mode):lower()

        if mode == "" then mode = "n" end
        if ft == "" or ft == "." then
          ft = nil
        end
        local pos = { i = "top", k = "bottom", j = "left", l = "right" }

        -- "n" is always float first (then FloatIntoCurrent)
        local position = (mode == "n" or mode == ".") and "float" or (pos[mode] or "float")
        Snacks.scratch.open({
          name = filename,
          ft = ft,
          win = { position = position },
        })
        return mode
      end
    end

    -- MUST run for all paths
    if name:match("^%d+$") or name == "" then
      ExecuteSnackOpen(name)
    else
      local mode = ExecuteSnackOpen(name)
      if mode == "n" or mode == "." then
        vim.schedule(function()
          pcall(vim.cmd, "FloatIntoCurrent")
        end)
      end
    end

    vim.schedule(function()
      local ft = vim.bo.filetype
      local marker = Nvim.builtin.FtFoldMarker[ft]
      if marker and type(marker) == "string" and marker:find(",") then
        vim.opt_local.foldmarker = marker
      end
    end)
  end,
  desc = "Create Scratch (named)",
}

lvim.keys.normal_mode["<leader>>"] = {
  "<cmd>lua Snacks.scratch.select()<cr>",
  desc = "Select Scratch Buffer",
}
