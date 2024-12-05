vim.list_extend(lvim.lsp.automatic_configuration.skipped_servers, { "intelephense" })
local opts = {
  single_file_support = true,
  filetypes = { "php" },
  root_dir = function(...)
    local util = require "lspconfig.util"
    return util.find_git_ancestor(...)
        or util.root_pattern(unpack({
          "composer.json",
          ".git",
          "index.php",
          "requirements.txt",
        }))(...)
  end,
  capabilities = Nvim.builtin.lsp.capabilities,
}
require("lvim.lsp.manager").setup("tailwindcss")
require("lvim.lsp.manager").setup("intelephense", opts)
