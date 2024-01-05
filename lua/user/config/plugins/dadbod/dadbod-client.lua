-- neovim db client
-- don't use password for security reason (use mysql_config_editor)
-- example : mysql_config_editor set --user=root --host=127.0.0.1 --port=3306 --password
vim.g.db_ui_use_nerd_fonts = 1
vim.g.dbs = {
  -- { name = 'orchid_db_v3', url = 'mysql://root@127.0.0.1:3306/orchid_db_v3' },
  { name = 'all_mysql_db_3306', url = 'mysql://root@127.0.0.1:3306' }
}
vim.g.db_ui_table_helpers = {
  mysql = {
    List = "select * from {dbname}.`{table}` LIMIT 200",
    ['Primary Keys'] =
    "SELECT * FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS WHERE TABLE_SCHEMA = '{dbname}' AND TABLE_NAME = '{table}' AND CONSTRAINT_TYPE = 'PRIMARY KEY'",
    ['Foreign Keys'] =
    "SELECT * FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS WHERE TABLE_SCHEMA = '{dbname}' AND TABLE_NAME = '{table}' AND CONSTRAINT_TYPE = 'FOREIGN KEY'",
    Count = "select count(*) from {dbname}.`{table}`",
    Explain = "EXPLAIN {last_query}"
  }
}
