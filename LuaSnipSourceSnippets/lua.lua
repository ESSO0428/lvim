local ls = require("luasnip")
local s = ls.snippet
local sn = ls.snippet_node
local t = ls.text_node
local i = ls.insert_node
local f = ls.function_node
local c = ls.choice_node
local d = ls.dynamic_node
local l = require("luasnip.extras").lambda
local r = require("luasnip.extras").rep
local p = require("luasnip.extras").partial
local m = require("luasnip.extras").match
local n = require("luasnip.extras").nonempty
local dl = require("luasnip.extras").dynamic_lambda
local fmt = require("luasnip.extras.fmt").fmt
local fmta = require("luasnip.extras.fmt").fmta
local types = require("luasnip.util.types")
local conds = require("luasnip.extras.expand_conditions")
local events = require("luasnip.util.events")

-- print("... in lua -> `" .. ... .. "`")

local utils = {}

-- -- args is a table, where 1 is the text in Placeholder 1, 2 the text in
-- -- placeholder 2,...
utils.copy = function(args)
  return args[1]
end

-- Returns a snippet_node wrapped around an insert_node whose initial
-- text value is set to the current date in the desired format.
utils.date_input = function(args, state, fmt)
  local fmt = fmt or "%Y-%m-%d"
  return sn(nil, i(1, os.date(fmt)))
end

-- Make sure to not pass an invalid command, as io.popen() may write over nvim-text.
-- $(git config github.user)
utils.bash = function(_, _, command)
  local file = io.popen(command, "r")
  local res = {}
  for line in file:lines() do
    table.insert(res, line)
  end
  return res
end

utils.part = function(func, ...)
  local args = { ... }
  return function() return func(unpack(args)) end
end

utils.pair = function(pair_begin, pair_end, expand_func, ...)
  return s({ trig = pair_begin, wordTrig = false }, { t({ pair_begin }), i(1), t({ pair_end }) },
    { condition = utils.part(expand_func, utils.part(..., pair_begin, pair_end)) })
end

-- complicated function for dynamicNode.
utils.jdocsnip = function(args, _, old_state)
  local nodes = {
    t({ "/**", " * " }),
    i(1, "A short Description"),
    t({ "", "" }),
  }

  -- These will be merged with the snippet; that way, should the snippet be updated,
  -- some user input eg. text can be referred to in the new snippet.
  local param_nodes = {}

  if old_state then
    nodes[2] = i(1, old_state.descr:get_text())
  end
  param_nodes.descr = nodes[2]

  -- At least one param.
  if string.find(args[2][1], ", ") then
    vim.list_extend(nodes, { t({ " * ", "" }) })
  end

  local insert = 2
  for indx, arg in ipairs(vim.split(args[2][1], ", ", true)) do
    -- Get actual name parameter.
    arg = vim.split(arg, " ", true)[2]
    if arg then
      local inode
      -- if there was some text in this parameter, use it as static_text for this new snippet.
      if old_state and old_state[arg] then
        inode = i(insert, old_state["arg" .. arg]:get_text())
      else
        inode = i(insert)
      end
      vim.list_extend(
        nodes,
        { t({ " * @param " .. arg .. " " }), inode, t({ "", "" }) }
      )
      param_nodes["arg" .. arg] = inode

      insert = insert + 1
    end
  end

  if args[1][1] ~= "void" then
    local inode
    if old_state and old_state.ret then
      inode = i(insert, old_state.ret:get_text())
    else
      inode = i(insert)
    end

    vim.list_extend(
      nodes,
      { t({ " * ", " * @return " }), inode, t({ "", "" }) }
    )
    param_nodes.ret = inode
    insert = insert + 1
  end

  if vim.tbl_count(args[3]) ~= 1 then
    local exc = string.gsub(args[3][2], " throws ", "")
    local ins
    if old_state and old_state.ex then
      ins = i(insert, old_state.ex:get_text())
    else
      ins = i(insert)
    end
    vim.list_extend(
      nodes,
      { t({ " * ", " * @throws " .. exc .. " " }), ins, t({ "", "" }) }
    )
    param_nodes.ex = ins
    insert = insert + 1
  end

  vim.list_extend(nodes, { t({ " */" }) })

  local snip = sn(nil, nodes)
  -- Error on attempting overwrite.
  snip.old_state = param_nodes
  return snip
