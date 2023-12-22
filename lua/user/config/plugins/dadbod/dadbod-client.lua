-- neovim db client
-- don't use password for security reason (use mysql_config_editor)
-- example : mysql_config_editor set --user=root --host=127.0.0.1 --port=3306 --password
vim.g.db_ui_use_nerd_fonts = 1
vim.g.dbs = {
  -- { name = 'orchid_db_v3', url = 'mysql://root@127.0.0.1:3306/orchid_db_v3' },
  { name = 'all_mysql_db_3306', url = 'mysql://root@127.0.0.1:3306' }
}
