require("luasnip.loaders.from_vscode").load({
  paths = {
    vim.fn.stdpath("config") .. "/snippets/python/mysnippets",
    vim.fn.stdpath("config") .. "/snippets/python/ericsia.pythonsnippets3-3.3.18",
    vim.fn.stdpath("config") .. "/snippets/python/cstrap.python-snippets-0.1.2"
  }
})
