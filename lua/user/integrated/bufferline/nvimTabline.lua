-- NOTE: 1. The primary modifications are within the 'require("bufferline.ui").tabline' function.
-- NOTE: 2. Use 'tabline.total_tab_length' directly to obtain the tab indicator instead of the previous method.
-- NOTE: 3. The other functions are dependent on 'require("bufferline.ui").tabline' and serve as auxiliary to the tabline function.
-- NOTE: 4. [240515] NEW FEATURE INTEGRATION: bufferline.nvim and tabline.nvim in setup config
local lazy = require("bufferline.lazy")
local utils = lazy.require("bufferline.utils") ---@module "bufferline.utils"
local config = lazy.require("bufferline.config") ---@module "bufferline.config"
local constants = lazy.require("bufferline.constants") ---@module "bufferline.constants"
local highlights = lazy.require("bufferline.highlights") ---@module "bufferline.highlights"
local api = vim.api

-- NOTE: [240515] NEW FEATURE INTEGRATION: bufferline.nvim and tabline.nvim in setup config
local M = require('lvim.core.bufferline')
M.setup = function()
  require("lvim.keymappings").load(lvim.builtin.bufferline.keymap)

  local status_ok, bufferline = pcall(require, "bufferline")
  if not status_ok then
    return
  end

  -- can't be set in settings.lua because default tabline would flash before bufferline is loaded
  vim.opt.showtabline = 2

  bufferline.setup {
    options = lvim.builtin.bufferline.options,
    highlights = lvim.builtin.bufferline.highlights,
  }

  if lvim.builtin.bufferline.on_config_done then
    lvim.builtin.bufferline.on_config_done()
  end
  require("tabline").on_session_load_post()
  vim.o.tabline = "%!v:lua.nvim_bufferline() .. v:lua.require'tabline'.tabline_tabs()"
end

-- NOTE: before [240515] note 1~3 features

