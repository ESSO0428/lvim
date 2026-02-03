local M = {}
lvim.builtin.which_key.setup.plugins.presets.h = false

function M.setup()
  local got_hydra, hydra = pcall(require, "hydra")
  local hint = [[
_<_/_>_: c previous/next
]]

  hydra({
    name = "quickfix",
    mode = { "n" },
    hint = hint,
    config = {
      invoke_on_body = true,
      color = "pink",
      hint = {
        float_opts = {
          border = 'rounded',
        },
      },
    },
    body = "<leader>hq",
    heads = {
      { '>', ':cnext<cr>',     { desc = 'cnext' } },
      { '<', ':cprevious<CR>', { desc = 'cprevious' } }
    }
  })

  hint = [[
_<_/_>_: previous/next
]]

  hydra({
    name = "args",
    mode = { "n" },
    hint = hint,
    config = {
      invoke_on_body = true,
      color = "pink",
      hint = {
        float_opts = {
          border = 'rounded',
        },
      },
    },
    body = "<leader>ha",
    heads = {
      { '>', ':next<cr>',     { desc = 'next' } },
      { '<', ':previous<CR>', { desc = 'previous' } }
    }
  })

  hint = [[
_<_/_>_: breakpint prev/next _S_: go to breakpint stop
]]

  hydra({
    name = "debug",
    mode = { "n" },
    hint = hint,
    config = {
      invoke_on_body = true,
      color = "pink",
      hint = {
        float_opts = {
          border = 'rounded',
        },
      },
    },
    body = "<leader>hd",
    heads = {
      { '<', ":lua require('goto-breakpoints').next()<CR>",    { desc = 'next breakpoints' } },
      { '>', ":lua require('goto-breakpoints').prev()<CR>",    { desc = 'prev breakpoints' } },
      { 'S', ":lua require('goto-breakpoints').stopped()<CR>", { desc = 'go to breakpoints stop' } },
    }
  })

  hint = [[
_o_: Folding Code (Toggle) _u_: Folding Preview
]]

  hydra({
    name = "FoldMode",
    mode = { "n" },
    hint = hint,
    config = {
      invoke_on_body = true,
      color = "pink",
      hint = {
        float_opts = {
          border = 'rounded',
        },
      },
    },
    body = "<leader>ho",
    heads = {
      { 'o', "za",                                    { desc = 'Folding Code (Toggle)' } },
      { 'u', ":lua PeekFoldedLinesUnderCursor()<cr>", { desc = "Folding Preview" } }
    }
  })

  hint = [[
_<_/_>_: bookmarks prev/next
]]

  hydra({
    name = "bookmarks",
    mode = { "n" },
    hint = hint,
    config = {
      invoke_on_body = true,
      color = "pink",
      hint = { float_opts = {} },
    },
    body = "<leader>hm",
    heads = {
      { '>', ":lua require('bookmarks.actions').bookmark_next()<cr>", { desc = 'next bookmark' } },
      { '<', ":lua require('bookmarks.actions').bookmark_prev()<cr>", { desc = 'prev bookmark' } },
    }
  })

  hint = [[
_<_/_>_: spell prev/next
]]

  hydra({
    name = "spell",
    mode = { "n" },
    hint = hint,
    config = {
      invoke_on_body = true,
      color = "pink",
      hint = {
        float_opts = {
          border = 'rounded',
        },
      },
    },
    body = "<leader>hs",
    heads = {
      { '>', "]s", { desc = 'next spell' } },
      { '<', "[s", { desc = 'prev spell' } },
    }
  })

  hint = [[
_<c-u>_/_<c-o>_: scroll 1% up/down
]]

  hydra({
    name = "bigfile scroll",
    mode = { "n" },
    hint = hint,
    config = {
      invoke_on_body = true,
      color = "pink",
      hint = {
        float_opts = {
          border = 'rounded',
        },
      },
    },
    body = "<leader>hb",
    heads = {
      { '<c-o>', [[<cmd>exe "normal! " . (line('$') >= 100 ? float2nr(ceil(line('$') / 100)) : 1) . "j"<cr>]], { desc = 'scroll 1% down' } },
      { '<c-u>', [[<cmd>exe "normal! " . (line('$') >= 100 ? float2nr(ceil(line('$') / 100)) : 1) . "k"<cr>]], { desc = 'scroll 1% up' } },
    }
  })
end

return M
