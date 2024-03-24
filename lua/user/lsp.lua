local navbuddy = require("nvim-navbuddy")

lvim.lsp.on_attach_callback = function(client, bufnr)
  if client.server_capabilities.documentSymbolProvider then
    navbuddy.attach(client, bufnr)
  end
end

-- 底下 Maso.. require("lvim.lsp... 為啟用 html emmet-ls 補全功能
-- :MasonInstall emmet-ls
local opts = { filetypes = { "html", "htmldjango" } }
pcall(function()
  require("lvim.lsp.manager").setup("html", opts)
end)
-- autocmd({ "FileType" }, { pattern = { "python", "html" }, command = "UltiSnipsAddFiletypes python.django.html.css" })
-- autocmd({ "FileType" }, { pattern = { "python" }, command = "setlocal foldmethod=indent" })

local function initializeAndDeduplicatePythonPaths()
  local custom_python_paths = {
    "/home/Andy6/research",
    "/home/andy6/research",
    "/root/research",
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