end

-- TODO: convert to lua
-- complicated function for dynamicNode.
utils.luadocsnip = function(args, _, old_state)
  local nodes = {
    t({ "/**", " * " }),
    i(1, "A short Description"),
    t({ "", "" }),
  }

  -- These will be merged with the snippet; that way, should the snippet be updated,
  -- some user input eg. text can be referred to in the new snippet.
  local param_nodes = {}

  if old_state then
    nodes[2] = i(1, old_state.descr:get_text())
  end
  param_nodes.descr = nodes[2]

  -- At least one param.
  if string.find(args[2][1], ", ") then
    vim.list_extend(nodes, { t({ " * ", "" }) })
  end

  local insert = 2
  for indx, arg in ipairs(vim.split(args[2][1], ", ", true)) do
    -- Get actual name parameter.
    arg = vim.split(arg, " ", true)[2]
    if arg then
      local inode
      -- if there was some text in this parameter, use it as static_text for this new snippet.
      if old_state and old_state[arg] then
        inode = i(insert, old_state["arg" .. arg]:get_text())
      else
        inode = i(insert)
      end
      vim.list_extend(
        nodes,
        { t({ " * @param " .. arg .. " " }), inode, t({ "", "" }) }
      )
      param_nodes["arg" .. arg] = inode

      insert = insert + 1
    end
  end

  if args[1][1] ~= "void" then
    local inode
    if old_state and old_state.ret then
      inode = i(insert, old_state.ret:get_text())
    else
      inode = i(insert)
    end

    vim.list_extend(
      nodes,
      { t({ " * ", " * @return " }), inode, t({ "", "" }) }
    )
    param_nodes.ret = inode
    insert = insert + 1
  end

  if vim.tbl_count(args[3]) ~= 1 then
    local exc = string.gsub(args[3][2], " throws ", "")
    local ins
    if old_state and old_state.ex then
      ins = i(insert, old_state.ex:get_text())
    else
      ins = i(insert)
    end
    vim.list_extend(
      nodes,
      { t({ " * ", " * @throws " .. exc .. " " }), ins, t({ "", "" }) }
    )
    param_nodes.ex = ins
    insert = insert + 1
  end

  vim.list_extend(nodes, { t({ " */" }) })

  local snip = sn(nil, nodes)
  -- Error on attempting overwrite.
  snip.old_state = param_nodes
  return snip
end

-- local c = ls.choice_node
-- local sn = ls.snippet_node
-- local isn = ls.indent_snippet_node

-- Needed for fancy snippets
local ts_utils_ok, ts_utils = pcall(require, "nvim-treesitter.ts_utils")
if not ts_utils_ok then
  return {}
end

local query = require "vim.treesitter.query"
local function_q = vim.treesitter.query.parse(
  "lua",
  [[
    [
        (function_declaration parameters: (parameters) @parms)
        (function_definition parameters: (parameters) @parms)
    ] @fun
]]
)
-- This only matches returns that actually return something, so early return can still be used for
-- control flow!
local return_q = vim.treesitter.query.parse("lua", "(return_statement (expression_list)) @ret")

