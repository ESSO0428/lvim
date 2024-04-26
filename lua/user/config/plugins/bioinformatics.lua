-- reverse
vim.api.nvim_create_user_command('Reverse', "'<,'>!rev", { range = true })
-- reverse-complement
vim.api.nvim_create_user_command('ReverseComplementT', "silent!'<,'>!rev | tr 'ACGT' 'TGCA'", { range = true })
vim.api.nvim_create_user_command('ReverseComplementU', "silent!'<,'>!rev | tr 'ACGU' 'UGCA'", { range = true })
vim.api.nvim_create_user_command('ReverseComplementt', "silent!'<,'>!rev | tr 'acgt' 'tgca'", { range = true })
vim.api.nvim_create_user_command('ReverseComplementu', "silent!'<,'>!rev | tr 'acgu' 'ugca'", { range = true })
-- T/U or t/u
vim.api.nvim_create_user_command('TUorUT', "silent!'<,'>!tr 'TtUu' 'UuTt'", { range = true })

-- set fasta filetype and syntax on
vim.api.nvim_create_user_command('FileTypeOnFasta', 'set filetype=fasta', { nargs = "*" })
vim.api.nvim_create_user_command('FileTypeOnCsv', 'set filetype=csv', { nargs = "*" })
vim.api.nvim_create_user_command('FileTypeOnTsv', 'set filetype=tsv', { nargs = "*" })
vim.api.nvim_create_user_command('FileTypeOnText', 'set filetype=text', { nargs = "*" })

vim.api.nvim_create_user_command('FileTypeOnCsvSemicolon', 'set filetype=csv_semicolon', { nargs = "*" })
vim.api.nvim_create_user_command('FileTypeOnCsvWhitespace', 'set filetype=csv_whitespace', { nargs = "*" })
vim.api.nvim_create_user_command('FileTypeOnCsvPipe', 'set filetype=csv_pipe', { nargs = "*" })
vim.api.nvim_create_user_command('FileTypeOnRfcCsv', 'set filetype=rfc_csv', { nargs = "*" })
vim.api.nvim_create_user_command('FileTypeOnRfcSemicolon', 'set filetype=rfc_semicolon', { nargs = "*" })


-----------------------------------------------------------------
-- 添加更多映射
my_ext_syntax_map = {
  ['csv'] = 'csv',
  ['txt'] = 'tsv',
  ['tab'] = 'tsv'
}
function toggle_syntax()
  local current_filetype = vim.bo.filetype
  local ext = vim.fn.expand('%:e')
  if current_filetype == '' and ext == '' then
    print('Failed : filetype is empty')
    return
  elseif current_filetype == '' or current_filetype == 'text' then
    local new_filetype = my_ext_syntax_map[ext]
    current_filetype = new_filetype
    if not new_filetype then
      print('Failed: unknown file type')
      return
    end

    vim.cmd('set filetype=' .. new_filetype)
  end

  local current_syntax = vim.api.nvim_buf_get_option(0, 'syntax')
  local datatable_filetypes = { 'csv', 'tsv', 'csv_semicolon', 'csv_whitespace', 'csv_pipe', 'rfc_csv', 'rfc_semicolon' }
  local is_match_filetype = vim.fn.index(datatable_filetypes, current_filetype) ~= -1 and 1 or -1

  if current_syntax == '' or current_syntax == 'off' then
    vim.b.current_buffer_syntax = 'on'
    vim.cmd('setlocal syntax=on')
    if is_match_filetype ~= -1 then
      vim.cmd('TSBufDisable highlight')
      vim.cmd('set syntax=' .. current_filetype)
    end
    print('syntax on')
  else
    vim.b.current_buffer_syntax = 'off'
    vim.cmd('setlocal syntax=off')
    vim.cmd('set laststatus=3')
    if is_match_filetype ~= -1 then
      vim.cmd('TSBufEnable highlight')
    end
    print('syntax off')
  end
end

-- NOTE: for link highlight toggle
function toggle_conceal()
  local buf = vim.api.nvim_get_current_buf()

  -- 初始化当前 buffer 的 conceal 状态，如果它还不存在
  if vim.b.current_buffer_conceal_change == nil or vim.b.current_buffer_conceal_change == '' then
    vim.b.current_buffer_conceal_change = 'off'
  end

  -- 如果 conceallevel 已经被更改，恢复到原始状态
  if vim.b.current_buffer_conceal_change == 'on' then
    vim.b.current_buffer_conceal_change = 'off'
    vim.o.conceallevel = vim.b.original_conceallevel
    print('conceal 0 → ' .. (vim.b.original_conceallevel) .. ' (default)')
  else
    -- 如果还没更改过，保存当前 conceallevel 并设置为 0
    vim.b.original_conceallevel = vim.o.conceallevel
    vim.b.current_buffer_conceal_change = 'on'
    vim.o.conceallevel = 0
    print('conceal ' .. (vim.b.original_conceallevel or 0) .. ' (default)' .. ' → 0')
  end
end

function ReStartNotTableFileTypeLayout(action)
  if vim.fn.getcmdline() ~= '' then
    return
  end
  local datatable_filetypes = { 'csv', 'tsv', 'csv_semicolon', 'csv_whitespace', 'csv_pipe', 'rfc_csv', 'rfc_semicolon' }
  local int_bool = -1
  if action == 'leave' then
    int_bool = 1
  end
  local is_match_filetype = vim.fn.index(datatable_filetypes, vim.bo.filetype) ~= -1 and 1 or -1
  if is_match_filetype == int_bool then
    -- vim.cmd("lua require('lualine').setup()")
    vim.cmd("set laststatus=3")
  end
end

lvim.keys.normal_mode["sn"] = { "<cmd>lua toggle_syntax()<cr>" }
lvim.keys.normal_mode["sc"] = { "<cmd>lua toggle_conceal()<cr>" }
vim.cmd([[
  " autocmd FileType csv,tsv syntax off
  augroup disable_syntax
    autocmd!
    autocmd FileType csv,tsv if !exists("b:current_buffer_syntax") || b:current_buffer_syntax != 'on' | setlocal syntax=off | endif
    autocmd FileType bed,clustal,cwl,faidx,fasta,fastq,flagstat,gaussian,gtf,nexus,pdb,pml,sam,vcf if !exists("b:current_buffer_syntax") || b:current_buffer_syntax != 'on' | setlocal syntax=off | endif
  augroup END
  " manual setting filetype csv not autocmd
  " autocmd BufNewFile,BufRead *.csv   set filetype=csv

  autocmd BufNewFile,BufRead *.tsv.txt   set filetype=tsv
  autocmd BufNewFile,BufRead *.dat   set filetype=csv_pipe
  " autocmd BufLeave,WinLeave * lua ReStartNotTableFileTypeLayout()
  autocmd WinEnter * lua ReStartNotTableFileTypeLayout('enter')
  autocmd BufLeave * lua ReStartNotTableFileTypeLayout('leave')
]])

local function format_json(opts)
  local line1 = opts.line1 or 1
  local line2 = opts.line2 or vim.api.nvim_buf_line_count(0)
  vim.cmd(line1 .. ',' .. line2 .. '!xargs -0 -I {} node -e \'console.log(JSON.stringify({}, null, 2));\'')
end

vim.api.nvim_create_user_command('FormatJson', format_json, { range = '%' })
