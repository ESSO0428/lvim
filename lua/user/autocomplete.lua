require "user.snippets"
require("luasnip.loaders.from_lua").lazy_load { paths = "~/.config/lvim/LuaSnipSourceSnippets/" }
local cmp = require("lvim.utils.modules").require_on_index "cmp"
local cmp_mapping = require "cmp.config.mapping"
local luasnip = require("lvim.utils.modules").require_on_index "luasnip"
local cmp_ultisnips_mappings = require("cmp_nvim_ultisnips.mappings")
local original_cmp_path_dirname = require("cmp_path")._dirname

require("cmp_path").get_trigger_characters = function()
  return { '/', '.', "'", '"', ":" }
end
require("cmp_path")._dirname = function(self, params, option)
  local original_return = original_cmp_path_dirname(self, params, option)
  if original_return ~= nil then
    return original_return
  end
  local NAME_REGEX = "\\%([^/\\\\:\\*?<>'\"`\\|]\\)"
  local PATH_REGEX = vim.regex(([[\%([/"\']PAT\+\)*[/"\']\zePAT*$]]):gsub("PAT", NAME_REGEX))
  local cursor_line = params.context.cursor_before_line

  local s = PATH_REGEX:match_str(cursor_line)

  if s then
    local buf_dirname = option.get_cwd(params)
    local dirname = string.gsub(string.sub(cursor_line, s + 2), '%a*$', '') -- exclude '/'
    local prefix = string.sub(cursor_line, 1, s + 1)                        -- include '/'
    if prefix:match("\"$") or prefix:match("'$") then
      return vim.fn.resolve(buf_dirname .. "/" .. dirname)
    end
  end

  local orgmode_s = cursor_line:find("%[%[file:")
  if orgmode_s then
    local buf_dirname = option.get_cwd(params)
    local dirname = string.gsub(string.sub(cursor_line, orgmode_s + 7), '%a*$', '') -- exclude '/'
    local prefix = string.sub(cursor_line, 7, orgmode_s + 7)                        -- include '/'
    if prefix:match(':/$') then
      return vim.fn.resolve('/' .. dirname)
    end
  end

  return nil
end

lvim.builtin.cmp.enabled = function()
  local filetype = vim.api.nvim_get_option_value("filetype", { buf = 0 })
  if filetype == "neo-tree-popup" or filetype == "prompt" or filetype == "TelescopePrompt" then
    return false or require("cmp_dap").is_dap_buffer()
  end
  return lvim.builtin.cmp.active
end
require("cmp").setup.filetype({ "dap-repl", "dapui_watches", "dapui_hover" }, {
  sources = {
    { name = "dap" },
    {
      name = "buffer",
      option = {
        get_bufnrs = function()
          local max_size = 100000 -- 设置文件大小限制为 100,000 字节
          local bufs = {}

          -- 获取当前 Tab 中的所有窗口
          local windows = vim.api.nvim_tabpage_list_wins(0)
          for _, win in ipairs(windows) do
            -- 获取每个窗口的缓冲区编号
            local buf = vim.api.nvim_win_get_buf(win)
            -- 检查文件类型是否不是 neo-tree
            if vim.api.nvim_get_option_value("filetype", { buf = buf }) ~= 'neo-tree' then
              -- 检查文件大小
              local size = vim.fn.getfsize(vim.api.nvim_buf_get_name(buf))
              if size > 0 and size < max_size then
                bufs[buf] = true
              end
            end
          end

          return vim.tbl_keys(bufs)
        end
      }
    }
  }
})
require("cmp").setup.filetype({ "copilot-chat" }, {
  sources = {
    { name = "copilot-chat" },
    { name = "copilot" },
    {
      name = "buffer",
      option = {
        get_bufnrs = function()
          local max_size = 100000 -- 设置文件大小限制为 100,000 字节
          local bufs = {}

          -- 获取当前 Tab 中的所有窗口
          local windows = vim.api.nvim_tabpage_list_wins(0)
          for _, win in ipairs(windows) do
            -- 获取每个窗口的缓冲区编号
            local buf = vim.api.nvim_win_get_buf(win)
            -- 检查文件类型是否不是 neo-tree
            if vim.api.nvim_get_option_value("filetype", { buf = buf }) ~= 'neo-tree' then
              -- 检查文件大小
              local size = vim.fn.getfsize(vim.api.nvim_buf_get_name(buf))
              if size > 0 and size < max_size then
                bufs[buf] = true
              end
            end
          end

          return vim.tbl_keys(bufs)
        end
      }
    },
    { name = "path" }
  }
})
lvim.builtin.cmp.snippet = {
  expand = function(args)
    -- luasnip.lsp_expand(args.body)
    vim.fn["UltiSnips#Anon"](args.body)
  end,
}
lvim.builtin.cmp.performance = {
  trigger_debounce_time = 500,
  throttle = 550,
  fetching_timeout = 80,
}
local function remove_copilot_if_node_version_too_low()
  -- 執行 `node --version` 並獲取輸出
  local handle = io.popen("node --version")
  local result = handle:read("*a")
  handle:close()

  -- 解析版本號
  local major, minor, patch = result:match("v(%d+)%.(%d+)%.(%d+)")
  major, minor, patch = tonumber(major), tonumber(minor), tonumber(patch)

  -- 檢查版本是否低於標準（假設標準是 18.x）
  if major and major < 18 then
    -- 遍歷並移除 copilot
    for i, source in ipairs(lvim.builtin.cmp.sources) do
      if source.name == "copilot" then
        table.remove(lvim.builtin.cmp.sources, i)
        print(
          table.concat(
            { 'Copilot: Node.js version 18.x ablove required',
              '(neaad update; ex: nvm install 19.8.1 && nvm use 19.8.1 >> ~/.bashrc)' }, ' '))
        break
      end
    end
  end
end

-- 調用函數
remove_copilot_if_node_version_too_low()
lvim.builtin.cmp.experimental.ghost_text = true
-- lvim.builtin.cmp.sources[#lvim.builtin.cmp.sources + 1] = { name = "luasnip" }
-- lvim.builtin.cmp.sources[#lvim.builtin.cmp.sources + 1] = { name = "jupyter" }
table.insert(lvim.builtin.cmp.sources, 2, { name = "jupyter", priority = 10 })
table.insert(lvim.builtin.cmp.sources, 3, { name = "jupynium", priority = 10 })
lvim.builtin.cmp.sources[#lvim.builtin.cmp.sources + 1] = { name = "lazydev", group_index = 0 }
lvim.builtin.cmp.sources[#lvim.builtin.cmp.sources + 1] = { name = "cmdline_history" }
lvim.builtin.cmp.sources[#lvim.builtin.cmp.sources + 1] = { name = "ultisnips" }
lvim.builtin.cmp.sources[#lvim.builtin.cmp.sources + 1] = { name = "vsnip" }
lvim.builtin.cmp.sources[#lvim.builtin.cmp.sources + 1] = { name = "orgmode" }
lvim.builtin.cmp.sources[#lvim.builtin.cmp.sources + 1] = { name = "dap" }
lvim.builtin.cmp.sources[#lvim.builtin.cmp.sources + 1] = { name = "vim-dadbod-completion" }

table.insert(lvim.builtin.cmp.sources, 1, {
  name = "html-css",
  priority = 10,
  option = {
    max_count = {}, -- not ready yet
    enable_on = {
      "htmldjango",
      "html",
      "php",
    },                                            -- set the file types you want the plugin to work on
    enable_file_patterns = { "*.html", "*.php" }, -- set the file patterns you want the plugin to work on
    file_extensions = { "css", "sass", "less" },  -- set the local filetypes from which you want to derive classes
    -- style_sheets = {
    -- example of remote styles, only css no js for now
    -- "https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css",
    -- "https://cdn.jsdelivr.net/npm/bulma@0.9.4/css/bulma.min.css",
    -- }
  }
})
lvim.builtin.cmp.formatting.source_names["html-css"] = "(html-css)"
---[[
lvim.builtin.cmp.formatting.format = function(entry, vim_item)
  local max_width = lvim.builtin.cmp.formatting.max_width
  if max_width ~= 0 and #vim_item.abbr > max_width then
    vim_item.abbr = string.sub(vim_item.abbr, 1, max_width - 1) .. lvim.icons.ui.Ellipsis
  end

  -- tailwindcss color preview
  local doc = entry.completion_item.documentation
  if vim_item.kind == "Color" and doc then
    local utils = require("tailwind-tools.utils")
    local content = type(doc) == "string" and doc or doc.value
    local base, _, _, _r, _g, _b = 10, content:find("rgba?%((%d+), (%d+), (%d+)")

    if not _r then
      base, _, _, _r, _g, _b = 16, content:find("#(%x%x)(%x%x)(%x%x)")
    end

    if _r then
      local r, g, b = tonumber(_r, base), tonumber(_g, base), tonumber(_b, base)
      vim_item.kind_hl_group = utils.set_hl_from(r, g, b, "foreground")
    end
  end

  if lvim.use_icons then
    vim_item.kind = lvim.builtin.cmp.formatting.kind_icons[vim_item.kind]

    if entry.source.name == "copilot" then
      if vim.bo.filetype == "prompt" then
        return
      end
      vim_item.kind = lvim.icons.git.Octoface
      vim_item.kind_hl_group = "CmpItemKindCopilot"
    end
    if entry.source.name == "copilot-chat" then
      vim_item.kind = lvim.icons.git.Octoface
      vim_item.kind_hl_group = "CmpItemKindCopilot"
    end
    if entry.source.name == "cmp_tabnine" then
      vim_item.kind = lvim.icons.misc.Robot
      vim_item.kind_hl_group = "CmpItemKindTabnine"
    end

    if entry.source.name == "crates" then
      vim_item.kind = lvim.icons.misc.Package
      vim_item.kind_hl_group = "CmpItemKindCrate"
    end

    if entry.source.name == "lab.quick_data" then
      vim_item.kind = lvim.icons.misc.CircuitBoard
      vim_item.kind_hl_group = "CmpItemKindConstant"
    end

    if entry.source.name == "emoji" then
      vim_item.kind = lvim.icons.misc.Smiley
      vim_item.kind_hl_group = "CmpItemKindEmoji"
    end

    if entry.source.name == "orgmode" then
      -- vim_item.kind = ""
      -- vim_item.kind_hl_group = "CmpItemKindCopilot"
      local ok, devicons = pcall(require, 'nvim-web-devicons')
      if ok then
        local icon, icon_highlight_group = devicons.get_icon(vim.fn.expand('%:t'))
        if icon == nil then
          icon, icon_highlight_group = devicons.get_icon_by_filetype(vim.bo.filetype)
        end
        vim_item.kind = icon
        vim_item.kind_hl_group = icon_highlight_group
      end
    end
    if entry.source.name == "vim-dadbod-completion" then
      vim_item.kind = ""
      vim_item.kind_hl_group = "CmpItemKindEmoji"
    end
  end
  vim_item.menu = lvim.builtin.cmp.formatting.source_names[entry.source.name]
  vim_item.dup = lvim.builtin.cmp.formatting.duplicates[entry.source.name]
      or lvim.builtin.cmp.formatting.duplicates_default

  if entry.source.name == "html-css" then
    -- vim_item.menu = entry.source.menu
    vim_item.menu = '(html-css)' .. ' ' .. entry.completion_item.menu
  end
  return vim_item
end
--]]
-- lvim.builtin.cmp.formatting.source_names["html-css"] = "(html-css)"
-- pcall(require('html-css'):setup())

--[[
for i, source in pairs(lvim.builtin.cmp.sources) do
  if source.name == "buffer" then
    lvim.builtin.cmp.sources[i] = {
      name = "buffer",
      option = {
        get_bufnrs = function()
          local function is_not_neotree(buf)
            return vim.api.nvim_buf_get_option(buf, 'filetype') ~= 'neo-tree'
          end

          local buf_list = vim.api.nvim_list_bufs()
          local filtered_buf_list = vim.tbl_filter(is_not_neotree, buf_list)
          return filtered_buf_list
        end
      }
    }
  end
end
--]]
--[[
for i, source in pairs(lvim.builtin.cmp.sources) do
  if source.name == "buffer" then
    lvim.builtin.cmp.sources[i] = {
      name = "buffer",
      option = {
        get_bufnrs = function()
          local function is_not_neotree(buf)
            return vim.api.nvim_buf_get_option(buf, 'filetype') ~= 'neo-tree'
          end

          local buf_list = vim.api.nvim_list_bufs()
          local filtered_buf_list = vim.tbl_filter(is_not_neotree, buf_list)
          return filtered_buf_list
        end
      }
    }
  end
end
--]]
function BufferAllCompleteToggle()
  for i, source in pairs(lvim.builtin.cmp.sources) do
    if source.name == "buffer" then
      if not lvim.builtin.cmp.sources[i].option or next(lvim.builtin.cmp.sources[i].option) == nil then
        lvim.builtin.cmp.sources[i] = {
          name = "buffer",
          option = {
            get_bufnrs = function()
              local function is_not_neotree(buf)
                return vim.api.nvim_get_option_value("filetype", { buf = buf }) ~= 'neo-tree'
              end

              local buf_list = vim.api.nvim_list_bufs()
              local filtered_buf_list = vim.tbl_filter(is_not_neotree, buf_list)
              return filtered_buf_list
            end
          }
        }
      else
        lvim.builtin.cmp.sources[i] = {
          name = "buffer",
          option = {}
        }
      end
    else
      util_cmp_config(i, source)
    end
  end
end

function CurrentTabCompleteToggle()
  for i, source in pairs(lvim.builtin.cmp.sources) do
    if source.name == "buffer" then
      if not lvim.builtin.cmp.sources[i].option or next(lvim.builtin.cmp.sources[i].option) == nil then
        lvim.builtin.cmp.sources[i] = {
          name = "buffer",
          option = {
            get_bufnrs = function()
              local max_size = 100000 -- 设置文件大小限制为 100,000 字节
              local bufs = {}

              -- 获取当前 Tab 中的所有窗口
              local windows = vim.api.nvim_tabpage_list_wins(0)
              for _, win in ipairs(windows) do
                -- 获取每个窗口的缓冲区编号
                local buf = vim.api.nvim_win_get_buf(win)
                -- 检查文件类型是否不是 neo-tree
                if vim.api.nvim_get_option_value("filetype", { buf = buf }) ~= 'neo-tree' then
                  -- 检查文件大小
                  local size = vim.fn.getfsize(vim.api.nvim_buf_get_name(buf))
                  if size > 0 and size < max_size then
                    bufs[buf] = true
                  end
                end
              end

              return vim.tbl_keys(bufs)
            end
          }
        }
      else
        lvim.builtin.cmp.sources[i] = {
          name = "buffer",
          option = {}
        }
      end
    else
      util_cmp_config(i, source)
    end
  end
end

function util_cmp_config(i, source)
  if source.name == "nvim_lsp" then
    lvim.builtin.cmp.sources[i] = {
      name = "nvim_lsp",
      priority = 10,
      -- max_item_count = 200,
      entry_filter = function(entry, ctx)
        local kind = require("cmp.types.lsp").CompletionItemKind[entry:get_kind()]
        if kind == "Snippet" and ctx.prev_context.filetype == "java" then
          return false
        end
        return true
      end
    }
  end
end

CurrentTabCompleteToggle()
local status_cmp_ok, cmp_types = pcall(require, "cmp.types.cmp")
local ConfirmBehavior = cmp_types.ConfirmBehavior
local SelectBehavior = cmp_types.SelectBehavior
for k, v in pairs(lvim.builtin.cmp.mapping) do
  -- print(k)
  if k == "<C-K>" then
    lvim.builtin.cmp.mapping[k] = nil
    lvim.builtin.cmp.mapping["<M-i>"] = v
  end
  if k == "<C-J>" then
    lvim.builtin.cmp.mapping[k] = nil
  end
  if k == "<C-D>" then
    lvim.builtin.cmp.mapping[k] = nil
    lvim.builtin.cmp.mapping["<C-u>"] = v
  end
  if k == "<C-F>" then
    lvim.builtin.cmp.mapping[k] = nil
    lvim.builtin.cmp.mapping["<C-o>"] = v
  end
  if k == "<C-Y>" then
    local confirm_opts = vim.deepcopy(lvim.builtin.cmp.confirm_opts) -- avoid mutating the original opts below
    v = {
      -- i = cmp_mapping.confirm { behavior = ConfirmBehavior.Replace, select = false },
      i = cmp_mapping.confirm { confirm_opts },
      c = function(fallback)
        if cmp.visible() then
          cmp.confirm { behavior = ConfirmBehavior.Replace, select = false }
        else
          fallback()
        end
      end,
    }
    lvim.builtin.cmp.mapping["<M-l>"] = v
  end
  if k == "<Tab>" then
    lvim.builtin.cmp.mapping[k] = nil
    lvim.builtin.cmp.mapping["<M-d>"] = v
  end
  if k == "<S-Tab>" then
    lvim.builtin.cmp.mapping[k] = nil
    lvim.builtin.cmp.mapping["<M-a>"] = v
  end
  if k == "<C-Space>" then
    lvim.builtin.cmp.mapping[k] = nil
  end
  if k == "<C-E>" then
    lvim.builtin.cmp.mapping[k] = nil
  end
  if k == "<cr>" then
    lvim.builtin.cmp.mapping[k] = cmp_mapping(function(fallback)
      if cmp.visible() then
        local confirm_opts = vim.deepcopy(lvim.builtin.cmp.confirm_opts) -- avoid mutating the original opts below
        local is_insert_mode = function()
          return vim.api.nvim_get_mode().mode:sub(1, 1) == "i"
        end
        if is_insert_mode() then -- prevent overwriting brackets
          confirm_opts.behavior = ConfirmBehavior.Insert
        end
        local entry = cmp.get_selected_entry()
        local is_copilot = entry and entry.source.name == "copilot"
        -- if is_copilot then
        --   confirm_opts.behavior = ConfirmBehavior.Replace
        --   confirm_opts.select = true
        -- end
        if cmp.confirm(confirm_opts) then
          return -- success, exit early
        end
      end
      fallback() -- if not exited early, always fallback
    end)
  end
end
local cmp_mapping = require "cmp.config.mapping"
lvim.builtin.cmp.mapping['<M-i>'] = cmp_mapping(function(fallback)
  if cmp.visible() then
    -- cmp.select_prev_item()
    cmp.select_prev_item({ behavior = SelectBehavior.Select })
  else
    cmp.complete()
    --fallback()
  end
end, { "i", "c" })
lvim.builtin.cmp.mapping['<M-k>'] = cmp_mapping(function(fallback)
  if cmp.visible() then
    -- cmp.select_next_item()
    cmp.select_next_item({ behavior = SelectBehavior.Select })
  else
    cmp.complete()
    --fallback()
  end
end, { "i", "c" })

vim.keymap.set('i', '<a-j>', "<ESC>")
lvim.builtin.cmp.mapping["<M-j>"] = cmp.mapping(cmp_mapping.abort(), { "i", "c" })

lvim.builtin.cmp.formatting.source_names.lazydev = "(lazydev)"
lvim.builtin.cmp.formatting.source_names.vsnip = "(V-Snippet)"
lvim.builtin.cmp.formatting.source_names.luasnip = "(L-Snippet)"
lvim.builtin.cmp.formatting.source_names.ultisnips = "(U-Snippet)"
lvim.builtin.cmp.formatting.source_names.orgmode = "(orgmode)"
lvim.builtin.cmp.formatting.source_names.dap = "(dap)"
lvim.builtin.cmp.formatting.source_names['vim-dadbod-completion'] = "(dadbod-sql)"
lvim.builtin.cmp.formatting.source_names.jupyter = "(jupyter)"
lvim.builtin.cmp.formatting.source_names.jupynium = "(jupynium)"
lvim.builtin.cmp.formatting.source_names["copilot-chat"] = "(copilot-chat)"
lvim.builtin.cmp.formatting.duplicates = {
  ['html-css'] = 1,
  buffer = 1,
  path = 1,
  nvim_lsp = 1,
  luasnip = 1,
  ultisnips = 1,
  vsnip = 1,
}
-- 底下 UltiSnipsExpandTrigger 已經沒用了，但為了避免 visual model 的縮排受預設的 tab 受引響
-- 故故意設定無效按鍵
vim.g.UltiSnipsExpandTrigger = "<C-space>"
vim.g.UltiSnipsJumpBackwardTrigger = "<M-a>"
vim.g.UltiSnipsJumpForwardTrigger = "<M-d>"

-- vim.g.UltiSnipsListSnippets="<leader>l"
vim.g.UltiSnipsListSnippets = "<M-/>"
-- vim.g.UltiSnipsSnippetDirectories = { "$HOME/.config/lvim/Ultisnips/" }

-- vim.g.ultisnips_python_style="google"
-- lvim.builtin.cmp.formatting.format = function(entry, vim_item)
--   if entry.source.name == "html-css" then
--     vim_item.menu = entry.source.menu
--   end
--   return vim_item
-- end
