local navbuddy = require("nvim-navbuddy")

lvim.lsp.on_attach_callback = function(client, bufnr)
  if client.server_capabilities.documentSymbolProvider then
    navbuddy.attach(client, bufnr)
  end
end

-- 底下 Maso.. require("lvim.lsp... 為啟用 html emmet-ls 補全功能
-- :MasonInstall emmet-ls
-- lvim.lsp.installer.setup.ensure_installed = { "html", "tailwindcss" }
lvim.lsp.installer.setup.ensure_installed = { "html", "tailwindcss", "tsserver", "basedpyright", "ruff_lsp" }
local opts = { filetypes = { "html", "htmldjango" } }
require("lvim.lsp.manager").setup("html", opts)

local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities = vim.tbl_deep_extend(
  "force",
  vim.lsp.protocol.make_client_capabilities(),
  -- returns configured operations if setup() was already called
  -- or default operations if not
  require 'lsp-file-operations'.default_capabilities()
)
capabilities.textDocument.foldingRange = {
  dynamicRegistration = false,
  lineFoldingOnly = true,
}
capabilities.workspace.didChangeWatchedFiles.dynamicRegistration = true
Nvim.builtin.lsp = {}
Nvim.builtin.lsp.capabilities = capabilities
--   require("lvim.lsp.manager").setup("yamlls", {
--     capabilities = Nvim.builtin.lsp.capabilities,
--     settings = {
--       yaml = {
--         hover = true,
--         completion = true,
--         validate = true,
--         schemaStore = {
--           enable = true,
--           url = "https://www.schemastore.org/api/json/catalog.json",
--         },
--         schemas = require("schemastore").yaml.schemas(),
--       },
--     }
--   })
-- -- NOTE: comment tailwindcss lsp config because it's lunarvim default config
-- -- require("lvim.lsp.manager").setup("tailwindcss", { ... })
require("lvim.lsp.manager").setup("cssls", {
  capabilities = Nvim.builtin.lsp.capabilities,
  settings = {
    css = {
      validate = true,
      lint = {
        unknownAtRules = "ignore"
      }
    },
    scss = {
      validate = true,
      lint = {
        unknownAtRules = "ignore"
      }
    },
    less = {
      validate = true,
      lint = {
        unknownAtRules = "ignore"
      }
    }
  }
})
require("lvim.lsp.manager").setup("tsserver", {
  capabilities = Nvim.builtin.lsp.capabilities,
  settings = {
    typescript = {
      inlayHints = {
        includeInlayParameterNameHints = "all",
        includeInlayParameterNameHintsWhenArgumentMatchesName = true,
        includeInlayFunctionParameterTypeHints = true,
        includeInlayVariableTypeHints = true,
        includeInlayVariableTypeHintsWhenTypeMatchesName = true,
        includeInlayPropertyDeclarationTypeHints = true,
        includeInlayFunctionLikeReturnTypeHints = true,
        includeInlayEnumMemberValueHints = true,
      },
    },
    javascript = {
      inlayHints = {
        includeInlayParameterNameHints = "all",
        includeInlayParameterNameHintsWhenArgumentMatchesName = true,
        includeInlayFunctionParameterTypeHints = true,
        includeInlayVariableTypeHints = true,
        includeInlayVariableTypeHintsWhenTypeMatchesName = true,
        includeInlayPropertyDeclarationTypeHints = true,
        includeInlayFunctionLikeReturnTypeHints = true,
        includeInlayEnumMemberValueHints = true,
      },
    },
  }
})
require("lvim.lsp.manager").setup("lua_ls", {
  capabilities = Nvim.builtin.lsp.capabilities,
  settings = {
    Lua = {
      hint = {
        enable = true
      }
    }
  }
})
local function initializeAndDeduplicatePythonPaths()
  local custom_python_paths = {
    vim.fn.getcwd(), -- 添加当前工作目录
    -- current_directory -- 将当前目录加入到路径列表中
    -- ... 添加其他路径
  }

  -- 去重复的方法
  local unique_paths = {}
  for _, path in ipairs(custom_python_paths) do
    unique_paths[path] = true
  end

  -- 将唯一的路径转回到列表中
  local deduplicated_paths = {}
  for path, _ in pairs(unique_paths) do
    table.insert(deduplicated_paths, path)
  end

  -- 将处理后的路径列表用于更新PYTHONPATH
  local current_pythonpath = vim.fn.getenv("PYTHONPATH") or ""
  for _, path in ipairs(deduplicated_paths) do
    if current_pythonpath == "" or current_pythonpath == vim.NIL then
      current_pythonpath = path
    else
      current_pythonpath = current_pythonpath .. ":" .. path
    end
  end

  vim.fn.setenv("PYTHONPATH", current_pythonpath)
end

-- 初始时设置PYTHONPATH
initializeAndDeduplicatePythonPaths()

local initial_pythonpath = vim.fn.getenv("PYTHONPATH") or ""

local function modify_pythonpath()
  local work_directory = vim.fn.getcwd()
  local file_directory = vim.fn.expand("%:p:h")
  local modified_pythonpath = initial_pythonpath
  if not string.find(":" .. modified_pythonpath .. ":", ":" .. work_directory .. ":") then
    modified_pythonpath = work_directory .. ":" .. modified_pythonpath
  end
  if not string.find(":" .. modified_pythonpath .. ":", ":" .. file_directory .. ":") then
    modified_pythonpath = file_directory .. ":" .. modified_pythonpath
  end
  vim.fn.setenv("PYTHONPATH", modified_pythonpath)
end

local function reset_pythonpath()
  vim.fn.setenv("PYTHONPATH", initial_pythonpath)
end

vim.api.nvim_create_autocmd("BufEnter", { pattern = "*.py", callback = modify_pythonpath })
vim.api.nvim_create_autocmd("BufLeave", { pattern = "*.py", callback = reset_pythonpath })
