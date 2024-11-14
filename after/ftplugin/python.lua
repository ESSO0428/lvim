vim.list_extend(lvim.lsp.automatic_configuration.skipped_servers, { "pyright", "ruff_lsp" })
local opts = {
  single_file_support = true,
  filetypes = { "python" },
  root_dir = function(...)
    -- local cwd = vim.fn.getcwd()
    -- fname = fname or vim.api.nvim_buf_get_name(0)
    -- local file_dir = vim.fn.fnamemodify(fname, ':h')
    -- local workspace
    -- if vim.startswith(fname, cwd) then
    --   workspace = cwd
    -- else
    --   workspace = file_dir -- Sets the workspace directory to the file's directory if CWD does not match
    -- end
    local util = require "lspconfig.util"
    return util.find_git_ancestor(...)
        or util.root_pattern(unpack {
          "pyproject.toml",
          "setup.py",
          "setup.cfg",
          "requirements.txt",
          "Pipfile",
          "pyrightconfig.json",
          "README.md",
          -- workspace
        })(...)
  end,
  capabilities = Nvim.builtin.lsp.capabilities,
  settings = {
    basedpyright = {
      analysis = {
        autoSearchPaths = true,
        autoImportCompletions = true,
        diagnosticMode = "openFilesOnly",
        useLibraryCodeForTypes = true,
        reportMissingTypeStubs = false,
        typeCheckingMode = "basic",
        enableTypeIgnoreComments = true,
      },
    },
  },
}
require("lvim.lsp.manager").setup("basedpyright", opts)
require("lvim.lsp.manager").setup("ruff", {
  on_attach = function(client, buffer)
    client.server_capabilities.documentFormattingProvider = false
    client.server_capabilities.hoverProvider = false
    client.server_capabilities.renameProvider = false
  end,
  init_options = {
    settings = {
      -- Any extra CLI arguments for `ruff` go here.
      args = {},
    }
  }
})

if vim.b.CURRENT_REPL == nil then
  vim.b.CURRENT_REPL = "REPL:default"
  vim.keymap.set('n', '[w', ':norm strah<cr>', { buffer = true, silent = true })
  vim.keymap.set('n', ']w', ':norm strih<cr>', { buffer = true, silent = true })
end
