local function load_template(template_name)
  local template = "user.config.plugins.env_template"
  template = table.concat({ template, template_name }, '.')
  return function()
    require(template).insert_dotenv_template()
  end
end

-- setting commands and aliases (or only one command)
Nvim.nvim_create_user_commands({ 'ENVTemplateDB', 'DBENVTemplate' }, load_template('db'))
