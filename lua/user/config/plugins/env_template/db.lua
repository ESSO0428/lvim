local M = {}
function M.insert_dotenv_template()
  local template = [[
DB_CONNECTION=
DB_PORT=
DB_DATABASE=
DB_USERNAME=

# For security reasons, it is recommended to use `mysql_config_editor` to set up passwordless login.
# Alternatively, you can set `DB_PASSWORD` for `DB_UI_DEV`, but this is not recommended.
# Example for setting up passwordless login:
# `mysql_config_editor set --user=root --host=127.0.0.1 --port=3306 --password`

# `DB_UI_*` : The suffix after `DB_UI_` becomes the name of the connection (lowercased).
# You can specify any number of connections using the `DB_UI_` prefix.
# For example, `DB_UI_DEV_PORT` or `DB_UI_PRODUCTION` will be converted to `dev_port` or `production` connections.
# Omitting `DB_DATABASE` will include the entire DBMS as the connection target.

# NOTE: If the same variable name appears multiple times in the configuration file, the first occurrence of the variable will take precedence.
# Therefore, any new values must be defined in new variables for use in DB_UI... =
# ex : DB2_CONNECTION, DB2_PORT, DB2_DATABASE, DB2_USERNAME, DB2_PASSWORD
DB_UI_DEV="${DB_CONNECTION}://${DB_USERNAME}@127.0.0.1:${DB_PORT}/${DB_DATABASE}"
]]
  -- 插入模板到当前 buffer
  vim.api.nvim_put(vim.split(template, '\n'), '', false, true)
end

return M
