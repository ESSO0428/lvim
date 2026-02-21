return {
  {
    "luukvbaal/statuscol.nvim",
    event = "BufReadPost", -- 開某個檔案後再載入
    opts = function()
      local builtin = require('statuscol.builtin')
      return {
        setopt = true,
        -- override the default list of segments with:
        -- number-less fold indicator, then signs, then line number & separator
        segments = {
          { text = { '%s' },                  click = 'v:lua.ScSa' },
          { text = { builtin.foldfunc, ' ' }, click = 'v:lua.ScFa' },
          {
            text = { builtin.lnumfunc, ' ' },
            condition = { true, builtin.not_empty },
            click = 'v:lua.ScLa',
          },
        },
      }
    end,
  },
  {
    "ESSO0428/bookmarks.nvim",
    config = function()
      require("user.config.plugins.BookMarks").setup()
    end,
  },
}
