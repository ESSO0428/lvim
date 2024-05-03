vim.list_extend(lvim.lsp.automatic_configuration.skipped_servers, { "pyright" })

local pyright_opts = {
  single_file_support = true,
  root_dir = function(fname)
    local cwd = vim.fn.getcwd()
    fname = fname or vim.api.nvim_buf_get_name(0)
    local file_dir = vim.fn.fnamemodify(fname, ':h')
    if vim.startswith(fname, cwd) then
      return cwd
    else
      return file_dir -- Sets the workspace directory to the file's directory if CWD does not match
    end
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
