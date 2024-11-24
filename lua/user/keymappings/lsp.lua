-- lvim.lsp.
lvim.lsp.buffer_mappings.normal_mode['K']  = nil
lvim.lsp.buffer_mappings.normal_mode['gs'] = nil
-- lvim.keys.normal_mode['gh']                = "<cmd>lua vim.lsp.buf.hover()<cr>"
function lsp_or_jupyter_hover()
  local is_jupyter_attached = vim.b.jupyter_attached or false

  if is_jupyter_attached then
    vim.cmd('JupyterInspect')
  else
    vim.lsp.buf.hover()
  end
end

local function LspbufRename()
  vim.g.dress_input = true
  vim.lsp.buf.rename()
end
vim.api.nvim_create_user_command('LspbufRename', LspbufRename, {})

lvim.keys.normal_mode['gh']                = "<cmd>lua lsp_or_jupyter_hover()<cr>"
lvim.lsp.buffer_mappings.normal_mode['gh'] = { "<cmd>lua lsp_or_jupyter_hover()<cr>", "Show documentation" }
lvim.keys.normal_mode['sgh']               = "<cmd>lua require('hoversplit').split_remain_focused()<cr>"
lvim.keys.normal_mode['g;']                = "<cmd>lua vim.lsp.buf.type_definition()<cr>"

function filetype_specfic_antovim()
  local captures = vim.treesitter.get_captures_at_cursor(0)
  local is_antovim = false
  for _, capture in ipairs(captures) do
    if capture == "spell" then
      is_antovim = true
      break
    end
  end
  return is_antovim
end

function execute_check_action_toggle_on_filetype()
  local filetype = vim.bo.filetype
  if filetype == 'org' then
    local is_antovim = filetype_specfic_antovim()
    if not is_antovim then
      -- pcall(function() require("orgmode").action("org_mappings.toggle_checkbox") end)
      vim.cmd('normal gS')
    else
      vim.cmd('Antovim')
    end
  elseif filetype == 'markdown' then
    local is_antovim = filetype_specfic_antovim()
    if not is_antovim then
      -- pcall(vim.cmd, 'MkdnToggleToDo')
      vim.cmd('normal gS')
    else
      vim.cmd('Antovim')
    end
  else
    vim.cmd('Antovim')
  end
end

vim.api.nvim_create_autocmd("BufEnter", {
  pattern = "*",
  callback = function()
    vim.keymap.set('n', 'gs', execute_check_action_toggle_on_filetype, { noremap = true, silent = true })
  end
})

-- lvim.keys.normal_mode['gs']                = "<cmd>Antovim<cr>"
lvim.keys.normal_mode['ga']            = "<cmd>TSJToggle<cr>"
-- lvim.keys.normal_mode['gm']                = "<cmd>lua vim.lsp.buf.signature_help()<cr>"
lvim.keys.normal_mode['gm']            = "<cmd>lua require('lsp_signature').toggle_float_win()<cr>"

-- replace to Lspsaga code action
-- lvim.keys.normal_mode['<leader>ua']           = { "<cmd>lua vim.lsp.buf.code_action()<cr>" }
lvim.keys.normal_mode['<leader>ud']    = { "<cmd>Telescope diagnostics bufnr=0 theme=get_ivy<cr>" }
lvim.keys.normal_mode['<leader>uw']    = { "<cmd>Telescope diagnostics<cr>" }
-- lvim.keys.normal_mode['<leader>uf'] = { require("lvim.lsp.utils").format() }
lvim.keys.normal_mode['<leader>=']     = "<cmd>lua vim.lsp.buf.format()<cr>"
-- lvim.keys.normal_mode['<leader>rn'] = "<cmd>lua vim.lsp.buf.rename()<cr>"
lvim.keys.normal_mode['<leader>rn']    = "<cmd>LspbufRename<cr>"
lvim.keys.normal_mode['<leader>ui']    = { "<cmd>LspInfo<cr>" }
lvim.keys.normal_mode['<leader>uI']    = { "<cmd>Mason<cr>" }
-- lvim.keys.normal_mode['<leader>uo']        = { "<cmd>lua vim.diagnostic.goto_next()<cr>" }
-- lvim.keys.normal_mode['<leader>uu']        = { "<cmd>lua vim.diagnostic.goto_prev()<cr>" }
lvim.keys.normal_mode['>']             = { "<cmd>lua vim.diagnostic.goto_next()<cr>" }
lvim.keys.normal_mode['<']             = { "<cmd>lua vim.diagnostic.goto_prev()<cr>" }

lvim.keys.normal_mode['<leader>ul']    = { "<cmd>lua vim.lsp.codelens.run()<cr>" }
lvim.keys.normal_mode['<leader>uq']    = { "<cmd>lua vim.diagnostic.setloclist()<cr>" }

lvim.keys.normal_mode['<leader>us']    = { "<cmd>Telescope lsp_document_symbols<cr>" }
lvim.keys.normal_mode['<leader>uS']    = { "<cmd>Telescope lsp_dynamic_workspace_symbols<cr>" }
lvim.keys.normal_mode['<leader>ue']    = { "<cmd>Telescope quickfix<cr>" }

-- lvim.keys.normal_mode['<a-u>']             = "<cmd>LspInfo<cr>"
-- now replace to <leader>ui

-- lvim.builtin.which_key.mappings['c']   = { "<cmd>Telescope lsp_references<cr>", "lsp_references" }
lvim.builtin.which_key.mappings['gr']  = { "<cmd>Telescope lsp_references<cr>", "lsp_references" }
lvim.builtin.which_key.mappings['v']   = { "<cmd>Telescope lsp_document_symbols<cr>", "lsp_document_symbols" }

-- lvim.lsp.buffer_mappings.normal_mode['gd'] = nil
lvim.keys.normal_mode['<a-o>']         = "<cmd>lua vim.lsp.buf.definition()<cr>"
-- lvim.keys.normal_mode['<a-o>']             = "<cmd>Lspsaga goto_definition<cr>"
-- lvim.keys.normal_mode['<a-o>']         = "<cmd>lua require('telescope.builtin').lsp_definitions()<cr>"
lvim.keys.normal_mode['<leader><a-o>'] = "<cmd>lua require('goto-preview').goto_preview_definition()<cr>"
lvim.keys.normal_mode['sL']            = "<cmd>wincmd L<cr>"
lvim.keys.normal_mode['sK']            = "<cmd>wincmd J<cr>"
lvim.keys.normal_mode['<leader>I']     = "<cmd>wincmd W<cr>"
lvim.keys.normal_mode['<leader>K']     = "<cmd>wincmd w<cr>"
lvim.keys.normal_mode['<leader>uq']    = "<cmd>lua vim.lsp.diagnostic.setloclist()<cr>"

-- lvim.lsp.buffer_mappings.normal_mode['<a-d>'] = { vim.lsp.buf.hover, "Show documentation" }
-- lvim.lsp.buffer_mappings.normal_mode['<a-s>'] = { vim.lsp.buf.hover, "Show documentation" }
-- lvim.lsp.buffer_mappings.normal_mode['gh'] = { vim.lsp.buf.hover, "Show documentation" }
-- lvim.keys.normal_mode['<c-t>'] = "<cmd>SymbolsOutline<cr>"
-- lvim.keys.normal_mode['<c-t>'] = "<cmd>Lspsaga outline<cr>"
lvim.keys.normal_mode['<c-t>']         = "<cmd>Outline!<cr>"
lvim.keys.normal_mode['<leader><c-t>'] = "<cmd>OutlineFocusOutline<cr>"
