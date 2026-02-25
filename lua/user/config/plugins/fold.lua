local M = {}
-- ufo folding
vim.opt.foldcolumn = "1"
vim.o.foldlevel = 99
vim.o.foldlevelstart = 99
vim.o.foldenable = true
vim.o.foldmethod = "manual"


-- Option 1: lsp settings

-- Option 2: nvim lsp as LSP client
-- Tell the server the capability of foldingRange,
-- Neovim hasn't added foldingRange to default capabilities, users must add it manually
-- vim.o.fillchars = [[eob: ,fold: ,foldopen:,foldsep: ,foldclose:]]

function M.setup()
  -- NOTE: foldingRange capability is injected in the main LSP setup.
  local ftMap = {
    vim = 'indent',
    -- python = { 'indent', 'treesitter' },
    python = { 'indent', 'marker' },
    git = ''
  }
  local aggregate_ftMap = {
    'python',
  }
  local empty_return_filetypes = {
    'org',
    'markdown',
    'copilot-chat',
    'Avante',
  }
  ---@param providers table|string List of providers to aggregate, e.g. {'indent', 'marker'}, or a string provider name
  local function aggregate_providers(providers)
    return function(buf)
      if type(providers) ~= 'table' then
        return providers
      end
      local ufo = require('ufo')
      local res = {}
      for _, provider in ipairs(providers) do
        local ok, folds = pcall(ufo.getFolds, buf, provider)
        if ok and folds then
          vim.list_extend(res, folds)
        end
      end
      return res
    end
  end
  local handler = function(virtText, lnum, endLnum, width, truncate)
    local newVirtText = {}
    local suffix = (' … 󱦶 %d '):format(endLnum - lnum)
    local sufWidth = vim.fn.strdisplaywidth(suffix)
    local targetWidth = width - sufWidth
    local curWidth = 0
    for _, chunk in ipairs(virtText) do
      local chunkText = chunk[1]
      local chunkWidth = vim.fn.strdisplaywidth(chunkText)
      if targetWidth > curWidth + chunkWidth then
        table.insert(newVirtText, chunk)
      else
        chunkText = truncate(chunkText, targetWidth - curWidth)
        local hlGroup = chunk[2]
        table.insert(newVirtText, { chunkText, hlGroup })
        chunkWidth = vim.fn.strdisplaywidth(chunkText)
        -- str width returned from truncate() may less than 2nd argument, need padding
        if curWidth + chunkWidth < targetWidth then
          suffix = suffix .. (' '):rep(targetWidth - curWidth - chunkWidth)
        end
        break
      end
      curWidth = curWidth + chunkWidth
    end
    table.insert(newVirtText, { suffix, 'MoreMsg' })
    return newVirtText
  end
  local opts = {
    fold_virt_text_handler = handler,
    provider_selector = function(bufnr, filetype, buftype)
      if vim.tbl_contains(empty_return_filetypes, filetype) then
        return ''
      end
      if vim.tbl_contains(aggregate_ftMap, filetype) then
        return aggregate_providers(ftMap[filetype])
      end
      -- if you prefer treesitter provider rather than lsp,
      -- return ftMap[filetype] or {'treesitter', 'indent'}
      return ftMap[filetype]
    end,
    preview = {
      mappings = {
        scrollU = '<C-u>',
        scrollD = '<C-o>',
        jumpTop = 'gg',
        jumpBot = 'G',
        switch = 'u'
      }
    },
  }
  require('ufo').setup(opts)

  -- global handler
  -- `handler` is the 2nd parameter of `setFoldVirtTextHandler`,
  -- check out `./lua/ufo.lua` and search `setFoldVirtTextHandler` for detail.
  -- require('ufo').setup({
  --   fold_virt_text_handler = handler
  -- })

  -- buffer scope handler
  -- will override global handler if it is existed
  -- local bufnr = vim.api.nvim_get_current_buf()
  -- require('ufo').setFoldVirtTextHandler(bufnr, handler)

  vim.api.nvim_create_autocmd("OptionSet", {
    pattern = "foldmarker",
    callback = function()
      require("ufo").enableFold()
    end
  })
  vim.api.nvim_create_autocmd("BufEnter", {
    pattern = "*",
    callback = function()
      if vim.api.nvim_buf_get_name(0):match("UfoPreviewFloatWin") then
        vim.opt_local.list = false
        require("ufo").attach()
        require("ufo").enableFold()
        vim.cmd('normal! zX')
      else
        if vim.wo.foldenable then
          require("ufo").enableFold()
        end
      end
    end
  })
end

local function apply_marker_and_fold(action)
  local buf = vim.api.nvim_get_current_buf()
  local ft = vim.bo[buf].filetype
  local marker = Nvim.builtin.FtFoldMarker[ft]

  marker = (type(marker) == "string" and marker:find(",")) and marker or "{{{,}}}"

  local marker_start = vim.split(marker, ",")[1]
  local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)

  for row, line in ipairs(lines) do
    if line:find(marker_start, 1, true) then
      if action == "close" then
        pcall(vim.cmd, row .. "foldclose")
      elseif action == "open" then
        pcall(vim.cmd, row .. "foldopen")
      end
    end
  end
end

lvim.keys.normal_mode["<leader>Om"] = {
  function() apply_marker_and_fold("close") end,
  desc = "Close all filetype markers (ufo)",
}

lvim.keys.normal_mode["<leader>OM"] = {
  function() apply_marker_and_fold("open") end,
  desc = "Open all filetype markers (ufo)",
}

return M
