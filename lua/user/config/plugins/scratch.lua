-- Snacks
-- Scratch File
-- raw toggle that supports count slots
vim.keymap.set("n", "<Plug>(snacks-scratch-raw)", function()
  Snacks.scratch()
end, { desc = "Snacks scratch raw toggle" })
local function open_scratch_manager()
  local scratches = Snacks.scratch.list()

  local buf_lines = {}
  for _, sc in ipairs(scratches) do
    local ft_label = sc.ft or "txt"
    local line = string.format("[%s] %s", ft_label, sc.name or "Scratch")
    if sc.cwd then line = line .. "  @ " .. vim.fn.fnamemodify(sc.cwd, ":~") end
    if sc.branch then line = line .. "  # " .. sc.branch end
    table.insert(buf_lines, line)
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
    title = " Manage Scratches (<CR>: open, dd: delete, :w: save/create) ",
    title_pos = "center",
  })

  local ns = vim.api.nvim_create_namespace("snacks_scratch_manager")
  local mark_to_scratch = {}

  -- Bind extmarks only to already existing scratches
  for i, sc in ipairs(scratches) do
    local mark_id = vim.api.nvim_buf_set_extmark(buf, ns, i - 1, 0, {})
    mark_to_scratch[mark_id] = sc
  end

  local function get_mark_and_scratch(row)
    local marks = vim.api.nvim_buf_get_extmarks(buf, ns, { row, 0 }, { row, -1 }, {})
    if #marks > 0 then
      local mark_id = marks[1][1]
      return mark_id, mark_to_scratch[mark_id]
    end
    return nil, nil
  end

  -- Parse a line string to extract [filetype] and filename
  local function parse_line(line)
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
  local function do_rename(mark_id, scratch, new_name, new_ft)
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

    mark_to_scratch[mark_id] = scratch
    return scratch
  end

  -- Create a brand new scratch
  local function create_new_scratch(name, ft)
    -- Use the directory of existing scratches, or fall back to the default data dir
    local root_dir = scratches[1] and vim.fn.fnamemodify(scratches[1].file, ":h") or
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
    local row = vim.api.nvim_win_get_cursor(0)[1] - 1
    local line = vim.api.nvim_get_current_line()
    local current_name, current_ft = parse_line(line)

    if current_name == "" then return end

    local mark_id, scratch = get_mark_and_scratch(row)
    if scratch then
      scratch = do_rename(mark_id, scratch, current_name, current_ft)
    end

    vim.api.nvim_win_close(win, true)

    if scratch then
      Snacks.scratch.open({ file = scratch.file, ft = scratch.ft, name = scratch.name })
    else
      -- New line: hand directly to Snacks to open and create
      Snacks.scratch.open({ name = current_name, ft = current_ft })
    end
  end, { buffer = buf, desc = "Open Scratch" })

  -- Keymap: dd
  vim.keymap.set("n", "dd", function()
    local row = vim.api.nvim_win_get_cursor(0)[1] - 1
    local _, scratch = get_mark_and_scratch(row)
    if scratch then
      pcall(os.remove, scratch.file)
      pcall(os.remove, scratch.file .. ".meta")
      vim.notify("Deleted Scratch: " .. scratch.name, vim.log.levels.INFO)
    end
    vim.api.nvim_buf_set_lines(buf, row, row + 1, false, {})
  end, { buffer = buf, desc = "Delete Scratch" })

  -- Event: :w batch save/create
  vim.api.nvim_create_autocmd("BufWriteCmd", {
    buffer = buf,
    callback = function()
      local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
      for row, line in ipairs(lines) do
        local new_name, new_ft = parse_line(line)
        if new_name ~= "" then
          local mark_id, scratch = get_mark_and_scratch(row - 1)
          if scratch then
            do_rename(mark_id, scratch, new_name, new_ft)
          else
            -- New line: create a new file and bind tracking
            local new_scratch = create_new_scratch(new_name, new_ft)
            local new_mark_id = vim.api.nvim_buf_set_extmark(buf, ns, row - 1, 0, {})
            mark_to_scratch[new_mark_id] = new_scratch

            -- Update the UI line to include the working directory, matching other entries
            if new_scratch.cwd then
              local display_line = string.format("[%s] %s  @ %s", new_ft, new_name,
                vim.fn.fnamemodify(new_scratch.cwd, ":~"))
              vim.api.nvim_buf_set_lines(buf, row - 1, row, false, { display_line })
            end
          end
        end
      end
      vim.bo[buf].modified = false
      vim.notify("Scratch panel saved!", vim.log.levels.INFO)
    end
  })

  local close_ui = function()
    vim.bo[buf].modified = false
    vim.cmd("close")
  end
  vim.keymap.set("n", "q", close_ui, { buffer = buf, desc = "Close" })
  vim.keymap.set("n", "<Esc>", close_ui, { buffer = buf, desc = "Close" })

  vim.api.nvim_create_autocmd("BufLeave", {
    buffer = buf,
    callback = function() vim.bo[buf].modified = false end
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
    local lines = {
      "Scratch Command:",
      "----------------------------------",
      "  .   → note to current",
      "  <   → quick note (float)",
      "  w   → manage scratches UI",
      "  i/j/k/l → top/bottom/left/right",
      "  n/<CR> → new scratch",
      "  q → cancel",
      "----------------------------------",
      "Press key: ",
    }

    local cmd = Nvim.Menu.menu_getkeys(lines)
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
    local name = Nvim.Menu.menu_getkeys({ "Scratch name (number/name/%/./>/</nothing): " })
    name = vim.trim(name)

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
        local position = (mode == "n" or mode == ".") and "float" or (pos[mode] or "float")
        Snacks.scratch.open({
          name = filename,
          win = { position = position },
        })
        return mode[mark]
      end
    else
      -- named scratch (ask ft)
      ExecuteSnackOpen = function(filename)
        local ft = Nvim.Menu.menu_getkeys({ "Filetype (markdown/lua/python/./...): " })
        local mode = Nvim.Menu.menu_getkeys({ "Window? [Enter]=float, [n/.]=current, i,k,j,l:top/bottom/left/right: " })
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
