local M = {}

function M.setup()
  local success, msg = pcall(function()
    require('mkdnflow').setup({
      new_file_template = {
        use_template = true,
        template = [[
---
title: {{ title }}
author: Andy6
date: {{ date }}
filename: {{ filename }}
---
]],
        placeholders = {
          before = {
            date = function()
              return os.date("%A, %B %d, %Y") -- Wednesday, March 1, 2023
            end
          },
          after = {
            filename = function()
              return vim.api.nvim_buf_get_name(0)
            end
          }
        }
      },
      to_do = {
        symbols = { ' ', 'x' },
        update_parents = true,
        not_started = ' ',
        complete = 'x'
      },
      create_dirs = false,
      hijack_dirs = true,
      mappings = {
        -- MkdnEnter = { { 'i', 'n', 'v' }, '<CR>' }, -- This monolithic command has the aforementioned
        MkdnEnter                   = false,
        -- insert-mode-specific behavior and also will trigger row jumping in tables. Outside
        -- of lists and tables, it behaves as <CR> normally does.
        MkdnNewListItem             = { 'i', '<CR>' }, -- Use this command instead if you only want <CR> in
        -- insert mode to add a new list item (and behave as usual outside of lists).
        -- MkdnFollowLink              = { 'n', '<a-o>' },
        MkdnFollowLink              = false, -- integrated with lsp gd (when lsp gd not work will use this)
        MkdnDestroyLink             = false,
        MkdnCreateLinkFromClipboard = false,
        MkdnNextLink                = false,
        MkdnPrevLink                = false,
        MkdnToggleToDo              = { { 'n', 'v' }, 'gS' },
        MkdnNewListItemAboveInsert  = false,
        MkdnNewListItemBelowInsert  = { 'n', '<leader>oh' },
        MkdnIncreaseHeading         = { 'n', '<a-<>' },
        MkdnDecreaseHeading         = { 'n', '<a->>' },
        -- MkdnNextHeading             = { 'n', '}' },
        MkdnNextHeading             = { 'n', 'gk' },
        -- MkdnPrevHeading             = { 'n', '{' },
        MkdnPrevHeading             = { 'n', 'gi' },
        -- MkdnFoldSection = false,
        MkdnFoldSection             = { 'n', '<tab>' },
        -- MkdnUnfoldSection = false,
        -- MkdnUnfoldSection           = { 'n', '<S-tab>' },
        MkdnFoldCycle               = { 'n', '<S-tab>' },
        MkdnYankFileAnchorLink      = false,
        MkdnYankAnchorLink          = false,
        MkdnMoveSource              = false,
        MkdnTableNextCell           = false,
        MkdnTablePrevCell           = false,
        MkdnTagSpan                 = false,
        MkdnTableNewRowBelow        = false,
        MkdnTableNewRowAbove        = false,
        MkdnTableNewColAfter        = false,
        MkdnTableNewColBefore       = false,
        -- MkdnUpdateNumbering = { 'n', '<leader>rr' }
      },
    })
  end)
  if not success then
    print("Error setting up mkdnflow")
  end
end

local function markdown_go_to_definition()
  local params = vim.lsp.util.make_position_params()
  local function is_url(text)
    local pattern = "^(https?://.+)$"
    return text:match(pattern) ~= nil
  end
  -- Treesitter check if current node is a link
  local ts_utils = require('nvim-treesitter.ts_utils')
  local node = ts_utils.get_node_at_cursor()
  local function get_node_text(node)
    local bufnr = vim.api.nvim_get_current_buf()
    return vim.treesitter.get_node_text(node, bufnr)
  end

  -- Check node type
  local link_text
  local link_url
  if node and node:type() == "link_text" then
    -- Get the next node
    local next_node = node:next_named_sibling()
    if next_node and next_node:type() == "link_destination" then
      link_text = get_node_text(next_node)
      if is_url(link_text) then
        link_url = link_text
      end
    end
  elseif node and node:type() == "link_destination" then
    link_text = get_node_text(node)
    if is_url(link_text) then
      link_url = link_text
    end
  end
  if link_url then
    vim.ui.open(link_url)
    return
  end

  vim.lsp.buf_request(0, 'textDocument/definition', params, function(err, result, ctx, config)
    if err then
      vim.api.nvim_echo({ { "LSP error: " .. err.message, "ErrorMsg" } }, true, {})
      return
    end

    if result and not vim.tbl_isempty(result) then
      if vim.islist(result) then
        vim.lsp.util.jump_to_location(result[1])
      else
        vim.lsp.util.jump_to_location(result)
      end
    else
      vim.api.nvim_echo({ { "LSP 'go to definition' failed, using MkdnFollowLink instead", "WarningMsg" } }, true, {})
      pcall(function()
        vim.api.nvim_command('MkdnFollowLink')
      end)
    end
  end)
end
vim.api.nvim_create_autocmd('FileType', {
  pattern = 'markdown',
  group = vim.api.nvim_create_augroup('markdown_only_keymap', { clear = true }),
  callback = function()
    vim.keymap.set('n', "<leader>uv", ':MarkdownHeadersClosest<cr>', { silent = true, buffer = true })
    vim.keymap.set('n', '<leader>o', '<Nop>', { silent = true, buffer = true })
    vim.keymap.set('n', '<leader>oo', 'za', { silent = true, buffer = true })
    vim.keymap.set('n', '<a-o>', markdown_go_to_definition, { silent = true, buffer = true })
  end,
})

-- NOTE: AI chat open link under cursor
vim.api.nvim_create_autocmd("FileType", {
  pattern = { "Avante*", "copilot-chat" },
  callback = function()
    vim.keymap.set("n", "<a-o>", function()
      Nvim.MarkDownTool.open_link("cfile")
    end, { buffer = true, desc = "Open file under cursor (cfile) in picked window" })
    vim.keymap.set("v", "<a-o>", ":<C-u>call v:lua.Nvim.MarkDownTool.open_link('visual')<cr>",
      { silent = true, buffer = true, desc = "Open file under cursor (visual) in picked window" })
    vim.keymap.set("n", "gh", function()
      Nvim.MarkDownTool.open_link("float")
    end, { buffer = true, desc = "Open file under cursor (cfile) in float window" })
    vim.keymap.set("v", "gh", ":<C-u>call v:lua.Nvim.MarkDownTool.open_link('float_visual')<cr>",
      { silent = true, buffer = true, desc = "Open file under cursor (visual) in float window" })
    vim.keymap.set("n", "g;", function()
      Nvim.MarkDownTool.open_link("cline")
    end, { buffer = true, desc = "Open file under cursor (cline) in picked window" })
    vim.keymap.set("n", "gp", function()
      Nvim.MarkDownTool.open_link("float_cline")
    end, { buffer = true, desc = "Open file under cursor (cline) in float window" })
  end,
})

vim.api.nvim_create_user_command('Date', 'silent! r! date +"\\%A, \\%B, \\%d, \\%Y"', { nargs = "*" })

return M
