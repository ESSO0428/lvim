local M = {}
function M.insert_dotenv_template()
  local template = [[
DB_CONNECTION=
DB_PORT=
DB_DATABASE=
DB_USERNAME=

# DB_UI_`DEV` : the `DEV` will becomes the name of the connection (lowercased)
DB_UI_DEV="${DB_CONNECTION}://${DB_USERNAME}@127.0.0.1:${DB_PORT}/${DB_DATABASE}"
]]
  -- 插入模板到当前 buffer
  vim.api.nvim_put(vim.split(template, '\n'), '', false, true)
end

return M
