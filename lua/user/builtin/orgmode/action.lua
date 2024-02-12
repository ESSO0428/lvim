local M = {}
local Files = require('orgmode.parser.files')
local utils = require('orgmode.utils')

function M.custom_cycle()
  local file = Files.get_current_file()
  local line = vim.fn.line('.') or 0
  if not vim.wo.foldenable then
    vim.wo.foldenable = true
    vim.cmd([[silent! norm!zx]])
  end
  local level = vim.fn.foldlevel(line)
  if level == 0 then
    return utils.echo_info('No fold')
  end
  local is_fold_closed = vim.fn.foldclosed(line) ~= -1
  if is_fold_closed then
    return vim.cmd([[silent! norm!zo]])
  end
  local section = file.sections_by_line[line]
  if section then
    if not section:has_children() then
      return
    end
    local close = #section.sections == 0
    if not close then
      local has_nested_children = false
      for _, child in ipairs(section.sections) do
        if not has_nested_children and child:has_children() then
          has_nested_children = true
        end
        if child:has_children() and vim.fn.foldclosed(child.line_number) == -1 then
          vim.cmd(string.format('silent! keepjumps norm!%dggzc', child.line_number))
          close = true
        end
      end
      vim.cmd(string.format('silent! keepjumps norm!%dgg', line))
      if not close and not has_nested_children then
        close = true
      end
    end

    if close then
      return vim.cmd([[silent! norm!zc]])
    end
    return vim.cmd([[silent! norm!zczO]])
  end

  if vim.fn.getline(line):match('^%s*:[^:]*:%s*$') then
    return vim.cmd([[silent! norm!za]])
  end
  -- NOTE: folding list or code block
  if vim.fn.getline(line):match('^%s*[-+*]%s') then
    return vim.cmd([[silent! norm!za]])
  end
  if vim.fn.getline(line):match('^%s*[0-9]+[.]%s') then
    return vim.cmd([[silent! norm!za]])
  end
  if vim.fn.getline(line):match('^%s*[a-z][.]%s') then
    return vim.cmd([[silent! norm!za]])
  end
  if vim.fn.getline(line):match('^%s*#[+]begin_src%s') then
    return vim.cmd([[silent! norm!za]])
  end
end

return M
