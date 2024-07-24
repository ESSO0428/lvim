local Path = require('plenary.path')
local config = require('session_manager.config')
local utils = require('session_manager.utils')
local config_group = vim.api.nvim_create_augroup('MyConfigGroup', {}) -- A global group for all your config autocommands

-- NOTE: Below is a fix for the `bufferline` pinning status, integrated with `neovim-session-manager`
-- `vim.api.nvim_buf_delete(buffer, { force = true })` can cause abnormal bufferline pinning status.
-- This issue mainly occurs when Neovim just starts and sources the session view.
-- `utils.first_load` is used to check if Neovim has just started.
-- If Neovim just started, `vim.api.nvim_buf_delete(buffer, { force = true })` is not executed.
-- After the first view load, the status is set to false.
-- On subsequent session loads, unnecessary buffers are closed.
utils.first_load = true       -- Initialization flag variable
utils.session_loading = false -- Indicates the session loading status to avoid triggering other plugins during session loading
function utils.load_session(filename, discard_current)
  utils.session_loading = true
  if not discard_current then
    -- Ask to save files in current session before closing them.
    for _, buffer in ipairs(vim.api.nvim_list_bufs()) do
      if vim.api.nvim_get_option_value('modified', { buf = buffer }) then
        local choice = vim.fn.confirm('The files in the current session have changed. Save changes?',
          '&Yes\n&No\n&Cancel')
        if choice == 3 or choice == 0 then
          return -- Cancel.
        elseif choice == 1 then
          vim.api.nvim_command("silent wall")
        end
        break
      end
    end
  end

  -- Delete all buffers first except the current one to avoid entering buffers scheduled for deletion.
  local current_buffer = vim.api.nvim_get_current_buf()
  if not utils.first_load then
    for _, buffer in ipairs(vim.api.nvim_list_bufs()) do
      if vim.api.nvim_buf_is_valid(buffer) and buffer ~= current_buffer then
        vim.api.nvim_buf_delete(buffer, { force = true })
      end
    end
  end
  vim.api.nvim_buf_delete(current_buffer, { force = true })

  -- Set the active session filename.
  utils.active_session_filename = filename

  local swapfile = vim.o.swapfile
  vim.o.swapfile = false
  vim.api.nvim_exec_autocmds('User', { pattern = 'SessionLoadPre' })
  vim.api.nvim_command('silent source ' .. filename)
  vim.api.nvim_exec_autocmds('User', { pattern = 'SessionLoadPost' })
  vim.o.swapfile = swapfile

  -- After the first call, set the flag variable to false
  utils.first_load = false
  utils.session_loading = false
end

vim.api.nvim_create_autocmd({ 'User' }, {
  pattern = "SessionLoadPost",
  group = config_group,
  callback = function()
    if lvim.builtin.nvimtree.active == false then
      session_open_neo_tree()
    else
      session_open_nvim_tree()
    end
  end,
})
local session_manager = require('session_manager')
local opt = {
  sessions_dir = Path:new(vim.fn.stdpath('data'), 'sessions'), -- The directory where the session files will be saved.
  path_replacer = '__',                                        -- The character to which the path separator will be replaced for session files.
  colon_replacer = '++',                                       -- The character to which the colon symbol will be replaced for session files.
  -- autoload_mode = require('session_manager.config').AutoloadMode.LastSession, -- Define what to do when Neovim is started without arguments. Possible values: Disabled, CurrentDir, LastSession
  autoload_mode = config.AutoloadMode.CurrentDir,              -- Define what to do when Neovim is started without arguments. Possible values: Disabled, CurrentDir, LastSession
  autosave_last_session = true,                                -- Automatically save last session on exit and on session switch.
  autosave_ignore_not_normal = true,                           -- Plugin will not save a session when no buffers are opened, or all of them aren't writable or listed.
  autosave_ignore_dirs = {},                                   -- A list of directories where the session will not be autosaved.
  autosave_ignore_filetypes = {                                -- All buffers of these file types will be closed before the session is saved.
    'gitcommit'
  },
  autosave_ignore_buftypes = {
    'terminal',
    'toggleterm'
  },                                -- All buffers of these bufer types will be closed before the session is saved.
  autosave_only_in_session = false, -- Always autosaves session. If true, only autosaves after a session is active.
  max_path_length = 80,             -- Shorten the display path if length exceeds this threshold. Use 0 if don't want to shorten the path at all.
}

if next(vim.fn.argv()) ~= nil then
  opt.autoload_mode = require('session_manager.config').AutoloadMode.Disabled
  opt.autosave_last_session = false
end
session_manager.setup(opt)
