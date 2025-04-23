lvim.builtin.bigfile.config = {
  filesize = 1,      -- size of the file in MiB, the plugin round file sizes to the closest MiB
  pattern = { "*" }, -- autocmd pattern or function see <### Overriding the detection of big files>
  features = {       -- features to disable
    "indent_blankline",
    "illuminate",
    "lsp",
    "treesitter",
    "syntax",
    "matchparen",
    "vimopts",
    "filetype",
    {
      name = "mymatchparen",
      opts = {
        defer = false,
      },
      disable = function()
        vim.cmd('set nowrap')
        vim.cmd('set nofoldenable')
        vim.cmd('setlocal nospell')
        vim.cmd('setlocal cursorline')
        require "rainbow-delimiters".disable(0)
        if not require('session_manager.utils').session_loading then
          if vim.g.vim_pid == nil then
            vim.g.vim_pid = vim.fn.getpid()
          end
          local pid_info = vim.g.vim_pid and ("(CURRENT PID: " .. vim.g.vim_pid .. ")") or ""
          local bufnr = vim.api.nvim_get_current_buf()
          local fileName = vim.api.nvim_buf_get_name(0)
          local choice = vim.fn.input(
            table.concat({
              table.concat({ pid_info, "File is large file, Do you want to continue loading?" }, " "),
              "[n]ot open",
              "[s]ecurity session save and open",
              "[y]es directly open",
              "choice(s/y/n): ",
            }, "\n")
          )
          if choice == "s" then
            -- vim.cmd("BufferLineKill")
            vim.cmd("b#")
            vim.cmd("bd " .. bufnr)
            vim.defer_fn(function()
              vim.cmd('SessionManager save_current_session')
              vim.cmd("e " .. fileName)
            end, 50)
          elseif choice == "y" then
            -- Continue with default settings
          else
            -- vim.cmd("BufferLineKill")
            vim.cmd("b#")
            vim.cmd("bd " .. bufnr)
          end
        end
      end,
    }
  },
}
