vim.list_extend(lvim.lsp.automatic_configuration.skipped_servers, { "pyright", "ruff" })
local function stop_pyright()
  local clients = vim.lsp.get_active_clients()
  for _, client in ipairs(clients) do
    if client.name == "pyright" then
      vim.lsp.stop_client(client)
      print("Pyright has been stopped.")
      return
    end
  end
  print("Pyright is not running.")
end
local function start_pyright()
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
        disableOrganizeImports = true
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
          diagnosticMode = "workspace", -- openFilesOnly, workspace
          typeCheckingMode = "basic",   -- off, basic, strict
          useLibraryCodeForTypes = true,
          ignore = { '*' },
        }
      }
    },
  }
  pcall(function()
    require("lvim.lsp.manager").setup("basedpyright", pyright_opts)
    require("lvim.lsp.manager").setup("ruff_lsp", {
      init_options = {
        settings = {
          -- Any extra CLI arguments for `ruff` go here.
          args = {},
        }
      }
    })
    -- nvim-lspconfig : 6e5c78e above
    -- require("lvim.lsp.manager").setup("basedpyright", pyright_opts)
  end)
end
start_pyright()
vim.api.nvim_create_user_command('PyrightStop', stop_pyright, {})
vim.api.nvim_create_user_command('PyrightStart', start_pyright, {})

if vim.b.CURRENT_REPL == nil then
  vim.b.CURRENT_REPL = "REPL:default"
  vim.keymap.set('n', '[w', ':norm strah<cr>', { buffer = true, silent = true })
  vim.keymap.set('n', ']w', ':norm strih<cr>', { buffer = true, silent = true })
end
