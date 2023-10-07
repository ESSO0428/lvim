-- NOTE: 注意 close buffer 的功能可能會因為彩虹括號套件而出錯
-- 請不要安裝和使用 mrjones2014/nvim-ts-rainbow"
-- 改用 HiPhish/nvim-ts-rainbow2
-- 或 HiPhish/rainbow-delimiters.nvim (推薦)

require('close_buffers').setup({
  preserve_window_layout = { 'this' },
  next_buffer_cmd = function(windows)
    require('bufferline').cycle(1)
    local bufnr = vim.api.nvim_get_current_buf()

    for _, window in ipairs(windows) do
      vim.api.nvim_win_set_buf(window, bufnr)
    end
  end,
})
function BufferLineKill(opts)
  opts = opts or {}
  local force = opts.force or false
  local bo = vim.bo
  local api = vim.api
  local fmt = string.format
  local fn = vim.fn
  local choice

  local bufnr = vim.api.nvim_get_current_buf()
  local bufname = api.nvim_buf_get_name(bufnr)

  if api.nvim_buf_get_option(bufnr, "buftype") == "terminal" then
    if force ~= true then
      vim.cmd('BufferKill')
    else
      vim.cmd([[lua require("lvim.core.bufferline").buf_kill("bd", 0, true)]])
    end
  else
    if force ~= true then
      if bo[bufnr].modified then
        choice = fn.confirm(fmt([[Save changes to "%s"?]], bufname), "&Yes\n&No\n&Cancel")
        if choice == 1 then
          vim.api.nvim_buf_call(bufnr, function()
            vim.cmd("w")
          end)
        elseif choice == 2 then
          do end -- Empty block, no operation
        else
          return
        end
      end
    end

    -- Get list of active buffers
    local buffers = vim.tbl_filter(function(buf)
      return api.nvim_buf_is_valid(buf) and bo[buf].buflisted
    end, api.nvim_list_bufs())
    if #buffers == 1 then
      vim.cmd([[lua require("lvim.core.bufferline").buf_kill("bd", 0, true)]])
    else
      vim.cmd([[lua require('close_buffers').delete({type = 'this', force = true})]])
    end
  end
end

vim.cmd([[
command! BufferLineKill lua BufferLineKill({ force = false })
command! ForceBufferLineKill lua BufferLineKill({ force = true })
]])
