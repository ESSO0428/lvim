return {
  { "junegunn/fzf" },
  {
    "kevinhwang91/nvim-bqf",
    ft = "qf",
    config = function()
      require("bqf").setup({
        auto_enable = true,
        preview = {
          win_height = 12,
          win_vheight = 12,
          delay_syntax = 80,
          border_chars = { "┃", "┃", "━", "━", "┏", "┓", "┗", "┛", "█" }
        },
        func_map = {
          split = "<a-k>",
          vsplit = "<a-l>",
          ptogglemode = "z,",
          stoggleup = "",
          pscrollup = "<c-u>",
          pscrolldown = '<C-o>',
          fzffilter = '<c-f>'
        },
        filter = {
          fzf = {
            action_for = { ["ctrl-s"] = "split" },
            extra_opts = { "--bind", "ctrl-o:toggle-all", "--prompt", "> " }
          }
        }
      })
    end
  },
  {
    "stevearc/quicker.nvim",
    event = "FileType qf",
    ---@module "quicker"
    ---@type quicker.SetupOptions
    opts = {},
    config = function()
      require("quicker").setup({
        opts = {
          buflisted = false,
          number = false,
          relativenumber = false,
          signcolumn = "auto",
          winfixheight = true,
          wrap = false,
        },
        keys = {
          {
            ">",
            function()
              local win_info = vim.fn.getwininfo(vim.api.nvim_get_current_win())[1]
              local is_quickfix = win_info and win_info.quickfix == 1
              local is_loclist = win_info and win_info.loclist == 1
              if is_quickfix and not is_loclist then
                vim.cmd("cclose")
                require("quicker").collapse()
                require("quicker").expand({ before = 2, after = 2, add_to_existing = true })
                Nvim.Quickfix.open_quickfix_safety()
              else
                require("quicker").collapse()
                require("quicker").expand({ before = 2, after = 2, add_to_existing = true })
              end
            end,
            desc = "Expand quickfix context",
          },
          {
            "<",
            function()
              local win_info = vim.fn.getwininfo(vim.api.nvim_get_current_win())[1]
              local is_quickfix = win_info and win_info.quickfix == 1
              local is_loclist = win_info and win_info.loclist == 1
              if is_quickfix and not is_loclist then
                vim.cmd("cclose")
                require("quicker").collapse()
                Nvim.Quickfix.open_quickfix_safety()
              else
                require("quicker").collapse()
              end
            end,
            desc = "Collapse quickfix context",
          },
        },
      })
    end
  },
}
