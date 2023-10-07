local ls = require('luasnip')
local s = ls.snippet
local sn = ls.snippet_node
local t = ls.text_node
local i = ls.insert_node
local f = ls.function_node
local d = ls.dynamic_node
local c = ls.choice_node

local isn = ls.indent_snippet_node
local fmt = require("luasnip.extras.fmt").fmt
local types = require("luasnip.util.types")
local events = require("luasnip.util.events")
local r = ls.restore_node

local function node_with_virtual_text(pos, node, text)
  local nodes
  if node.type == types.textNode then
    node.pos = 2
    nodes = { i(1), node }
  else
    node.pos = 1
    nodes = { node }
  end
  return sn(pos, nodes, {
    callbacks = {
      -- node has pos 1 inside the snippetNode.
      [1] = {
        [events.enter] = function(nd)
          -- node_pos: {line, column}
          local node_pos = nd.mark:pos_begin()
          -- reuse luasnips namespace, column doesn't matter, just 0 it.
          nd.virt_text_id = vim.api.nvim_buf_set_extmark(0, ls.session.ns_id, node_pos[1], 0, {
            virt_text = { { text, "GruvboxOrange" } },
          })
        end,
        [events.leave] = function(nd)
          vim.api.nvim_buf_del_extmark(0, ls.session.ns_id, nd.virt_text_id)
        end,
      },
    },
  })
end

local function nodes_with_virtual_text(nodes, opts)
  if opts == nil then
    opts = {}
  end
  local new_nodes = {}
  for pos, node in ipairs(nodes) do
    if opts.texts[pos] ~= nil then
      node = node_with_virtual_text(pos, node, opts.texts[pos])
    end
    table.insert(new_nodes, node)
  end
  return new_nodes
end

local function choice_text_node(pos, choices, opts)
  choices = nodes_with_virtual_text(choices, opts)
  return c(pos, choices, opts)
end

local ct = choice_text_node

local function py_init()
  return c(1, {
    t "",
    sn(1, {
      t ", ",
      i(1),
      d(2, py_init),
    }),
  })
end

-- splits the string of the comma separated argument list into the arguments
-- and returns the text-/insert- or restore-nodes
local function to_init_assign(args)
  local tab = {}
  local a = args[1][1]
  if #a == 0 then
    table.insert(tab, t { "", "\tpass" })
  else
    local cnt = 1
    for e in string.gmatch(a, " ?([^,]*) ?") do
      if #e > 0 then
        table.insert(tab, t { "", "\tself." })
        -- use a restore-node to be able to keep the possibly changed attribute name
        -- (otherwise this function would always restore the default, even if the user
        -- changed the name)
        table.insert(tab, r(cnt, tostring(cnt), i(nil, e)))
        table.insert(tab, t " = ")
        table.insert(tab, t(e))
        cnt = cnt + 1
      end
    end
  end
  return sn(nil, tab)
end


local function generic_pdoc(ilevel, args)
  local nodes = { t({ "'''", string.rep('\t', ilevel) }) }
  nodes[#nodes + 1] = i(1, 'Small Description.')
  nodes[#nodes + 1] = t({ '', '', string.rep('\t', ilevel) })
  nodes[#nodes + 1] = i(2, 'Long Description')
  nodes[#nodes + 1] = t({ '', '', string.rep('\t', ilevel) .. 'Args:' })

  local a = vim.tbl_map(function(item)
    local trimed = vim.trim(item)
    return trimed
  end, vim.split(
    args[1][1],
    ',',
    true
  ))

  if args[1][1] == '' then
    a = {}
  end

  for idx, v in pairs(a) do
    nodes[#nodes + 1] = t({ '', string.rep('\t', ilevel + 1) .. v .. ': ' })
    nodes[#nodes + 1] = i(idx + 2, 'Description For ' .. v)
  end

  return nodes, #a
end

local function pyfdoc(args, ostate)
  local nodes, a = generic_pdoc(1, args)
  nodes[#nodes + 1] = c(a + 2 + 1, { t(''), t({ '', '', '\tReturns:' }) })
  nodes[#nodes + 1] = i(a + 2 + 2)
  nodes[#nodes + 1] = c(a + 2 + 3, { t(''), t({ '', '', '\tRaises:' }) })
  nodes[#nodes + 1] = i(a + 2 + 4)
  nodes[#nodes + 1] = t({ '', "\t'''", '\t' })
  local snip = sn(nil, nodes)
  snip.old_state = ostate or {}
  return snip
end

local function pycdoc(args, ostate)
  local nodes, _ = generic_pdoc(2, args)
  nodes[#nodes + 1] = t({ '', "\t\t'''", '' })
  local snip = sn(nil, nodes)
  snip.old_state = ostate or {}
  return snip
end

-- create the actual snippet
local snippets = {
  s("#!", {
    t { "#!/usr/bin/env python", "" },
    i(0),
  }),
  s({ trig = 'class', dscr = 'Documented Class Structure' }, {
    t('class '),
    i(1, { 'NewClass' }),
    t('('),
    i(2, { '' }),
    t({ '):', '\t' }),
    t({ 'def init(self,' }),
    i(3),
    t({ '):', '\t\t' }),
    d(4, pycdoc, { 3 }, { 2 }),
    f(function(args)
      if not args[1][1] or args[1][1] == '' then
        return { '' }
      end
      local a = vim.tbl_map(function(item)
        local trimed = vim.trim(item)
        return '\t\tself.' .. trimed .. ' = ' .. trimed
      end, vim.split(
        args[1][1],
        ',',
        true
      ))
      return a
    end, {
      3,
    }),
    i(0),
  }),
  s({ trig = 'def', dscr = 'Documented Function Structure' }, {
    t('def '),
    i(1, { 'function' }),
    t('('),
    i(2),
    t({ '):', '\t' }),
    d(3, pyfdoc, { 2 }, { 1 }),
  }),
}
return snippets
