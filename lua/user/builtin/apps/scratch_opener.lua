local M = {}

-- Store opened buffers as a Set (key-value pair)
local opened_buffers = {}

-- Function to create an editable floating scratch buffer
function M.open_scratch()
  local buf = vim.api.nvim_create_buf(false, true) -- Create buffer
  vim.bo[buf].buftype = "nofile"
  vim.bo[buf].modifiable = true
  vim.bo[buf].filetype = "scratch"

  -- Floating window options
  local width = math.floor(vim.o.columns * 0.6)
  local height = math.floor(vim.o.lines * 0.5)
  local row = math.floor((vim.o.lines - height) / 2)
  local col = math.floor((vim.o.columns - width) / 2)

  local opts = {
    style = "minimal",   -- Minimal UI (no borders, status line, etc.)
    relative = "editor", -- Relative to the full editor
    width = width,
    height = height,
    row = row,
    col = col,
    border = "rounded" -- Rounded border (can be changed to "single", "double", "solid", "shadow" etc)
  }

  local win = vim.api.nvim_open_win(buf, true, opts)

  -- Enable line numbers in floating window
  vim.wo[win].number = true
  vim.wo[win].winbar = "Open Buffers"

  -- Key mappings for floating window
  local key_opts = { noremap = true, silent = true, buffer = buf }

  -- Enter to open files
  vim.keymap.set("n", "<CR>", function()
    M.open_files(win)
  end, key_opts)

  -- Esc to close window
  vim.keymap.set("n", "<Esc>", function()
    vim.api.nvim_win_close(win, true)
  end, key_opts)

  -- Make sure it closes properly in insert mode
  vim.keymap.set("i", "<Esc>", function()
    vim.cmd("stopinsert")
    vim.api.nvim_win_close(win, true)
  end, key_opts)

  -- Bind g? to open a floating help window
  vim.keymap.set("n", "g?", function()
    M.show_help_window()
  end, key_opts)
end

-- Function to show a floating help window
function M.show_help_window()
  local help_buf = vim.api.nvim_create_buf(false, true) -- Create buffer
  local help_text = {
    "Scratch Opener Help",
    "----------------------------",
    "g?   - Show this help window",
    "<CR> - Open all listed files",
    "<Esc> - Close this window",
  }

  vim.api.nvim_buf_set_lines(help_buf, 0, -1, false, help_text)
  vim.bo[help_buf].modifiable = false

  local help_width = 40
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

  -- Bind Esc to close help window
  vim.keymap.set("n", "<Esc>", function()
    vim.api.nvim_win_close(help_win, true)
  end, { noremap = true, silent = true, buffer = help_buf })
end

-- Function to open files from the scratch buffer **in background**
function M.open_files(win)
  -- Get the content of the buffer
  local buf = vim.api.nvim_win_get_buf(win)
  local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)

  local files_to_open = {}
  -- Open each file in the background
  for _, line in ipairs(lines) do
    line = line:gsub("%s+$", "")
    if line ~= "" and not line:match("^%s*%-%-") then
      local file = vim.fn.fnameescape(line)
      if vim.loop.fs_stat(file) then
        vim.cmd("silent! badd " .. file)
        table.insert(files_to_open, file)
      else
        vim.notify("File not found: " .. file, vim.log.levels.WARN)
      end
    end
  end
  for _, file in ipairs(files_to_open) do
    vim.cmd("silent! buffer " .. file)
    vim.wo.number = vim.opt_global.number:get()
    vim.wo.relativenumber = vim.opt_global.relativenumber:get()
    vim.wo.cursorline = vim.opt_global.cursorline:get()
    vim.opt.signcolumn = vim.opt_global.signcolumn:get()
    vim.wo.foldcolumn = vim.opt_global.foldcolumn:get()
    vim.wo.wrap = vim.opt_global.wrap:get()
    pcall(function() require('statuscol').setup() end)
  end

  -- Close floating window
  vim.api.nvim_win_close(win, true)
end

return M
