local function load_template(template_name)
  local template = "user.config.plugins.dadbod.dotenv_template"
  template = table.concat({ template, template_name }, '.')
  return function()
    require(template).insert_dotenv_template()
  end
end


vim.api.nvim_create_user_command('DotenvTemplateSQL', load_template('sql'), {})
