vim.list_extend(lvim.lsp.automatic_configuration.skipped_servers, { "pyright" })

local pyright_opts = {
  single_file_support = true,
  root_dir = function()
    return vim.fn.getcwd()
  end,
  settings = {
    pyright = {
      disableLanguageServices = false,
      disableOrganizeImports = false
    },
    basedpyright = {
      typeCheckingMode = "standard",
      analysis = {
        autoImportCompletions = true,
        autoSearchPaths = true,
        diagnosticMode = "workspace", -- openFilesOnly, workspace
        useLibraryCodeForTypes = true
      }
    },
    python = {
      analysis = {
        autoImportCompletions = true,
        autoSearchPaths = true,
        diagnosticMode = "workspace",  -- openFilesOnly, workspace
        typeCheckingMode = "standard", -- off, basic, strict
        useLibraryCodeForTypes = true
      }
    }
  },
}
pcall(function()
  require("lvim.lsp.manager").setup("pyright", pyright_opts)

  -- nvim-lspconfig : 6e5c78e above
  -- require("lvim.lsp.manager").setup("basedpyright", pyright_opts)
end)