-- string.len counts number of bytes and so the unicode icons are counted
-- larger than their display width. So we use nvim's strwidth
local strwidth = vim.api.nvim_strwidth
local padding = constants.padding
local custom_area = lazy.require("bufferline.custom_area") ---@module "bufferline.custom_area"
local offset = lazy.require("bufferline.offset") ---@module "bufferline.offset"
local function get_id(component) return component and component.attr and component.attr.__id end
local function get_tab_close_button(options, hls)
  if options.show_close_icon and (#vim.api.nvim_list_tabpages() > 1) then
    return {
      {
        text = padding .. options.close_icon .. padding,
        highlight = hls.tab_close.hl_group,
        attr = { prefix = "%999X" },
      },
    }
  end
  return {}
end
local function has_text(s)
  if s == nil or s.text == nil or s.text == "" then return false end
  return true
end

local function get_component_size(segments)
  assert(utils.is_list(segments), "Segments must be a list")
  local sum = 0
  for _, s in pairs(segments) do
    if has_text(s) then sum = sum + strwidth(tostring(s.text)) end
  end
  return sum
end
local function get_marker_size(count, element_size) return count > 0 and strwidth(tostring(count)) + element_size or 0 end
local function get_sections(items)
  local Section = require("bufferline.models").Section
  local current = Section:new()
  local before = Section:new()
  local after = Section:new()

  for _, tab_view in ipairs(items) do
    if not tab_view.hidden then
      if tab_view:current() then
        current:add(tab_view)
      elseif current.length == 0 then -- We haven't reached the current buffer yet
        before:add(tab_view)
      else
        after:add(tab_view)
      end
    end
  end
  return before, current, after
end
local function truncate(before, current, after, available_width, marker, visible)
  visible = visible or {}

  local left_trunc_marker = get_marker_size(marker.left_count, marker.left_element_size)
  local right_trunc_marker = get_marker_size(marker.right_count, marker.right_element_size)

  local markers_length = left_trunc_marker + right_trunc_marker
  local total_length = before.length + current.length + after.length + markers_length

  if available_width >= total_length then
    local items = {}
    visible = utils.merge_lists(before.items, current.items, after.items)
    for index, item in ipairs(visible) do
      table.insert(items, item.component(visible[index + 1]))
    end
    return items, marker, visible
    -- if we aren't even able to fit the current buffer into the
    -- available space that means the window is really narrow
    -- so don't show anything
  elseif available_width < current.length then
    return {}, marker, visible
  else
    if before.length >= after.length then
      before:drop(1)
      marker.left_count = marker.left_count + 1
    else
      after:drop(#after.items)
      marker.right_count = marker.right_count + 1
    end
    -- drop the markers if the window is too narrow
    -- this assumes we have dropped both before and after
    -- sections since if the space available is this small
    -- we have likely removed these
    if (current.length + markers_length) > available_width then
      marker.left_count = 0
      marker.right_count = 0
    end
    return truncate(before, current, after, available_width, marker, visible)
  end
end

local function get_trunc_marker(trunc_icon, count_hl, icon_hl, count)
  if count > 0 then
    return {
      { highlight = count_hl, text = padding .. count .. padding },
      { highlight = icon_hl,  text = trunc_icon .. padding },
    }
  end
end
local function extend_highlight(component)
  local locations, extension_map = {}, {}
  for index, part in pairs(component) do
    local id = get_id(part)
    if id then locations[id] = index end
    local extends = vim.tbl_get(part, "attr", "extends")
    if extends then
      for _, target in pairs(extends) do
        extension_map[target.id] = target.highlight or part.highlight
      end
    end
  end
  for id, hl in pairs(extension_map) do
    local target = component[locations[id]]
    if target then target.highlight = hl end
  end
  return component
end

local function to_tabline_str(component)
  component = component or {}
  local str = {}
  local globals = {}
  extend_highlight(component)
  for _, part in ipairs(component) do
    local attr = part.attr
    if attr and attr.global then table.insert(globals, { attr.prefix or "", attr.suffix or "" }) end
    local hl = highlights.hl(part.highlight)
    table.insert(str, {
      hl,
      ((attr and not attr.global) and attr.prefix or ""),
      (part.text or ""),
      ((attr and not attr.global) and attr.suffix or ""),
    })
  end
  for _, attr in ipairs(globals) do
    table.insert(str, 1, attr[1])
    table.insert(str, #str + 1, attr[1])
  end
  return table.concat(vim.tbl_flatten(str))
end

local function join(list)
  local str = ""
  for _, item in pairs(list) do
    str = str .. to_tabline_str(item)
  end
  return str
end
local function statusline_str_width(...)
  local str = table.concat({ ... }, "")
  return api.nvim_eval_statusline(str, { use_tabline = true }).width
end


---@diagnostic disable-next-line: unused-local
require("bufferline.ui").tabline = function(items, tab_indicators)
  local options = config.options
  local hl = config.highlights
  local right_align = { { highlight = hl.fill.hl_group, text = "%=" } }

  local tab_close_button = get_tab_close_button(options, hl)
  local tab_close_button_length = get_component_size(tab_close_button)

  -- NOTE: use tabline.total_tab_length instead to get_tab_indicator
  local tab_indicator_segments, tab_indicator_length = {}, require("tabline").total_tab_length

  -- NOTE: this estimates the size of the truncation marker as we don't know how big it will be yet
  local left_trunc_icon = options.left_trunc_marker
  local right_trunc_icon = options.right_trunc_marker
  local max_padding = string.rep(padding, 2)
  local left_element_size = utils.measure(max_padding, left_trunc_icon, max_padding)
  local right_element_size = utils.measure(max_padding, right_trunc_icon, max_padding)

  local offsets = offset.get()
  local custom_area_size, left_area, right_area = custom_area.get()

  local available_width = vim.o.columns
      - custom_area_size
      - offsets.total_size
      - tab_indicator_length
      - tab_close_button_length

  local before, current, after = get_sections(items)
  local segments, marker, visible_components = truncate(before, current, after, available_width, {
    left_count = 0,
    right_count = 0,
    left_element_size = left_element_size,
    right_element_size = right_element_size,
  })

  local fill = hl.fill.hl_group
  local left_marker = get_trunc_marker(left_trunc_icon, fill, fill, marker.left_count)
  local right_marker = get_trunc_marker(right_trunc_icon, fill, fill, marker.right_count)

  local core = join(
    utils.merge_lists(
      { left_marker },
      segments,
      { right_marker, right_align },
      tab_indicator_segments,
      { tab_close_button }
    )
  )

  --- NOTE: the custom areas are essentially mini tablines a user can define so they can't
  --- be safely converted to segments so they are concatenated to string and joined with
  --- the rest of the tabline
  local tabline = utils.join(offsets.left, left_area, core, right_area, offsets.right)

  local left_offset_size = offsets.left_size + statusline_str_width(left_area)
  local left_marker_size = left_marker and get_component_size(left_marker) or 0
  local right_offset_size = offsets.right_size + statusline_str_width(right_area)
  local right_marker_size = right_marker and get_component_size(right_marker) or 0

  return {
    str = tabline,
    segments = segments,
    visible_components = visible_components,
    right_offset_size = right_offset_size + right_marker_size,
    left_offset_size = left_offset_size + left_marker_size,
  }
end
return M
