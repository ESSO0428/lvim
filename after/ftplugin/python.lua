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
    local root = util.find_git_ancestor(...)
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
    local excluded_paths = {
      vim.loop.os_homedir(),
      "/",
      "/tmp",
    }
    local function is_excluded(dir, excluded_paths)
      for _, excluded in ipairs(excluded_paths) do
        if dir == excluded then
          return true
        end
      end
      return false
    end
    if root and not is_excluded(vim.fn.getcwd(), excluded_paths) then
      return root
    end
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
  -- NOTE: str is iron.nvim command to send current line to repl
  -- And then in visual mode is send selected lines
  vim.keymap.set('n', '[r', ':norm stR<cr>', { buffer = true, silent = true })
  vim.keymap.set('n', ']r', ':norm stR<cr>', { buffer = true, silent = true })
  -- NOTE: stf is iron.nvim command to send current file to repl
  vim.keymap.set('n', '[R', ':norm stf<cr>', { buffer = true, silent = true })
  vim.keymap.set('n', ']R', ':norm stf<cr>', { buffer = true, silent = true })
  vim.keymap.set('v', '[w', 'str', { buffer = true, remap = true, silent = true })
  vim.keymap.set('v', ']w', 'str', { buffer = true, remap = true, silent = true })
  vim.keymap.set('v', '[r', 'str', { buffer = true, remap = true, silent = true })
  vim.keymap.set('v', ']r', 'str', { buffer = true, remap = true, silent = true })
end
