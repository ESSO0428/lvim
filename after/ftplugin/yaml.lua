require("lvim.lsp.manager").setup("yamlls", {
  capabilities = Nvim.builtin.lsp.capabilities,
  settings = {
    yaml = {
      hover = true,
      completion = true,
      validate = true,
      schemaStore = {
        enable = true,
        url = "https://www.schemastore.org/api/json/catalog.json",
      },
      schemas = require("schemastore").yaml.schemas(),
    },
  }
})
