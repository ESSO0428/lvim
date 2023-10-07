local groups = require('bufferline.groups')
lvim.builtin.bufferline.options.groups = {
  options = {
    toggle_hidden_on_enter = true -- when you re-enter a hidden group this options re-opens that group so the buffer is visible
  },
  items = {
    {
      name = "OrgMode",
      auto_close = false, -- whether or not close this group if it doesn't contain the current buffer
      matcher = function(buf)
        return buf.id and vim.fn.bufname(buf.id):match('%.org')
      end,
    },
    {
      name = "README",
      auto_close = false, -- whether or not close this group if it doesn't contain the current buffer
      matcher = function(buf)
        return buf.id and vim.fn.bufname(buf.id):match('%readme') or buf.id and vim.fn.bufname(buf.id):match('%README')
      end,
    },
    {
      name = "Shell",
      auto_close = false, -- whether or not close this group if it doesn't contain the current buffer
      matcher = function(buf)
        return buf.id and vim.fn.bufname(buf.id):match('%.sh')
      end,
    },
    {
      name = "Python",
      auto_close = false, -- whether or not close this group if it doesn't contain the current buffer
      matcher = function(buf)
        return buf.id and vim.fn.bufname(buf.id):match('%.py')
      end,
    },
    {
      name = "Table",
      auto_close = false, -- whether or not close this group if it doesn't contain the current buffer
      matcher = function(buf)
        return buf.id and vim.fn.bufname(buf.id):match('%.csv') or buf.id and vim.fn.bufname(buf.id):match('%.tsv')
      end,
    },
    {
      name = "Web",
      auto_close = false, -- whether or not close this group if it doesn't contain the current buffer
      matcher = function(buf)
        return buf.id and vim.fn.bufname(buf.id):match('%.html') or buf.id and vim.fn.bufname(buf.id):match('%.css') or
            buf.id and vim.fn.bufname(buf.id):match('%.js') or
            buf.id and vim.fn.bufname(buf.id):match('%.java') or buf.id and vim.fn.bufname(buf.id):match('%.scss')
      end,
    },
    {
      name = "Tests", -- Mandatory
      priority = 2, -- determines where it will appear relative to other groups (Optional)
      icon = "", -- Optional
      matcher = function(buf) -- Mandatory
        return buf.id and vim.fn.bufname(buf.id):match('%_test') or buf.id and vim.fn.bufname(buf.id):match('%_spec')
      end,
    },
    {
      name = "Docs",
      auto_close = false, -- whether or not close this group if it doesn't contain the current buffer
      matcher = function(buf)
        return buf.id and vim.fn.bufname(buf.id):match('%.md') or buf.id and vim.fn.bufname(buf.id):match('%.txt')
      end,
    },
    {
      name = 'Dotfiles',
      matcher = function(buf)
        return buf.name:sub(1, 1) == '.'
      end,
    },
    {
      name = "Lua/Vim",
      auto_close = false, -- whether or not close this group if it doesn't contain the current buffer
      matcher = function(buf)
        return buf.id and vim.fn.bufname(buf.id):match('%.lua') or buf.id and vim.fn.bufname(buf.id):match('%.vim')
      end,
    },
    groups.builtin.ungrouped,
  }
}

-- local groups = require('bufferline.groups')
-- lvim.builtin.bufferline.options.groups = {
--   options = {
--     toggle_hidden_on_enter = true -- when you re-enter a hidden group this options re-opens that group so the buffer is visible
--   },
--   items = {
--     {
--       name = "OrgMode",
--       auto_close = false, -- whether or not close this group if it doesn't contain the current buffer
--       matcher = function(buf)
--         return buf.filename:match('%.org')
--       end,
--     },
--     {
--       name = "README",
--       auto_close = false, -- whether or not close this group if it doesn't contain the current buffer
--       matcher = function(buf)
--         return buf.filename:match('%readme') or buf.filename:match('%README')
--       end,
--     },
--     {
--       name = "Shell",
--       auto_close = false, -- whether or not close this group if it doesn't contain the current buffer
--       matcher = function(buf)
--         return buf.filename:match('%.sh')
--       end,
--     },
--     {
--       name = "Python",
--       auto_close = false, -- whether or not close this group if it doesn't contain the current buffer
--       matcher = function(buf)
--         return buf.filename:match('%.py')
--       end,
--     },
--     {
--       name = "Table",
--       auto_close = false, -- whether or not close this group if it doesn't contain the current buffer
--       matcher = function(buf)
--         return buf.filename:match('%.csv') or buf.filename:match('%.tsv')
--       end,
--     },
--     {
--       name = "Web",
--       auto_close = false, -- whether or not close this group if it doesn't contain the current buffer
--       matcher = function(buf)
--         return buf.filename:match('%.html') or buf.filename:match('%.css') or buf.filename:match('%.js') or
--             buf.filename:match('%.java') or buf.filename:match('%.scss')
--       end,
--     },
--     {
--       name = "Tests",         -- Mandatory
--       priority = 2,           -- determines where it will appear relative to other groups (Optional)
--       icon = "",           -- Optional
--       matcher = function(buf) -- Mandatory
--         return buf.filename:match('%_test') or buf.filename:match('%_spec')
--       end,
--     },
--     {
--       name = "Docs",
--       auto_close = false, -- whether or not close this group if it doesn't contain the current buffer
--       matcher = function(buf)
--         return buf.filename:match('%.md') or buf.filename:match('%.txt')
--       end,
--     },
--     {
--       name = 'Dotfiles',
--       matcher = function(buf)
--         return buf.name:sub(1, 1) == '.'
--       end,
--     },
--     {
--       name = "Lua/Vim",
--       auto_close = false, -- whether or not close this group if it doesn't contain the current buffer
--       matcher = function(buf)
--         return buf.filename:match('%.lua') or buf.filename:match('%.vim')
--       end,
--     },
--     groups.builtin.ungrouped,
--   }
-- }
