lvim.builtin.nvimtree.active = true -- NOTE: using neo-tree
require "user.integrated.TermForNvimTree"
function open_nvim_tree()
  -- open the tree
  -- if vim.g.SessionLoad then return end
  if vim.bo.filetype ~= "alpha" and vim.bo.filetype ~= "lir" and next(vim.fn.argv()) ~= nil then
    require("nvim-tree.api").tree.toggle(false, true)
    -- vim.cmd([[wincmd w]])
  end
end

function session_open_nvim_tree()
  -- open the tree
  require("nvim-tree.api").tree.toggle(false, true)
  -- vim.cmd([[wincmd w]])
end

function float_term(...)
  local args = { ... }
  local state = nil
  if select("#", ...) > 0 then
    state = args[1]
  end
  nvimtreeToggleTerm("float", state)
end

function horizontal_term(...)
  local args = { ... }
  local state = nil
  if select("#", ...) > 0 then
    state = args[1]
  end
  nvimtreeToggleTerm("horizontal", state)
end

function horizontal_termFzfRg(...)
  local args = { ... }
  local state = nil
  if select("#", ...) > 0 then
    state = args[1]
  end
  nvimtreeToggleTermFzfRg("horizontal", state)
end

function float_termRanger(...)
  local args = { ... }
  local state = nil
  if select("#", ...) > 0 then
    state = args[1]
  end
  nvimtreeToggleTermRanger("float", state)
end

function vertical_term(...)
  local args = { ... }
  local state = nil
  if select("#", ...) > 0 then
    state = args[1]
  end
  nvimtreeToggleTerm("vertical", state)
end

function CderOpen(...)
  local args = { ... }
  local state = nil
  if select("#", ...) > 0 then
    state = args[1]
  end
  nvimtreeCder("", state)
end

function ToDoOpen(...)
  local args = { ... }
  local state = nil
  if select("#", ...) > 0 then
    state = args[1]
  end
  nvimtreeToDoTelescope("", state)
end

function wsl_system_open_dir()
  local node = require("nvim-tree.lib").get_node_at_cursor()
  local abspath = node.link_to or node.absolute_path
  -- local abspath = node.path
  local is_folder = node.open ~= nil
  local basedir = is_folder and abspath or vim.fn.fnamemodify(abspath, ":h")
  local path = abspath

  -- macOs: open file in default application in the background.
  -- Probably you need to adapt the Linux recipe for manage path with spaces. I don't have a mac to try.
  vim.api.nvim_command("silent !open -g " .. basedir)
  -- Linux: open file in default application
  -- vim.api.nvim_command(string.format("silent !xdg-open '%s'", path))
  -- 檢查是否可以找到 explorer.exe
  local explorer_exists = vim.fn.executable('explorer.exe') == 1
  if explorer_exists then
    -- vim.api.nvim_command(string.format("silent !explorer.exe `wslpath -w '%s'`", path))
    vim.api.nvim_command(string.format("silent !explorer.exe `wslpath -w '%s'`", basedir))
  else
    -- 否則，使用 xdg-open 打開文件夾
    vim.api.nvim_command(string.format("silent !xdg-open '%s'", basedir))
  end
end

function wsl_system_open()
  local node = require("nvim-tree.lib").get_node_at_cursor()
  local abspath = node.link_to or node.absolute_path
  -- local abspath = node.path
  local is_folder = node.open ~= nil
  local basedir = is_folder and abspath or vim.fn.fnamemodify(abspath, ":h")
  local path = abspath

  -- macOs: open file in default application in the background.
  -- Probably you need to adapt the Linux recipe for manage path with spaces. I don't have a mac to try.
  vim.api.nvim_command("silent !open -g " .. path)
  -- Linux: open file in default application
  -- vim.api.nvim_command(string.format("silent !xdg-open '%s'", path))
  local explorer_exists = vim.fn.executable('explorer.exe') == 1
  -- 檢查是否可以找到 explorer.exe
  if explorer_exists then
    -- vim.api.nvim_command(string.format("silent !explorer.exe `wslpath -w '%s'`", path))
    vim.api.nvim_command(string.format("silent !explorer.exe `wslpath -w '%s'`", path))
  else
    -- 否則，使用 xdg-open 打開文件夾
    vim.api.nvim_command(string.format("silent !xdg-open '%s'", path))
  end
end

function NvimTreeFilePreview(...)
  local file_preview = require "user.integrated.FilePreviewNvimTree"
  local args = { ... }
  local state = nil
  if select("#", ...) > 0 then
    state = args[1]
  end
  file_preview.toggle_file_info(state)
end

