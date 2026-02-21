local function remove_lunarvim_default_language_ftplugins_in_rtp(languages)
  for _, lang in ipairs(languages) do
    local file_name = lang .. ".lua"
    vim.opt.rtp:remove(join_paths(get_runtime_dir(), "site", "after", "ftplugin", file_name))
    vim.opt.rtp:remove(join_paths(get_runtime_dir(), "after", "ftplugin", file_name))
  end
end

-- NOTE: The code below is used to *prevent* LunarVim's default ftplugin configuration from being loaded.
-- [Use When]:
--   - You want to disable configurations like LSP settings in LunarVim's default ftplugin.
--   - This is because LunarVim's default LSP configurations are loaded first, making it impossible
--     to override them with user-defined ftplugin settings.
-- [Do Not Use When]:
--   - You are simply setting up a new LSP or adding entirely new configurations. In such cases,
--     there's no need to remove LunarVim's default ftplugin configurations.
local function maybe_remove_lunarvim_default_language_ftplugins()
  if type(join_paths) ~= "function" or type(get_runtime_dir) ~= "function" then
    return
  end
  remove_lunarvim_default_language_ftplugins_in_rtp({ "lua", "python", "php" })
end

vim.api.nvim_create_autocmd({ "BufReadPre", "BufNewFile" }, {
  once = true,
  callback = maybe_remove_lunarvim_default_language_ftplugins,
})

lvim.lsp.on_attach_callback = function(client, bufnr)
  if client.server_capabilities.documentSymbolProvider then
    local ok, navbuddy = pcall(require, "nvim-navbuddy")
    if ok then
      navbuddy.attach(client, bufnr)
    end
  end
end

