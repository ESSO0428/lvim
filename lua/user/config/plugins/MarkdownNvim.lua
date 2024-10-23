local has_devicons, devicons = pcall(require, 'nvim-web-devicons')
require("render-markdown.lib.icons").get = function(language)
  if has_devicons then
    return devicons.get_icon_by_filetype(language)
  else
    return nil, nil
  end
end
