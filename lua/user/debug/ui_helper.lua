local dap_ui_mappings = lvim.builtin.dap.ui.config.mappings

local function cmd_to_string(cmd)
  if type(cmd) == "table" then
    return vim.inspect(cmd)
  else
    return tostring(cmd)
  end
end

local function mappings_to_string(mappings)
  local result = {}
  for key, cmd in pairs(mappings) do
    table.insert(result, key .. " -> " .. cmd_to_string(cmd))
  end
  return table.concat(result, "\n")
end

local function show_mappings_in_float()
  local buf = vim.api.nvim_create_buf(false, true)
  local mappings_str = mappings_to_string(dap_ui_mappings)

  vim.api.nvim_buf_set_lines(buf, 0, -1, false, vim.split(mappings_str, "\n"))

  -- Get the position of the dapui window
  local dap_win_id = vim.fn.win_getid()
  local win_pos = vim.fn.win_screenpos(dap_win_id)
  local dap_row = win_pos[1]
  local dap_col = win_pos[2]

  local win_width = 50
  local win_height = 7

  -- set the row and col of the float win, based on the position of the dapui win
  local row = dap_row
  local col = dap_col + 15

  local opts = {
    style    = "minimal",
    relative = "editor",
    width    = win_width,
    height   = win_height,
    row      = row,
    col      = col,
    border   = "rounded"
  }
  vim.api.nvim_buf_set_keymap(buf, 'n', 'q', '<Cmd>q<CR>', { noremap = true, silent = true })
  vim.api.nvim_open_win(buf, true, opts)
end

local dapui_filetypes = {
  "dapui_scopes",
  "dapui_breakpoints",
  "dapui_stacks",
  "dapui_watches"
}

for _, filetype in ipairs(dapui_filetypes) do
  vim.api.nvim_create_autocmd("FileType", {
    pattern = filetype,
    callback = function()
      vim.keymap.set('n', 'g?', show_mappings_in_float, { buffer = true, silent = true })
    end,
  })
end
