local autocmd = vim.api.nvim_create_autocmd
local navbuddy = require("nvim-navbuddy")

lvim.lsp.installer.setup.automatic_installation = {
  'emmet_ls'
}

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

-- 獲取當前的工作目錄
local current_directory = vim.fn.getcwd()

local custom_python_paths = {
  "/home/Andy6/research",
  "/home/andy6/research",
  "/root/research",
  current_directory -- 將當前目錄加入到路徑列表中
  -- ... 添加其他路徑
}

-- 去重複的方法
local unique_paths = {}
for _, path in ipairs(custom_python_paths) do
  unique_paths[path] = true
end

-- 將唯一的路徑轉回到列表中
local deduplicated_paths = {}
for path, _ in pairs(unique_paths) do
  table.insert(deduplicated_paths, path)
end
custom_python_paths = deduplicated_paths

local current_pythonpath = vim.fn.getenv("PYTHONPATH") or ""
for _, path in ipairs(custom_python_paths) do
  if current_pythonpath == "" or current_pythonpath == vim.NIL then
    current_pythonpath = path
  else
    current_pythonpath = current_pythonpath .. ":" .. path
  end
end

vim.fn.setenv("PYTHONPATH", current_pythonpath)
