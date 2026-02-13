require("luasnip.loaders.from_vscode").lazy_load({
  paths = {
    vim.fn.stdpath("config") .. "/snippets/bootstrap5/anbuselvanrocky.bootstrap5-vscode-0.4.2"
  }
})
require("luasnip.loaders.from_vscode").lazy_load({
  paths = {
    vim.fn.stdpath("config") .. "/snippets/django/bigonesystems.django-1.0.2"
  }
})