if lvim.builtin.nvimtree.active == false then
else
  local function on_attach(bufnr)
    local api = require "nvim-tree.api"
    local function opts(desc)
      return { desc = "nvim-tree: " .. desc, buffer = bufnr, noremap = true, silent = true, nowait = true }
    end

    api.config.mappings.default_on_attach(bufnr)
    vim.keymap.set('n', 'J', 'Unbind', { buffer = bufnr })
    vim.keymap.del('n', 'J', { buffer = bufnr })
    vim.keymap.set('n', 'I', 'Unbind', { buffer = bufnr })
    vim.keymap.del('n', 'I', { buffer = bufnr })
    vim.keymap.set('n', 'K', 'Unbind', { buffer = bufnr })
    vim.keymap.del('n', 'K', { buffer = bufnr })
    vim.keymap.set('n', 'S', 'Unbind', { buffer = bufnr })
    vim.keymap.del('n', 'S', { buffer = bufnr })
    vim.keymap.set('n', 'U', 'Unbind', { buffer = bufnr })
    vim.keymap.del('n', 'U', { buffer = bufnr })
    vim.keymap.set('n', 'bmv', 'Unbind', { buffer = bufnr })
    vim.keymap.del('n', 'bmv', { buffer = bufnr })
    vim.keymap.set('n', 's', 'Unbind', { buffer = bufnr })
    vim.keymap.del('n', 's', { buffer = bufnr })
    vim.keymap.set('n', 'R', 'Unbind', { buffer = bufnr })
    vim.keymap.del('n', 'R', { buffer = bufnr })
    vim.keymap.set('n', '>', 'Unbind', { buffer = bufnr })
    vim.keymap.del('n', '>', { buffer = bufnr })
    vim.keymap.set('n', '<', 'Unbind', { buffer = bufnr })
    vim.keymap.del('n', '<', { buffer = bufnr })
    vim.keymap.set('n', 'F', 'Unbind', { buffer = bufnr })
    vim.keymap.del('n', 'F', { buffer = bufnr })
    vim.keymap.set('n', 'R', 'Unbind', { buffer = bufnr })
    vim.keymap.del('n', 'R', { buffer = bufnr })
    vim.keymap.set('n', 'm', 'Unbind', { buffer = bufnr })
    vim.keymap.del('n', 'm', { buffer = bufnr })
    vim.keymap.set('n', 'H', 'Unbind', { buffer = bufnr })
    vim.keymap.del('n', 'H', { buffer = bufnr })
    vim.keymap.set('n', 'r', 'Unbind', { buffer = bufnr })
    vim.keymap.del('n', 'r', { buffer = bufnr })

    local useful_keys = {
      ["l"] = { api.node.open.edit, opts "Open" },
      ["o"] = { api.node.open.edit, opts "Open" },
      ["<CR>"] = { api.node.open.edit, opts "Open" },
      ["b"] = { api.tree.toggle_no_buffer_filter, opts "Toggle No Buffer" },
      ["gi"] = { api.node.navigate.sibling.first, opts "First Sibling" },
      ["gk"] = { api.node.navigate.sibling.last, opts "Last Sibling" },
      ["t"] = { api.marks.toggle, opts "Toggle Bookmark" },
      -- ["<leader>t"] = { api.marks.bulk.move, opts "Move Bookmarked" },
      ["<a-u>"] = { api.node.show_info_popup, opts "Info" },
      ["gh"] = { NvimTreeFilePreview, opts "File Preview" },
      ["<a-l>"] = { api.node.open.vertical, opts "Open: Vertical Split" },
      ["<a-k>"] = { api.node.open.horizontal, opts "Open: Horizontal Split" },
      ["h"] = { api.node.navigate.parent_close, opts "Close Directory" },
      ["zh"] = { api.tree.toggle_hidden_filter, opts "Toggle Dotfiles" },
      ["<c-r>"] = { api.fs.rename_sub, opts "Rename: Omit Filename" },
      ["e"] = { api.fs.rename_basename, opts "Rename: Basename" },
      ["C"] = { api.tree.change_root_to_node, opts "CD" },
      ["<a-o>"] = { wsl_system_open_dir, opts "wsl_system_open_dir" },
      ["<leader><a-o>"] = { wsl_system_open, opts "wsl_system_open" },
      ["<leader>sf"] = { telescope_find_files, opts "Telescope Find File" },
      ["<leader>sF"] = { telescope_file_browser, opts "Telescope File Browser" },
      ["<leader>sg"] = { telescope_live_grep, opts "Telescope Live Grep" },
      ["<leader>sG"] = { telescope_live_grep_args, opts "Telescope Live Grep (Args)" },
      ["<leader>sm"] = { telescope_media_files, opts "Telescope Find media" },
      ["<leader>sd"] = { CderOpen, opts "Telescope cder" },
      ["<leader>TT"] = { ToDoOpen, opts "Telescope todo" },
      ["<c-\\>"] = { float_term, opts "lvim_FloatTerm" },
      ["<leader><M-1>"] = { horizontal_term, opts "lvim_HterminalTerm" },
      ["<leader><M-2>"] = { vertical_term, opts "lvim_VerticalTerm" },
      ["<leader><M-3>"] = { float_term, opts "lvim_FloatTerm" },
      ["<leader><a-f>"] = { horizontal_termFzfRg, opts "lvim_HterminalTermFzfRg" },
      ["<leader>sr"] = { float_termRanger, opts "lvim_FloatTermRanger" },
      ["`"] = { api.tree.reload, opts "Refresh" },
      ["r"] = { api.fs.rename, opts "Rename" },
      ["<leader>g"] = { api.tree.toggle_gitignore_filter, opts "Toggle Git Ignore" },
    }

    require("lvim.keymappings").load_mode("n", useful_keys)
  end
  -- Add useful keymaps
  lvim.builtin.nvimtree.setup.on_attach = on_attach
end
