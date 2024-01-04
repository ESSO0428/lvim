-- Then, set an auto command for Markdown files
vim.api.nvim_create_autocmd("FileType", {
  pattern = "markdown",
  callback = function()
    -- local otter = require 'otter'
    -- table of embedded languages to look for
    local languages = { 'python', 'lua' }

    -- enable completion/diagnostics
    local completion = true
    local diagnostics = true
    -- treesitter query to look for embedded languages
    local tsquery = nil

    -- Activate Otter with the specified configuration
    require 'otter'.activate(languages, completion, diagnostics, tsquery)
  end,
})
