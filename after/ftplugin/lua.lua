require("lvim.lsp.manager").setup("lua_ls", {
  capabilities = Nvim.builtin.lsp.capabilities,
  settings = {
    Lua = {
      hint = {
        enable = true
      }
    }
  }
})
