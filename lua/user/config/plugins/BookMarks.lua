vim.cmd "au ColorScheme * hi link BookMarksAdd Normal"

local function get_path_sep()
  if jit then
    if jit.os == "Windows" then
      return '\\'
    else
      return '/'
    end
  else
    return package.config:sub(1, 1)
  end
end
local function ensure_directory_exists(dir_path)
  if vim.fn.exists(dir_path) == 0 or vim.fn.isdirectory(dir_path) == 0 then
    -- similar to mkdir -p
    vim.fn.mkdir(dir_path, "p")
  end
end
local function get_bookmark_path()
  local path_sep = get_path_sep()
  local base_filename = vim.fn.getcwd()

  if jit and jit.os == 'Windows' then
    base_filename = base_filename:gsub(':', '_')
  end
  -- nvim_bookmarks restore directory
  local bookmark_dir = vim.fn.stdpath('data') .. path_sep .. "nvim_bookmarks"
  -- check if the directory exists, if not, create it
  ensure_directory_exists(bookmark_dir)

  return bookmark_dir .. path_sep .. base_filename:gsub(path_sep, '_') .. '.json'
end
local bookmark_file_path = get_bookmark_path()
require("bookmarks").setup {
  -- sign_priority = 8,  --set bookmark sign priority to cover other sign
  -- save_file = vim.fn.expand "$HOME/.bookmarks", -- bookmarks save file path
  save_file = bookmark_file_path,
  keywords = {
    ["@t"] = "☑️", -- mark annotation startswith @t ,signs this icon as `Todo`
    ["@w"] = "⚠️", -- mark annotation startswith @w ,signs this icon as `Warn`
    ["@f"] = "🐞", -- mark annotation startswith @f ,signs this icon as `Fix`
    ["@n"] = "󰍨 ", -- mark annotation startswith @n ,signs this icon as `Note`
  },
  on_attach = function(bufnr)
    local bm = require "bookmarks"
    local bm_actions = require "bookmarks.actions"
    local map = vim.keymap.set
    map("n", "mm", bm.bookmark_toggle) -- add or remove bookmark at current line
    map("n", "ma", bm.bookmark_ann)    -- add or edit mark annotation at current line
    map("n", "mc", bm.bookmark_clean)  -- clean all marks in local buffer

    -- Save all bookmarks to the bookmarks file.
    -- This prevents data loss in case of an unexpected Neovim closure.
    -- NOTE: Bookmarks are auto-saved by VimLeavePre by default.)
    map("n", "ms", bm_actions.saveBookmarks)

    map("n", "mk", bm.bookmark_next) -- jump to next mark in local buffer
    map("n", "mi", bm.bookmark_prev) -- jump to previous mark in local buffer
    map("n", "ml", bm.bookmark_list) -- show marked file list in quickfix window
  end,
  signs = {
    ann = { hl = "BookMarksAnn", text = "🔖", numhl = "BookMarksAnnNr", linehl = "BookMarksAnnLn" },
  }
}
lvim.keys.normal_mode['-'] = "<cmd>Telescope bookmarks list<cr>"
