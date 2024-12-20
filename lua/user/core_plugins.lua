local custom_snapshot_path = vim.fn.stdpath("config") .. "/snapshots/default.json"
local custom_sha1 = {}

local content = vim.fn.readfile(custom_snapshot_path)
if content and #content > 0 then
  custom_sha1 = assert(vim.fn.json_decode(content))
end

local function get_short_name(long_name)
  if long_name:sub(-4) == ".git" then
    return long_name:sub(1, -5)
  end
  local slash = long_name:reverse():find("/", 1, true)
  return slash and long_name:sub(#long_name - slash + 2) or long_name:gsub("%W+", "_")
end

for _, spec in ipairs(require("lvim.plugins")) do
  local short_name = get_short_name(spec[1])
  if custom_sha1[short_name] and custom_sha1[short_name].commit then
    spec.commit = custom_sha1[short_name].commit
  end
end
