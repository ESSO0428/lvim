-- NOTE: Code action for checking markdown links
-- local ts_utils = require 'nvim-treesitter.ts_utils'
local uv = vim.uv or vim.loop
local ns_id = vim.api.nvim_create_namespace("markdown_link_checker")
local auto_check_var = "auto_check_markdown_links"
local null_ls_registered = false
local markdown_link_query
local auto_check_debounce_ms = 250
local debounce_timers = {}
local markdown_autocmds_attached = {}

local function close_timer(timer)
  if not timer then
    return
  end

  pcall(timer.stop, timer)

  local ok, is_closing = pcall(function()
    return timer:is_closing()
  end)
  if ok and is_closing then
    return
  end

  pcall(timer.close, timer)
end

local function stop_debounce_timer(bufnr)
  local timer = debounce_timers[bufnr]
  if not timer then
    return
  end
  debounce_timers[bufnr] = nil
  close_timer(timer)
end

local function cancel_current_async_job(bufnr)
  if not vim.api.nvim_buf_is_valid(bufnr) then
    return
  end
  local async_job = vim.b[bufnr].current_async_job
  if type(async_job) == "function" then
    async_job()
  elseif type(async_job) == "table" and async_job.stop then
    async_job:stop()
  end
  vim.b[bufnr].current_async_job = nil
end

local function get_markdown_link_query()
  if markdown_link_query == false then
    return nil
  end
  if markdown_link_query == nil then
    local ok, parsed = pcall(vim.treesitter.query.parse, 'markdown_inline', [[
      (link_destination) @link_destination
    ]])
    markdown_link_query = ok and parsed or false
  end
  return markdown_link_query or nil
end

-- Helper function to get the visual position of a character in a line
local function get_visual_position(line, col)
  return vim.str_utfindex(line, col) or 0
end

-- Use Tree-sitter to find all inline_link nodes
local function find_links_in_line(line, line_num, current_dir, not_ignore_http)
  if not line:find('](', 1, true) then
    return {}
  end

  local query = get_markdown_link_query()
  if not query then
    return {}
  end

  local parser = vim.treesitter.get_string_parser(line, 'markdown_inline')
  local tree = parser:parse()[1]
  local root = tree:root()

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

      -- Handle paths wrapped with <>
      local clean_text = text
      if text:match("^<.+>$") then
        clean_text = text:match("^<(.+)>$")
      end

      local is_not_http = not clean_text:match('^http') or not_ignore_http
      if type(clean_text) == 'string' and is_not_http then
        -- Construct the full path
        local path
        if clean_text:match('^./') or clean_text:match('^../') then
          path = vim.fn.fnamemodify(current_dir .. '/' .. clean_text, ":p")
        else
          path = vim.fn.fnamemodify(clean_text, ":p")
        end
        table.insert(links,
          { range = { start_row, start_col, end_row, end_col }, path = path, text = clean_text, original_text = text })
      end
    end
  end
  return links
end

