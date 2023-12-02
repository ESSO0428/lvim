require("bufferline.tabpages").get = function()
  local lazy = require("bufferline.lazy")
  local ui = lazy.require("bufferline.ui") ---@module "bufferline.ui"
  local pick = lazy.require("bufferline.pick") ---@module "bufferline.pick"
  local config = lazy.require("bufferline.config") ---@module "bufferline.config"
  local constants = lazy.require("bufferline.constants") ---@module "bufferline.constants"
  local duplicates = lazy.require("bufferline.duplicates") ---@module "bufferline.duplicates"
  local diagnostics = lazy.require("bufferline.diagnostics") ---@module "bufferline.diagnostics"
  local utils = lazy.require("bufferline.utils") ---@module "bufferline.utils"
  local models = lazy.require("bufferline.models") ---@module "bufferline.models"

  local padding = constants.padding

  local function tab_click_component(num) return "%" .. num .. "T" end
  local function render(tabpage, is_active, style, highlights)
    local h = highlights
    local hl = is_active and h.tab_selected.hl_group or h.tab.hl_group
    local separator_hl = is_active and h.tab_separator_selected.hl_group or h.tab_separator.hl_group
    local chars = constants.sep_chars[style] or constants.sep_chars.thin
    require('tabline').tabline_tabs()
    local TablineData = vim.fn.json_decode(vim.g.Tabline_session_data)
    local name
    -- if TablineData[tabpage.tabnr] then
    local name = padding .. TablineData[tabpage.tabnr].name .. padding
    -- else
    -- local name = padding .. tabpage.tabnr .. padding
    -- end
    local char_order = ({ thick = { 1, 2 }, thin = { 1, 2 } })[style] or { 2, 1 }
    return {
      { highlight = separator_hl, text = chars[char_order[1]] },
      {
        highlight = hl,
        text = name,
        attr = { prefix = tab_click_component(tabpage.tabnr) },
      },
      { highlight = separator_hl, text = chars[char_order[2]] },
    }
  end

  local tabs = vim.fn.gettabinfo()
  local current_tab = vim.fn.tabpagenr()
  local highlights = config.highlights
  local style = config.options.separator_style
  return utils.map(function(tab)
    local is_active_tab = current_tab == tab.tabnr
    local components = render(tab, is_active_tab, style, highlights)
    return {
      component = components,
      id = tab.tabnr,
      windows = tab.windows,
    }
  end, tabs)
end