-- HACK: Temporary fix for `_str_utfindex_enc` (reverted to `0.10.1 behavior`).
-- `Neovim 0.10.2` introduced stricter boundary checks, causing LSP completion
-- issues (e.g., `marksman`) with CJK characters. This override removes these
-- stricter checks. The issue remains unfixed in 0.10.4. When `Neovim 0.11` or
-- a patched version (e.g., `0.10.5`) is available, comment out this override
-- to test native behavior.
vim.api.nvim_create_autocmd("LspAttach", {
  once = true,
  callback = function()
    require("vim.lsp.util")._str_utfindex_enc = function(line, index, encoding)
      if not encoding then
        encoding = 'utf-16'
      end
      if encoding == 'utf-8' then
        if index then
          return index
        else
          return #line
        end
      elseif encoding == 'utf-16' then
        local _, col16 = vim.str_utfindex(line, index)
        return col16
      elseif encoding == 'utf-32' then
        local col32, _ = vim.str_utfindex(line, index)
        return col32
      else
        error('Invalid encoding: ' .. vim.inspect(encoding))
      end
    end
  end
})
-- 底下 Maso.. require("lvim.lsp... 為啟用 html emmet-ls 補全功能
-- :MasonInstall emmet-ls
-- lvim.lsp.installer.setup.ensure_installed = { "html", "tailwindcss" }
lvim.lsp.installer.setup.ensure_installed = { "html", "tailwindcss", "tsserver", "basedpyright", "ruff", "intelephense" }
lvim.lsp.installer.setup.automatic_installation.exclude = { "harper_ls" }
vim.api.nvim_create_autocmd("FileType", {
  pattern = { "html", "htmldjango" },
  once = true,
  callback = function()
    local opts = { filetypes = { "html", "htmldjango" } }
    require("lvim.lsp.manager").setup("html", opts)
  end
})


local capabilities = vim.lsp.protocol.make_client_capabilities()
local ok_lfo, lfo = pcall(require, "lsp-file-operations")
if ok_lfo and type(lfo.default_capabilities) == "function" then
  capabilities = vim.tbl_deep_extend(
    "force",
    capabilities,
    -- returns configured operations if setup() was already called
    -- or default operations if not
    lfo.default_capabilities()
  )
end
capabilities.textDocument.foldingRange = {
  dynamicRegistration = false,
  lineFoldingOnly = true,
}
capabilities.workspace.didChangeWatchedFiles.dynamicRegistration = true
Nvim.builtin.lsp = {}
Nvim.builtin.lsp.capabilities = capabilities
vim.api.nvim_create_autocmd("FileType", {
  pattern = "yaml",
  once = true,
  callback = function()
    local schemas = {}
    local ok_schemastore, schemastore = pcall(require, "schemastore")
    if ok_schemastore and schemastore.yaml and type(schemastore.yaml.schemas) == "function" then
      schemas = schemastore.yaml.schemas()
    end
    require("lvim.lsp.manager").setup("yamlls", {
      capabilities = Nvim.builtin.lsp.capabilities,
      settings = {
        yaml = {
          hover = true,
          completion = true,
          validate = true,
          schemaStore = {
            enable = true,
            url = "https://www.schemastore.org/api/json/catalog.json",
          },
          schemas = schemas,
        },
      }
    })
  end
})

-- NOTE: The TailwindCSS LSP configuration is commented out because it is already included in
--       LunarVim's default ftplugin settings for html, php, css, and other web-related filetypes.
-- See:
--   ~/.local/share/lunarvim/after/ftplugin/
--   ~/.local/share/lunarvim/site/after/ftplugin/
-- 1. If you need TailwindCSS LSP for additional filetypes, create and configure an ftplugin file
--    in your user configuration directory (e.g., after/ftplugin/...lua), and add
--    `require("lvim.lsp.manager").setup("tailwindcss")` to that file.
-- 2. If you want to use TailwindCSS but need to *override LunarVim's default ftplugin settings*
--    (e.g., if the default LSP configuration does not meet your needs):
--    First, create your own ftplugin file as described in step 1.
--    Then, use `vim.opt.rtp:remove` or `remove_lunarvim_default_language_ftplugins_in_rtp`.
--    This will prevent LunarVim's default ftplugin settings from interfering with
--    your custom LSP or other configurations.
vim.api.nvim_create_autocmd("FileType", {
  pattern = { "css", "scss", "less" },
  once = true,
  callback = function()
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
  end
})
vim.api.nvim_create_autocmd("FileType", {
  pattern = { "typescript", "javascript", "typescriptreact", "javascriptreact" },
  once = true,
  callback = function()
    require("lvim.lsp.manager").setup("ts_ls", {
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
      },
      handlers = {
        ["textDocument/definition"] = function(_, result, ctx)
          if result == nil or vim.tbl_isempty(result) then
            local _ = vim.lsp.log.info() and vim.lsp.log.info(ctx.method, "No location found")
            return nil
          end

          local nodejs_pattern1 = "node_modules/@types/.*/index.d.ts"
          local nodejs_pattern2 = "node_modules/%%40types/.*/index.d.ts"
          -- get offset_encoding
          local offset_encoding = ctx.client and ctx.client.offset_encoding or "utf-16"

          if vim.islist(result) then
            -- if result == 1, maybe user just want to jump to the type definition
            if #result == 1 then
              vim.lsp.util.jump_to_location(result[1], offset_encoding)
            else
              -- fillter out items that contain node_modules/@types/.*/index.d.ts
              local filtered_result = {}
              for _, value in pairs(result) do
                if not (string.match(value.targetUri or value.uri, nodejs_pattern1) or string.match(value.targetUri or value.uri, nodejs_pattern2)) then
                  table.insert(filtered_result, value)
                end
              end

              -- Determine actions based on filtered results
              if #filtered_result == 1 then
                vim.lsp.util.jump_to_location(filtered_result[1], offset_encoding)
              elseif #filtered_result > 1 then
                local items = vim.lsp.util.locations_to_items(filtered_result, offset_encoding)
                vim.fn.setqflist({}, ' ', { items = items })
                vim.api.nvim_command("copen")
              end
            end
            -- If the result is empty, do nothing
          else
            vim.lsp.util.jump_to_location(result, offset_encoding)
          end
        end
      }
    })
  end
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

  -- 将处理后的路径列表用于更新 `PYTHONPATH`
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

local function modify_pythonpath(initial_pythonpath)
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

local function reset_pythonpath(initial_pythonpath)
  vim.fn.setenv("PYTHONPATH", initial_pythonpath)
end

vim.api.nvim_create_autocmd("FileType", {
  pattern = "python",
  once = true,
  callback = function()
    initializeAndDeduplicatePythonPaths()

    local initial_pythonpath = vim.fn.getenv("PYTHONPATH") or ""

    modify_pythonpath(initial_pythonpath)

    vim.api.nvim_create_autocmd("BufEnter", {
      pattern = "*.py",
      callback = function()
        modify_pythonpath(initial_pythonpath)
      end,
    })
    vim.api.nvim_create_autocmd("BufLeave", {
      pattern = "*.py",
      callback = function()
        reset_pythonpath(initial_pythonpath)
      end,
    })
  end,
})
