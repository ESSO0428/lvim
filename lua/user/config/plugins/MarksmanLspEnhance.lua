-- NOTE: Code action for checking markdown links
-- local ts_utils = require 'nvim-treesitter.ts_utils'
local ns_id = vim.api.nvim_create_namespace("markdown_link_checker")
local auto_check_var = "auto_check_markdown_links"

-- Use Tree-sitter to find all inline_link nodes
local function find_links_with_treesitter(bufnr)
  local parser = vim.treesitter.get_parser(bufnr, 'markdown_inline')
  local tree = parser:parse()[1]
  local root = tree:root()
  local current_file = vim.api.nvim_buf_get_name(bufnr)
  local current_dir = vim.fn.fnamemodify(current_file, ":h")

  -- Query the syntax tree for inline_link nodes
  local query = vim.treesitter.query.parse('markdown_inline', [[
    (inline_link
      (link_text)? @link_text
      (link_destination) @link_destination)
  ]])

  local links = {}
  for id, node in query:iter_captures(root, bufnr, 0, -1) do
    local start_row, start_col, end_row, end_col = node:range()
    if node:type() == 'link_destination' then
      -- local text_parts = ts_utils.get_node_text(node, bufnr)
      -- local text = table.concat(text_parts, "")
      local text = vim.treesitter.get_node_text(node, bufnr)
      print(vim.inspect({ start_row, start_col, end_row, end_col }))
      print(text)
      if type(text) == 'string' and not text:match('^http') then
        -- Construct the full path
        local path
        if text:match('^./') or text:match('^../') then
          path = vim.fn.fnamemodify(current_dir .. '/' .. text, ":p")
        else
          path = vim.fn.fnamemodify(text, ":p")
        end
        table.insert(links, { range = { start_row, start_col, end_row, end_col }, path = path })
      end
    end
  end

  return links
end

-- async function to check hover information of links
local function check_link_hover_async(links, diagnostics, bufnr)
  if #links == 0 then
    -- all links have been checked, set the diagnostic information
    vim.diagnostic.set(ns_id, bufnr, diagnostics, {})
    return
  end

  local link = table.remove(links, 1)
  local linenr, start_col = link.range[1], link.range[2]
  local path = link.path
  local params = {
    textDocument = vim.lsp.util.make_text_document_params(),
    position = { line = linenr, character = start_col - 1 }
  }

  -- Use LSP to check if the link is valid
  vim.lsp.buf_request(bufnr, 'textDocument/hover', params, function(err, result, ctx, config)
    vim.schedule(function()
      if not (result and result.contents) then
        -- use async file system operation
        vim.loop.fs_stat(path, function(err, stat)
          vim.schedule(function()
            if not stat then
              -- If there is no result and the path is not a valid file or directory, add a warning diagnostic to the list
              table.insert(diagnostics, {
                lnum = linenr,
                col = start_col,
                message = table.concat({ "File/Directory/Link does not exist:", path }, " "),
                severity = vim.diagnostic.severity.WARN,
              })
            end
            -- check next link hover
            check_link_hover_async(links, diagnostics, bufnr)
          end)
        end)
      else
        -- check next link hover
        check_link_hover_async(links, diagnostics, bufnr)
      end
    end)
  end)
end

local function check_markdown_links_async()
  local bufnr = vim.api.nvim_get_current_buf()
  -- Cancel all previous diagnostics
  vim.diagnostic.reset(ns_id, bufnr)

  local links = find_links_with_treesitter(bufnr)
  local diagnostics = {}

  -- async function to check hover information of links
  check_link_hover_async(links, diagnostics, bufnr)
end

local function toggle_auto_check()
  if vim.b[auto_check_var] == nil or vim.b[auto_check_var] == true then
    print("Auto check disabled")
    vim.b[auto_check_var] = false
  else
    print("Auto check enabled")
    vim.b[auto_check_var] = true
    check_markdown_links_async()
  end
end

-- Create a custom command to check all links
vim.api.nvim_create_user_command('CheckMarkdownLinks', function()
  check_markdown_links_async()
end, {})
vim.api.nvim_create_user_command('ToggleAutoCheckLinks', function()
  toggle_auto_check()
end, {})

local function is_lsp_attached()
  local bufnr = vim.api.nvim_get_current_buf()
  local clients = vim.lsp.get_clients({ bufnr = bufnr })
  return next(clients) ~= nil
end

-- autocmd BufWinEnter,TextChanged,InsertLeave *.md lua check_markdown_links_async()
vim.api.nvim_create_autocmd({ "BufWinEnter", "TextChanged", "InsertLeave" }, {
  pattern = "*.md",
  callback = function()
    if vim.b[auto_check_var] == false then
      return
    end
    if is_lsp_attached() then
      check_markdown_links_async()
    end
  end,
})

local null_ls = require("null-ls")
local code_actions = {
  {
    name = "check_markdown_links",
    title = "Check Markdown Links",
    action = check_markdown_links_async
  },
  {
    name = "toggle_auto_check_markdown_links",
    title = "Toggle Auto Check Markdown Links ",
    action = toggle_auto_check
  },
}
-- Use a for loop to register all code actions
for _, action in ipairs(code_actions) do
  null_ls.register({
    name = action.name,
    method = null_ls.methods.CODE_ACTION,
    filetypes = { "markdown" },
    generator = {
      fn = function(params)
        return {
          {
            title = action.title,
            action = action.action,
          },
        }
      end,
    },
  })
end

-- set up null-ls
null_ls.setup()
