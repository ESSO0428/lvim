-- NOTE: Code action for checking markdown links
-- local ts_utils = require 'nvim-treesitter.ts_utils'
local ns_id = vim.api.nvim_create_namespace("markdown_link_checker")
local auto_check_var = "auto_check_markdown_links"

-- Helper function to get the visual position of a character in a line
local function get_visual_position(line, col)
  return vim.str_utfindex(line, col) or 0
end

-- Use Tree-sitter to find all inline_link nodes
local function find_links_in_line(line, line_num, current_dir, not_ignore_http)
  local parser = vim.treesitter.get_string_parser(line, 'markdown_inline')
  local tree = parser:parse()[1]
  local root = tree:root()

  -- Query the syntax tree for inline_link nodes
  local query = vim.treesitter.query.parse('markdown_inline', [[
    (link_destination) @link_destination
  ]])

  local links = {}
  for id, node in query:iter_captures(root, 0, 0, -1) do
    if query.captures[id] == 'link_destination' then
      local start_row, start_col, end_row, end_col = node:range()
      -- Ensure that the node is within the single line
      local text = string.sub(line, start_col + 1, end_col)
      start_row = line_num
      end_row = line_num
      start_col = get_visual_position(line, start_col)
      end_col = get_visual_position(line, end_col)
      local is_not_http = not text:match('^http') or not_ignore_http
      if type(text) == 'string' and is_not_http then
        -- Construct the full path
        local path
        if text:match('^./') or text:match('^../') then
          path = vim.fn.fnamemodify(current_dir .. '/' .. text, ":p")
        else
          path = vim.fn.fnamemodify(text, ":p")
        end
        table.insert(links, { range = { start_row, start_col, end_row, end_col }, path = path, text = text })
      end
    end
  end
  return links
end

-- Function to find all links in the buffer
local function find_links_with_treesitter(bufnr, not_ignore_http)
  local success, parser = pcall(vim.treesitter.get_parser, bufnr, 'markdown_inline')
  if not success then
    vim.notify("WARNING: Please install markdown_inline: TSInstall markdown_inline", vim.log.levels.WARN)
    return {}
  end

  local current_file = vim.api.nvim_buf_get_name(bufnr)
  local current_dir = vim.fn.fnamemodify(current_file, ":h")
  local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)

  local all_links = {}
  for line_num, line in ipairs(lines) do
    local links = find_links_in_line(line, line_num - 1, current_dir, not_ignore_http)
    for _, link in ipairs(links) do
      table.insert(all_links, link)
    end
  end

  return all_links
end

-- async function to check definition information of links
local function check_link_definition_async(links, diagnostics, bufnr)
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
    position = { line = linenr, character = start_col }
  }

  -- Use LSP to check if the link is valid
  vim.lsp.buf_request(bufnr, 'textDocument/definition', params, function(err, result, ctx, config)
    vim.schedule(function()
      if not result then
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
            -- check next link definition
            check_link_definition_async(links, diagnostics, bufnr)
          end)
        end)
      else
        -- check next link definition
        check_link_definition_async(links, diagnostics, bufnr)
      end
    end)
  end)
end

local function check_markdown_links_async()
  local bufnr = vim.api.nvim_get_current_buf()
  -- Cancel all previous diagnostics
  vim.diagnostic.reset(ns_id, bufnr)

  local links = find_links_with_treesitter(bufnr, false)
  local diagnostics = {}

  -- async function to check definition information of links
  check_link_definition_async(links, diagnostics, bufnr)
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

-- Function to list all links in quickfix
local function list_all_links_in_quickfix()
  local bufnr = vim.api.nvim_get_current_buf()
  local links = find_links_with_treesitter(bufnr, true)
  local qf_list = {}

  for _, link in ipairs(links) do
    table.insert(qf_list, {
      bufnr = bufnr,
      lnum = link.range[1] + 1,
      col = link.range[2] + 1,
      text = link.text
    })
  end

  vim.fn.setqflist(qf_list, 'r')
  vim.cmd('copen')
end

-- Function to list unique links in quickfix
local function list_unique_links_in_quickfix()
  local bufnr = vim.api.nvim_get_current_buf()
  local links = find_links_with_treesitter(bufnr, true)
  local qf_list = {}
  local seen_texts = {}

  for _, link in ipairs(links) do
    if not seen_texts[link.text] then
      table.insert(qf_list, {
        bufnr = bufnr,
        lnum = link.range[1] + 1,
        col = link.range[2] + 1,
        text = link.text
      })
      seen_texts[link.text] = true
    end
  end

  vim.fn.setqflist(qf_list, 'r')
  vim.cmd('copen')
end

-- Create a custom command to check all links
vim.api.nvim_create_user_command('CheckMarkdownLinks', function()
  check_markdown_links_async()
end, {})
vim.api.nvim_create_user_command('ToggleAutoCheckLinks', function()
  toggle_auto_check()
end, {})
vim.api.nvim_create_user_command('ListMarkdownLinks', function()
  list_all_links_in_quickfix()
end, {})
vim.api.nvim_create_user_command('ListUniqueMarkdownLinks', function()
  list_unique_links_in_quickfix()
end, {})

local function is_lsp_attached()
  local bufnr = vim.api.nvim_get_current_buf()
  local clients = vim.lsp.get_clients({ bufnr = bufnr })
  return next(clients) ~= nil
end

-- autocmd BufWinEnter,TextChanged,InsertLeave *.md lua check_markdown_links_async()
vim.api.nvim_create_autocmd({ "BufEnter", "TextChanged", "InsertLeave" }, {
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
  {
    name = "list_markdown_links",
    title = "List Markdown Links in Quickfix",
    action = list_all_links_in_quickfix
  },
  {
    name = "list_unique_markdown_links",
    title = "List Unique Markdown Links in Quickfix",
    action = list_unique_links_in_quickfix
  }
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
