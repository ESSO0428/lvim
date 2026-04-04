require("lvim.lsp.manager").setup("lua_ls", {
  capabilities = Nvim.builtin.lsp.get_capabilities(),
  settings = {
    Lua = {
      hint = {
        enable = true
      }
    }
  }
})