--- Obtains list of parameter names for the next lua function and whether it returns something.
-- @param linenr Line number at which we start searching.
-- @return parms, ret where parms is a list of parameters, in the order that they appear in the
--         function and ret is truthy if the function ever returns something.
local function next_fun_parms(linenr)
  local bufnr = vim.api.nvim_get_current_buf()

  -- TODO: Doesn't work if we land inside of a comment block because that's a different
  -- "language".
  local root = ts_utils.get_root_for_position(linenr - 1, 0)
  if not root then
    return
  end

  for _, captures, _ in function_q:iter_matches(root, bufnr) do
    local sline = captures[1]:range()

    if sline >= linenr - 1 then
      local parms = {}
      for parm, node_type in captures[1]:iter_children() do
        -- Parameters are given via "name" nodes, other nodes might be comments etc.
        if node_type == "name" then
          table.insert(parms, query.get_node_text(parm, bufnr))
        end
      end

      local returns = return_q:iter_matches(captures[2], bufnr)()
      return parms, returns
    end
  end
end

local snippets = {
  -- LEARNING ---------

  -- isn indent node >>
  -- START: UNDERSTAND
  -- arstss
  -- END: UNDERSTAND

  -- s("understand", {
  --     t("text_node"),
  -- }),

  -- PRINTS -----------

  s("lua print var", {
    t("print(\""),
    i(1, "desrc"),
    t(": \" .. "),
    i(2, "the_variable"),
    t(")"),
  }),


  --------------------------------------------
  ---       lua function definitions       ---
  --------------------------------------------

  -- TODO: convert to lua
  -- Very long example for a java class.
  s("fndef", {
    d(6, utils.luadocsnip, { 2, 4, 5 }),
    t({ "", "" }),
    c(1, {
      t("public "),
      t("private "),
    }),
    c(2, {
      t("void"),
      t("String"),
      t("char"),
      t("int"),
      t("double"),
      t("boolean"),
      i(nil, ""),
    }),
    t(" "),
    i(3, "myFunc"),
    t("("),
    i(4),
    t(")"),
    c(5, {
      t(""),
      sn(nil, {
        t({ "", " throws " }),
        i(1),
      }),
    }),
    t({ " {", "\t" }),
    i(0),
    t({ "", "}" }),
  }),

  -- inline
  -- callback
  -- anonymous
  -- table anonymous
  --
  -- lua doc params

  s("fn basic", {
    t("-- @param: "), f(utils.copy, 2),
    t({ "", "local " }), i(1), t(" = function("), i(2, "fn param"), t({ ")", "\t" }),
    i(0), -- Last Placeholder, exit Point of the snippet. EVERY 'outer' SNIPPET NEEDS Placeholder 0.
    t({ "", "end" }),
  }),

  s("fn module", {
    -- make new line into snippet
    t("-- @param: "), f(utils.copy, 3), t({ "", "" }),
    i(1, "modname"), t("."), i(2, "fnname"), t(" = function("), i(3, "fn param"), t({ ")", "\t" }),
    i(0), -- Last Placeholder, exit Point of the snippet. EVERY 'outer' SNIPPET NEEDS Placeholder 0.
    t({ "", "end" }),
  }),

  -------------------------------------
  ---       lua function call       ---
  -------------------------------------

  -- dynamic extensible params
  -- table

  ------------------------------
  ---       lua tables       ---
  ------------------------------
  -- key value pairs
  -- named sub tables
  --




  --------------------------------
  ---       conditionals       ---
  --------------------------------
  -- if nil
  -- elseif

  s({ trig = "if basic", wordTrig = true }, {
    t({ "if " }),
    i(1),
    t({ " then", "\t" }),
    i(0),
    t({ "", "end" })
  }),

  s({ trig = "ee", wordTrig = true }, {
    t({ "else", "\t" }),
    i(0),
  }),

  -- LOOPS ----------------------------------------

  s("for", {
    t "for ", c(1, {
      sn(nil, { i(1, "k"), t ", ", i(2, "v"), t " in ", c(3, { t "pairs", t "ipairs" }), t "(", i(4), t ")" }),
      sn(nil, { i(1, "i"), t " = ", i(2), t ", ", i(3), })
    }), t { " do", "\t" }, i(0), t { "", "end" }
  }),

  ---------------------------
  ---       strings       ---
  ---------------------------
  -- if fs.file_exists(string.format("%s/doc/doom_nvim.norg", system.doom_root)) then
  --


  -------------------------
  ---       regex       ---
  -------------------------
  -- for release in doom_releases:gmatch("[^\r\n]+") do
  -- for release_hash, version in version_info:gmatch("(%w+)%s(%w+%W+%w+%W+%w+)") do
  -- local backup_commit = fs.read_file(rolling_backup):gsub("[\r\n]+", "")
  -- local start_line = vim.fn.getline(vim.v.foldstart):gsub("\t", ("\t"):rep(vim.opt.tabstop:get()))
  -- local start_line = vim.fn.getline(vim.v.foldstart):gsub("\t", ("\t"):rep(vim.opt.tabstop:get()))
  -- sorted_releases[#releases + 1 - idx] = release:gsub("refs/tags/", "")

  -----------------------
  ---       i/o       ---
  -----------------------
  -- fs.write_file(releases_database_path, release .. "\n", "a+")
  ls.parser.parse_snippet("lm", "local M = {}\n\nfunction M.setup()\n  $1 \nend\n\nreturn M"),
  -- s("lm", { t { "local M = {}", "", "function M.setup()", "" }, i(1, ""), t { "", "end", "", "return M" } }),



  ls.parser.parse_snippet("for", "for ${1:i} = ${2:1}, ${3:n} do\n\t$0\nend"),
  ls.parser.parse_snippet("fun", "local function ${1:name}($2)\n\t$0\nend"),
  ls.parser.parse_snippet("while", "while ${1:cond} do\n\t$0\nend"),
  ls.parser.parse_snippet("mfun", "function M.${1:name}($2)\n\t$0\nend"),
  ls.parser.parse_snippet("pairs", "for ${1:key}, ${2:value} in pairs($3) do\n\t$0\nend"),
  ls.parser.parse_snippet("ipairs", "for ${1:i}, ${2:value} in ipairs($3) do\n\t$0\nend"),
  ls.parser.parse_snippet("if", "if ${1:cond} then\n\t$0\nend"),
  ls.parser.parse_snippet("ifn", "if not ${1:cond} then\n\t$0\nend"),

  s("todo", t 'print("TODO")'),

  -- s("req", fmt("local {} = require('{}')", { i(1, "default"), rep(1) })),
  s(
    "localreq",
    fmt('local {} = require("{}")', {
      l(l._1:match("[^.]*$"):gsub("[^%a]+", "_"), 1),
      i(1, "module"),
    })
  ),
  s(
    "localreq2",
    fmt([[local {} = require "{}"]], {
      f(function(import_name)
        local parts = vim.split(import_name[1][1], ".", true)
        return parts[#parts] or ""
      end, {
        1,
      }),
      i(1),
    })
  ),

  s(
    "preq",
    fmt('local {1}_ok, {1} = pcall(require, "{}")\nif not {1}_ok then return end', {
      l(l._1:match("[^.]*$"):gsub("[^%a]+", "_"), 1),
      i(1, "module"),
    })
  ),

  s("doc", {
    t "--- ",
    i(1, "Function description."),
    d(2, function(_, snip)
      local parms, ret = next_fun_parms(tonumber(snip.env.TM_LINE_NUMBER))
      assert(parms, "Did not find a function!")

      local parm_nodes = {}
      for j, parm in ipairs(parms) do
        table.insert(parm_nodes, t { "", "-- @param " .. parm .. " " })
        table.insert(parm_nodes, i(j, "Parameter description."))
      end

      if ret then
        table.insert(parm_nodes, t { "", "-- @return " })
        table.insert(parm_nodes, i(#parms + 1, "Return description."))
      end

      return s(1, parm_nodes)
    end),
  }),
}

return snippets -- , autosnippets