-- Function to find all links in the buffer
local function find_links_with_treesitter(bufnr, not_ignore_http)
  local success = pcall(vim.treesitter.get_parser, bufnr, 'markdown_inline')
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
  if not vim.api.nvim_buf_is_valid(bufnr) or not vim.api.nvim_buf_is_loaded(bufnr) then
    return
  end

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

  -- Cancel last time async job
  cancel_current_async_job(bufnr)

  -- Use LSP to check if the link is valid
  -- vim.lsp.buf_request(bufnr, 'textDocument/definition', params, function(err, result, ctx, config)
  local _, cancel = vim.lsp.buf_request(bufnr, 'textDocument/definition', params,
    function(err, result, ctx, config)
      vim.schedule(function()
        if not vim.api.nvim_buf_is_valid(bufnr) or not vim.api.nvim_buf_is_loaded(bufnr) then
          return
        end
        if not result then
          -- use async file system operation
          uv.fs_stat(path, function(err, stat)
            vim.schedule(function()
              if not vim.api.nvim_buf_is_valid(bufnr) or not vim.api.nvim_buf_is_loaded(bufnr) then
                return
              end
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
              vim.b[bufnr].current_async_job = nil
              check_link_definition_async(links, diagnostics, bufnr)
            end)
          end)
        else
          -- check next link definition
          vim.b[bufnr].current_async_job = nil
          check_link_definition_async(links, diagnostics, bufnr)
        end
      end)
    end)
  vim.b[bufnr].current_async_job = cancel
end

local function check_markdown_links_async(bufnr)
  bufnr = bufnr or vim.api.nvim_get_current_buf()
  if not vim.api.nvim_buf_is_valid(bufnr) or not vim.api.nvim_buf_is_loaded(bufnr) then
    return
  end
  -- Cancel all previous diagnostics
  vim.diagnostic.reset(ns_id, bufnr)

  local links = find_links_with_treesitter(bufnr, false)
  local diagnostics = {}

  -- async function to check definition information of links
  check_link_definition_async(links, diagnostics, bufnr)
end

local function toggle_auto_check(bufnr)
  bufnr = bufnr or vim.api.nvim_get_current_buf()
  if vim.b[bufnr][auto_check_var] == nil or vim.b[bufnr][auto_check_var] == true then
    print("Auto check disabled")
    stop_debounce_timer(bufnr)
    cancel_current_async_job(bufnr)
    vim.b[bufnr][auto_check_var] = false
  else
    print("Auto check enabled")
    vim.b[bufnr][auto_check_var] = true
    check_markdown_links_async(bufnr)
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

local function is_lsp_attached(bufnr)
  bufnr = bufnr or vim.api.nvim_get_current_buf()
  local clients = vim.lsp.get_clients({ bufnr = bufnr })
  return next(clients) ~= nil
end

local function can_auto_check(bufnr)
  return vim.api.nvim_buf_is_valid(bufnr)
    and vim.api.nvim_buf_is_loaded(bufnr)
    and vim.bo[bufnr].filetype == "markdown"
    and vim.b[bufnr][auto_check_var] ~= false
    and is_lsp_attached(bufnr)
end

local function maybe_check_markdown_links(bufnr)
  if can_auto_check(bufnr) then
    check_markdown_links_async(bufnr)
  end
end

local function schedule_markdown_links_check(bufnr)
  if not can_auto_check(bufnr) then
    stop_debounce_timer(bufnr)
    return
  end

  stop_debounce_timer(bufnr)

  local timer = uv.new_timer()
  debounce_timers[bufnr] = timer
  timer:start(auto_check_debounce_ms, 0, vim.schedule_wrap(function()
    if debounce_timers[bufnr] == timer then
      debounce_timers[bufnr] = nil
    end
    close_timer(timer)
    maybe_check_markdown_links(bufnr)
  end))
end

local function attach_markdown_buffer_autocmds(bufnr)
  if markdown_autocmds_attached[bufnr] then
    return
  end

  markdown_autocmds_attached[bufnr] = true

  vim.api.nvim_create_autocmd("BufWinEnter", {
    buffer = bufnr,
    callback = function(args)
      maybe_check_markdown_links(args.buf)
    end,
  })

  vim.api.nvim_create_autocmd({ "TextChanged", "InsertLeave" }, {
    buffer = bufnr,
    callback = function(args)
      schedule_markdown_links_check(args.buf)
    end,
  })

  -- Clear namespace when buffer is unloaded
  vim.api.nvim_create_autocmd("BufUnload", {
    buffer = bufnr,
    once = true,
    callback = function(args)
      stop_debounce_timer(args.buf)
      cancel_current_async_job(args.buf)
      vim.diagnostic.reset(ns_id, args.buf)
      markdown_autocmds_attached[args.buf] = nil
    end,
  })
end

vim.api.nvim_create_autocmd("FileType", {
  pattern = "markdown",
  callback = function(args)
    attach_markdown_buffer_autocmds(args.buf)
  end,
})
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

local function ensure_markdown_code_actions_registered()
  if null_ls_registered then
    return
  end

  local ok, null_ls = pcall(require, "null-ls")
  if not ok then
    return
  end

  null_ls.register({
    name = "markdown_link_actions",
    method = null_ls.methods.CODE_ACTION,
    filetypes = { "markdown" },
    generator = {
      fn = function()
        local actions = {}
        for _, action in ipairs(code_actions) do
          actions[#actions + 1] = {
            title = action.title,
            action = action.action,
          }
        end
        return actions
      end,
    },
  })

  null_ls_registered = true
end

vim.api.nvim_create_autocmd("LspAttach", {
  callback = function(args)
    if vim.bo[args.buf].filetype == "markdown" then
      ensure_markdown_code_actions_registered()
    end
  end,
})
