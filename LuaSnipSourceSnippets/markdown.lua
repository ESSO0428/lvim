local ls = require('luasnip')
local s = ls.snippet
local t = ls.text_node

local snippets = {
  s("!note", {
    t({ "> [!NOTE]", "> " })
  }, {
    description = "Insert Note"
  }),

  s("!tip", {
    t({ "> [!TIP]", "> " })
  }, {
    description = "Insert Tip"
  }),

  s("!important", {
    t({ "> [!IMPORTANT]", "> " })
  }, {
    description = "Insert Important"
  }),

  s("!warning", {
    t({ "> [!WARNING]", "> " })
  }, {
    description = "Insert Warning"
  }),

  s("!caution", {
    t({ "> [!CAUTION]", "> " })
  }, {
    description = "Insert Caution"
  }),
}

return snippets
