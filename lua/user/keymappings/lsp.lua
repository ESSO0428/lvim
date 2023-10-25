-- lvim.lsp.
lvim.lsp.buffer_mappings.normal_mode['K']  = nil
lvim.lsp.buffer_mappings.normal_mode['gs'] = nil
-- lvim.keys.normal_mode['gh']                = ":lua vim.lsp.buf.signature_help()<cr>"
function lsp_or_jupyter_signature_help()
  local is_jupyter_attached = vim.b.jupyter_attached or false

  if is_jupyter_attached then
    vim.cmd('JupyterInspect')
  else
    vim.cmd('lua vim.lsp.buf.hover()')
  end
end

lvim.lsp.buffer_mappings.normal_mode['gh'] = { ":lua lsp_or_jupyter_signature_help()<cr>", "Show documentation" }

lvim.keys.normal_mode['gs']                = ":Antovim<cr>"

-- replace to Lspsaga code action
-- lvim.keys.normal_mode['<leader>ua']           = { "<cmd>lua vim.lsp.buf.code_action()<cr>" }
lvim.keys.normal_mode['<leader>ud']        = { ":Telescope diagnostics bufnr=0 theme=get_ivy<cr>" }
lvim.keys.normal_mode['<leader>uw']        = { ":Telescope diagnostics<cr>" }
-- lvim.keys.normal_mode['<leader>uf'] = { require("lvim.lsp.utils").format() }
lvim.keys.normal_mode['<leader>=']         = ":lua vim.lsp.buf.format()<CR>"
-- lvim.keys.normal_mode['<leader>rn'] = ":lua vim.lsp.buf.rename()<CR>"
lvim.keys.normal_mode['<leader>rn']        = ":lua require'lspactions'.rename()<CR>"
lvim.keys.normal_mode['<leader>ui']        = { ":LspInfo<cr>" }
lvim.keys.normal_mode['<leader>uI']        = { ":Mason<cr>" }
lvim.keys.normal_mode['<leader>uo']        = { ":lua vim.diagnostic.goto_next()<cr>" }
lvim.keys.normal_mode['<leader>uu']        = { ":lua vim.diagnostic.goto_prev()<cr>" }
lvim.keys.normal_mode['<leader>ul']        = { ":lua vim.lsp.codelens.run()<cr>" }
lvim.keys.normal_mode['<leader>uq']        = { ":lua vim.diagnostic.setloclist()<cr>" }

lvim.keys.normal_mode['<leader>us']        = { ":Telescope lsp_document_symbols<cr>" }
lvim.keys.normal_mode['<leader>uS']        = { ":Telescope lsp_dynamic_workspace_symbols<cr>" }
lvim.keys.normal_mode['<leader>ue']        = { ":Telescope quickfix<cr>" }

lvim.keys.normal_mode['<a-u>']             = ":LspInfo<CR>"

lvim.builtin.which_key.mappings['c']       = { ":Telescope lsp_references<CR>", "lsp_references" }
lvim.builtin.which_key.mappings['v']       = { ":Telescope lsp_document_symbols<CR>", "lsp_document_symbols" }

lvim.lsp.buffer_mappings.normal_mode['gd'] = nil
-- lvim.keys.normal_mode['<a-o>']             = ":lua vim.lsp.buf.definition()<CR>"
lvim.keys.normal_mode['<a-o>']             = "<cmd>Lspsaga goto_definition<CR>"
lvim.keys.normal_mode['<leader><a-o>']     = ":lua require('goto-preview').goto_preview_definition()<CR>"
lvim.keys.normal_mode['sL']                = ":wincmd L<CR>"
lvim.keys.normal_mode['sK']                = ":wincmd J<CR>"
lvim.keys.normal_mode['<leader>I']         = ":wincmd W<CR>"
lvim.keys.normal_mode['<leader>K']         = ":wincmd w<CR>"
lvim.keys.normal_mode['<leader>uq']        = ":lua vim.lsp.diagnostic.setloclist()<CR>"

-- lvim.lsp.buffer_mappings.normal_mode['<a-d>'] = { vim.lsp.buf.hover, "Show documentation" }
-- lvim.lsp.buffer_mappings.normal_mode['<a-s>'] = { vim.lsp.buf.hover, "Show documentation" }
-- lvim.lsp.buffer_mappings.normal_mode['gh'] = { vim.lsp.buf.hover, "Show documentation" }
-- lvim.keys.normal_mode['<c-t>'] = ":SymbolsOutline<cr>"
