local ls = require('luasnip')
local s = ls.snippet
local t = ls.text_node
local snippets = {}
local snippet_definitions = {
  {
    triggers = { "!note", ">note" },
    text = { "> [!NOTE]", "> ", "> " },
  },
  {
    triggers = { "!tip", ">tip" },
    text = { "> [!TIP]", "> ", "> " },
  },
  {
    triggers = { "!important", ">important" },
    text = { "> [!IMPORTANT]", "> ", "> " },
  },
  {
    triggers = { "!warning", ">warning" },
    text = { "> [!WARNING]", "> ", "> " },
  },
  {
    triggers = { "!caution", ">caution" },
    text = { "> [!CAUTION]", "> ", "> " },
  },
}

for _, def in ipairs(snippet_definitions) do
  for _, trigger in ipairs(def.triggers) do
    table.insert(snippets, s(trigger, t(def.text)))
  end
end
return snippets
