require "user.snippets"
require("luasnip.loaders.from_lua").lazy_load { paths = "~/.config/lvim/LuaSnipSourceSnippets/" }
local cmp = require("lvim.utils.modules").require_on_index "cmp"
local cmp_mapping = require "cmp.config.mapping"
local luasnip = require("lvim.utils.modules").require_on_index "luasnip"
local cmp_ultisnips_mappings = require("cmp_nvim_ultisnips.mappings")
lvim.builtin.cmp.snippet = {
  expand = function(args)
    -- luasnip.lsp_expand(args.body)
    vim.fn["UltiSnips#Anon"](args.body)
  end,
}
lvim.builtin.cmp.experimental.ghost_text = true
-- lvim.builtin.cmp.sources[#lvim.builtin.cmp.sources + 1] = { name = "luasnip" }
-- lvim.builtin.cmp.sources[#lvim.builtin.cmp.sources + 1] = { name = "jupyter" }
table.insert(lvim.builtin.cmp.sources, 2, { name = "jupyter" })
lvim.builtin.cmp.sources[#lvim.builtin.cmp.sources + 1] = { name = "ultisnips" }
lvim.builtin.cmp.sources[#lvim.builtin.cmp.sources + 1] = { name = "vsnip" }
lvim.builtin.cmp.sources[#lvim.builtin.cmp.sources + 1] = { name = "orgmode" }
lvim.builtin.cmp.sources[#lvim.builtin.cmp.sources + 1] = { name = "vim-dadbod-completion" }
lvim.builtin.cmp.sources[#lvim.builtin.cmp.sources + 1] = {
  name = "spell",
  max_item_count = 3,
  option = {
    keep_all_entries = true,
    enable_in_context = function()
      return true
      -- return require('cmp.config.context').in_treesitter_capture('spell')
    end,
  },
}

lvim.builtin.cmp.sources[#lvim.builtin.cmp.sources + 1] = {
  name = "html-css",
  option = {
    max_count = {}, -- not ready yet
    enable_on = {
      "htmldjango",
      "html"
    },                                           -- set the file types you want the plugin to work on
    file_extensions = { "css", "sass", "less" }, -- set the local filetypes from which you want to derive classes
    -- style_sheets = {
    -- example of remote styles, only css no js for now
    -- "https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css",
    -- "https://cdn.jsdelivr.net/npm/bulma@0.9.4/css/bulma.min.css",
    -- }
  }
}
lvim.builtin.cmp.formatting.source_names["html-css"] = "(html-css)"
---[[
lvim.builtin.cmp.formatting.format = function(entry, vim_item)
  local max_width = lvim.builtin.cmp.formatting.max_width
  if max_width ~= 0 and #vim_item.abbr > max_width then
    vim_item.abbr = string.sub(vim_item.abbr, 1, max_width - 1) .. lvim.icons.ui.Ellipsis
  end
  if lvim.use_icons then
    vim_item.kind = lvim.builtin.cmp.formatting.kind_icons[vim_item.kind]

    if entry.source.name == "copilot" then
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
        icon, icon_highlight_group = devicons.get_icon(vim.fn.expand('%:t'))
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
    if entry.source.name == "spell" then
      vim_item.kind = "󰉿"
      vim_item.kind_hl_group = "CmpItemKindConstant"
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
                return vim.api.nvim_buf_get_option(buf, 'filetype') ~= 'neo-tree'
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
    end
  end
end

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
    lvim.builtin.cmp.mapping["<C-a>"] = v
  end
  if k == "<C-F>" then
    lvim.builtin.cmp.mapping[k] = nil
    lvim.builtin.cmp.mapping["<C-d>"] = v
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
  if k == "<CR>" then
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
    cmp.select_prev_item()
  else
    cmp.complete()
    --fallback()
  end
end, { "i", "c" })
lvim.builtin.cmp.mapping['<M-k>'] = cmp_mapping(function(fallback)
  if cmp.visible() then
    cmp.select_next_item()
  else
    cmp.complete()
    --fallback()
  end
end, { "i", "c" })

vim.keymap.set('i', '<a-j>', "<ESC>")
lvim.builtin.cmp.mapping["<M-j>"] = cmp.mapping(cmp_mapping.abort(), { "i", "c" })

lvim.builtin.cmp.formatting.source_names.vsnip = "(V-Snippet)"
lvim.builtin.cmp.formatting.source_names.luasnip = "(L-Snippet)"
lvim.builtin.cmp.formatting.source_names.ultisnips = "(U-Snippet)"
lvim.builtin.cmp.formatting.source_names.orgmode = "(orgmode)"
lvim.builtin.cmp.formatting.source_names['vim-dadbod-completion'] = "(dadbod-sql)"
lvim.builtin.cmp.formatting.source_names['spell'] = "(spell)"
lvim.builtin.cmp.formatting.source_names.jupyter = "(jupyter)"
lvim.builtin.cmp.formatting.duplicates = {
  buffer = 1,
  path = 1,
  nvim_lsp = 0,
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
vim.g.UltiSnipsListSnippets = "<M-n>"
-- vim.g.UltiSnipsSnippetDirectories = { "$HOME/.config/lvim/Ultisnips/" }

-- vim.g.ultisnips_python_style="google"
-- lvim.builtin.cmp.formatting.format = function(entry, vim_item)
--   if entry.source.name == "html-css" then
--     vim_item.menu = entry.source.menu
--   end
--   return vim_item
-- end
